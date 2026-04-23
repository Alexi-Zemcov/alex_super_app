import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:midi_playback/midi_playback.dart';
import 'package:vocal_warmup/src/features/warmup/domain/entities/voice_type.dart';
import 'package:vocal_warmup/src/features/warmup/domain/entities/warmup_session_status.dart';
import 'package:vocal_warmup/src/features/warmup/domain/entities/warmup_settings.dart';
import 'package:vocal_warmup/src/features/warmup/domain/services/warmup_sequence_planner.dart';
import 'package:vocal_warmup/src/features/warmup/domain/services/warmup_session_runner.dart';
import 'package:vocal_warmup/src/features/warmup/domain/usecases/load_warmup_settings_usecase.dart';
import 'package:vocal_warmup/src/features/warmup/domain/usecases/save_warmup_settings_usecase.dart';
import 'package:vocal_warmup/src/features/warmup/presentation/screens/warmup/bloc/warmup_event.dart';
import 'package:vocal_warmup/src/features/warmup/presentation/screens/warmup/bloc/warmup_state.dart';

class WarmupBloc extends Bloc<WarmupEvent, WarmupState> {
  WarmupBloc({
    required MidiPlaybackService playbackService,
    required LoadWarmupSettingsUseCase loadSettingsUseCase,
    required SaveWarmupSettingsUseCase saveSettingsUseCase,
    required WarmupSequencePlanner sequencePlanner,
    required WarmupSessionRunner sessionRunner,
  }) : _playbackService = playbackService,
       _loadSettingsUseCase = loadSettingsUseCase,
       _saveSettingsUseCase = saveSettingsUseCase,
       _sequencePlanner = sequencePlanner,
       _sessionRunner = sessionRunner,
       super(
         (const WarmupState.initial()).copyWith(
           availability: playbackService.availability,
         ),
       ) {
    _runnerSubscription = _sessionRunner.events.listen(
      (event) => add(WarmupSessionEventReceived(event)),
    );

    on<WarmupInitialized>(_onInitialized);
    on<WarmupVoiceSelected>(_onVoiceSelected);
    on<WarmupExerciseChanged>(_onExerciseChanged);
    on<WarmupTempoChanged>(_onTempoChanged);
    on<WarmupStepsUpChanged>(_onStepsUpChanged);
    on<WarmupStepsDownChanged>(_onStepsDownChanged);
    on<WarmupStartPressed>(_onStartPressed);
    on<WarmupPausePressed>(_onPausePressed);
    on<WarmupResumePressed>(_onResumePressed);
    on<WarmupStopPressed>(_onStopPressed);
    on<WarmupSessionEventReceived>(_onSessionEventReceived);
  }

  final MidiPlaybackService _playbackService;
  final LoadWarmupSettingsUseCase _loadSettingsUseCase;
  final SaveWarmupSettingsUseCase _saveSettingsUseCase;
  final WarmupSequencePlanner _sequencePlanner;
  final WarmupSessionRunner _sessionRunner;

  late final StreamSubscription<WarmupSessionEvent> _runnerSubscription;
  Timer? _previewTimer;

  Future<void> _onInitialized(
    WarmupInitialized event,
    Emitter<WarmupState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    final settings = await _loadSettingsUseCase() ?? WarmupSettings.defaults;
    emit(
      state.copyWith(
        isLoading: false,
        settings: settings,
        currentBaseNote: settings.voiceType?.startNote,
        availability: _playbackService.availability,
      ),
    );
  }

  Future<void> _onVoiceSelected(
    WarmupVoiceSelected event,
    Emitter<WarmupState> emit,
  ) async {
    if (state.controlsLocked) {
      return;
    }

    final newSettings = state.settings.copyWith(voiceType: event.voiceType);
    emit(
      state.copyWith(
        settings: newSettings,
        currentBaseNote: event.voiceType.startNote,
      ),
    );
    await _persistSettings(newSettings);
    await _previewVoice(event.voiceType);
  }

  Future<void> _onExerciseChanged(
    WarmupExerciseChanged event,
    Emitter<WarmupState> emit,
  ) async {
    if (state.controlsLocked) {
      return;
    }

    final newSettings = state.settings.copyWith(exercise: event.exercise);
    emit(state.copyWith(settings: newSettings));
    await _persistSettings(newSettings);
  }

  Future<void> _onTempoChanged(
    WarmupTempoChanged event,
    Emitter<WarmupState> emit,
  ) async {
    if (state.controlsLocked) {
      return;
    }

    final newSettings = state.settings.copyWith(tempoBpm: event.tempoBpm);
    emit(state.copyWith(settings: newSettings));
    await _persistSettings(newSettings);
  }

  Future<void> _onStepsUpChanged(
    WarmupStepsUpChanged event,
    Emitter<WarmupState> emit,
  ) async {
    if (state.controlsLocked) {
      return;
    }

    final newSettings = state.settings.copyWith(stepsUp: event.stepsUp);
    emit(state.copyWith(settings: newSettings));
    await _persistSettings(newSettings);
  }

  Future<void> _onStepsDownChanged(
    WarmupStepsDownChanged event,
    Emitter<WarmupState> emit,
  ) async {
    if (state.controlsLocked) {
      return;
    }

    final newSettings = state.settings.copyWith(stepsDown: event.stepsDown);
    emit(state.copyWith(settings: newSettings));
    await _persistSettings(newSettings);
  }

  Future<void> _onStartPressed(
    WarmupStartPressed event,
    Emitter<WarmupState> emit,
  ) async {
    final voiceType = state.settings.voiceType;
    if (voiceType == null || !state.canStart) {
      return;
    }

    final plan = _sequencePlanner.plan(
      voiceType: voiceType,
      stepsUp: state.settings.stepsUp,
      stepsDown: state.settings.stepsDown,
    );
    if (plan.isEmpty) {
      return;
    }

    emit(
      state.copyWith(
        sessionStatus: WarmupSessionStatus.playing,
        currentBaseNote: voiceType.startNote,
        currentStep: 0,
        totalSteps: plan.totalSteps,
        isRangeClamped: plan.isRangeClamped,
      ),
    );
    await _sessionRunner.start(plan: plan, tempoBpm: state.settings.tempoBpm);
  }

  void _onPausePressed(WarmupPausePressed event, Emitter<WarmupState> emit) {
    if (state.sessionStatus != WarmupSessionStatus.playing) {
      return;
    }

    _sessionRunner.pause();
    emit(state.copyWith(sessionStatus: WarmupSessionStatus.paused));
  }

  void _onResumePressed(WarmupResumePressed event, Emitter<WarmupState> emit) {
    if (state.sessionStatus != WarmupSessionStatus.paused) {
      return;
    }

    _sessionRunner.resume();
    emit(state.copyWith(sessionStatus: WarmupSessionStatus.playing));
  }

  Future<void> _onStopPressed(
    WarmupStopPressed event,
    Emitter<WarmupState> emit,
  ) async {
    await _sessionRunner.stop();
    emit(
      state.copyWith(
        sessionStatus: WarmupSessionStatus.idle,
        currentBaseNote: state.settings.voiceType?.startNote,
        currentStep: 0,
        totalSteps: 0,
        isRangeClamped: false,
      ),
    );
  }

  void _onSessionEventReceived(
    WarmupSessionEventReceived event,
    Emitter<WarmupState> emit,
  ) {
    switch (event.event) {
      case WarmupSessionStepStarted(
        :final step,
        :final stepIndex,
        :final totalSteps,
      ):
        emit(
          state.copyWith(
            sessionStatus: WarmupSessionStatus.playing,
            currentBaseNote: step.baseNote,
            currentStep: stepIndex,
            totalSteps: totalSteps,
          ),
        );
      case WarmupSessionFinished():
        emit(
          state.copyWith(
            sessionStatus: WarmupSessionStatus.finished,
            currentStep: state.totalSteps,
          ),
        );
    }
  }

  Future<void> _persistSettings(WarmupSettings settings) async {
    await _saveSettingsUseCase(settings);
  }

  Future<void> _previewVoice(VoiceType voiceType) async {
    if (!_playbackService.availability.isSupported) {
      return;
    }

    _previewTimer?.cancel();
    await _playbackService.stopAll();
    await _playbackService.playNote(voiceType.startNote);
    _previewTimer = Timer(const Duration(milliseconds: 800), () {
      unawaited(_playbackService.stopAll());
    });
  }

  @override
  Future<void> close() async {
    _previewTimer?.cancel();
    await _runnerSubscription.cancel();
    await _playbackService.stopAll();
    return super.close();
  }
}
