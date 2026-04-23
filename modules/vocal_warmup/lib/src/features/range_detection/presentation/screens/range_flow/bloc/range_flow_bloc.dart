import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_theory/music_theory.dart';
import 'package:pitch_detection/pitch_detection.dart';
import 'package:vocal_warmup/src/features/range_detection/domain/entities/detected_pitch_sample.dart';
import 'package:vocal_warmup/src/features/range_detection/domain/entities/range_detection_target.dart';
import 'package:vocal_warmup/src/features/range_detection/domain/entities/vocal_range.dart';
import 'package:vocal_warmup/src/features/range_detection/domain/usecases/classify_voice_use_case.dart';
import 'package:vocal_warmup/src/features/range_detection/domain/usecases/load_vocal_range_use_case.dart';
import 'package:vocal_warmup/src/features/range_detection/domain/usecases/observe_detected_pitch_use_case.dart';
import 'package:vocal_warmup/src/features/range_detection/domain/usecases/prepare_pitch_detection_use_case.dart';
import 'package:vocal_warmup/src/features/range_detection/domain/usecases/save_vocal_range_use_case.dart';
import 'package:vocal_warmup/src/features/range_detection/domain/usecases/stop_pitch_detection_use_case.dart';
import 'package:vocal_warmup/src/features/range_detection/presentation/screens/range_flow/bloc/range_flow_event.dart';
import 'package:vocal_warmup/src/features/range_detection/presentation/screens/range_flow/bloc/range_flow_state.dart';

class RangeFlowBloc extends Bloc<RangeFlowEvent, RangeFlowState> {
  RangeFlowBloc({
    required LoadVocalRangeUseCase loadRange,
    required SaveVocalRangeUseCase saveRange,
    required PreparePitchDetectionUseCase prepareDetection,
    required ObserveDetectedPitchUseCase observeDetectedPitch,
    required StopPitchDetectionUseCase stopDetection,
    required ClassifyVoiceUseCase classifyVoice,
  }) : _loadRange = loadRange,
       _saveRange = saveRange,
       _prepareDetection = prepareDetection,
       _observeDetectedPitch = observeDetectedPitch,
       _stopDetection = stopDetection,
       _classifyVoice = classifyVoice,
       super(const RangeFlowInitial()) {
    on<RangeFlowStarted>(_onStarted);
    on<RangeFlowRestarted>(_onRestarted);
    on<RangeFlowContinuePressed>(_onContinuePressed);
  }

  final LoadVocalRangeUseCase _loadRange;
  final SaveVocalRangeUseCase _saveRange;
  final PreparePitchDetectionUseCase _prepareDetection;
  final ObserveDetectedPitchUseCase _observeDetectedPitch;
  final StopPitchDetectionUseCase _stopDetection;
  final ClassifyVoiceUseCase _classifyVoice;

  static const _holdDuration = Duration(seconds: 3);

  @override
  Future<void> close() async {
    await _stopDetection();
    return super.close();
  }

  Future<void> _onStarted(
    RangeFlowStarted event,
    Emitter<RangeFlowState> emit,
  ) async {
    emit(const RangeFlowLoading());

    try {
      final storedRange = await _loadRange();
      if (storedRange != null) {
        emit(RangeFlowExerciseSelection(range: storedRange));
        return;
      }

      await _detectRange(emit);
    } catch (error) {
      emit(RangeFlowFailure(_mapFailureMessage(error)));
    }
  }

  Future<void> _onRestarted(
    RangeFlowRestarted event,
    Emitter<RangeFlowState> emit,
  ) async {
    emit(const RangeFlowLoading());
    try {
      await _detectRange(emit);
    } catch (error) {
      emit(RangeFlowFailure(_mapFailureMessage(error)));
    }
  }

  Future<void> _onContinuePressed(
    RangeFlowContinuePressed event,
    Emitter<RangeFlowState> emit,
  ) async {
    final selectedRange = event.selectedRange;
    if (selectedRange.highestNote.midi <= selectedRange.lowestNote.midi) {
      emit(
        const RangeFlowFailure(
          'Верхняя нота должна быть выше нижней. Попробуйте ещё раз.',
        ),
      );
      return;
    }

    emit(const RangeFlowLoading());

    try {
      await _saveRange(selectedRange);
      emit(RangeFlowExerciseSelection(range: selectedRange));
    } catch (error) {
      emit(RangeFlowFailure(_mapFailureMessage(error)));
    }
  }

  Future<void> _detectRange(Emitter<RangeFlowState> emit) async {
    await _prepareDetection();

    final lowestNote = await _detectBoundary(
      target: RangeDetectionTarget.lowest,
      emit: emit,
    );

    final highestNote = await _detectBoundary(
      target: RangeDetectionTarget.highest,
      emit: emit,
      lowestNote: lowestNote,
    );

    if (highestNote.midi <= lowestNote.midi) {
      emit(
        const RangeFlowFailure(
          'Верхняя нота должна быть выше нижней. Попробуйте ещё раз.',
        ),
      );
      return;
    }

    final range = VocalRange(
      lowestNote: lowestNote,
      highestNote: highestNote,
      detectedAt: DateTime.now(),
    );
    emit(RangeFlowResult(range: range, voiceType: _classifyVoice(range)));
  }

  Future<ScientificNote> _detectBoundary({
    required RangeDetectionTarget target,
    required Emitter<RangeFlowState> emit,
    ScientificNote? lowestNote,
  }) async {
    ScientificNote? comfortNote;
    ScientificNote? streakNote;
    DateTime? streakStartedAt;
    var hasMovedTowardTarget = false;

    emit(RangeFlowListening(target: target, lowestNote: lowestNote));

    final iterator = StreamIterator<DetectedPitchSample>(
      _observeDetectedPitch(target),
    );

    try {
      while (await iterator.moveNext()) {
        final sample = iterator.current;
        final nextState = _buildListeningState(
          sample: sample,
          target: target,
          lowestNote: lowestNote,
          comfortNote: comfortNote,
          streakNote: streakNote,
          streakStartedAt: streakStartedAt,
          hasMovedTowardTarget: hasMovedTowardTarget,
        );
        comfortNote = nextState.comfortNote;
        streakNote = nextState.streakNote;
        streakStartedAt = nextState.streakStartedAt;
        hasMovedTowardTarget = nextState.hasMovedTowardTarget;

        emit(nextState.state);

        if (nextState.completedNote case final completedNote?) {
          return completedNote;
        }
      }
    } finally {
      await iterator.cancel();
      await _stopDetection();
    }

    throw PitchDetectionException.noStablePitch();
  }

  _BoundaryProgress _buildListeningState({
    required DetectedPitchSample sample,
    required RangeDetectionTarget target,
    required ScientificNote? lowestNote,
    required ScientificNote? comfortNote,
    required ScientificNote? streakNote,
    required DateTime? streakStartedAt,
    required bool hasMovedTowardTarget,
  }) {
    final note = sample.note;
    var nextComfortNote = comfortNote;
    var nextStreakNote = streakNote;
    var nextStreakStartedAt = streakStartedAt;
    var nextHasMovedTowardTarget = hasMovedTowardTarget;
    var holdProgress = 0.0;
    ScientificNote? completedNote;

    if (!sample.isPitched || note == null) {
      nextStreakNote = null;
      nextStreakStartedAt = null;
    } else {
      if (nextComfortNote == null) {
        nextComfortNote = note;
      } else if (!nextHasMovedTowardTarget &&
          _movedTowardTarget(nextComfortNote, note, target)) {
        nextHasMovedTowardTarget = true;
        nextStreakNote = note;
        nextStreakStartedAt = sample.timestamp;
      } else if (nextHasMovedTowardTarget &&
          _movedTowardTarget(nextComfortNote, note, target)) {
        if (nextStreakNote != note) {
          nextStreakNote = note;
          nextStreakStartedAt = sample.timestamp;
        }
      } else if (nextHasMovedTowardTarget) {
        nextStreakNote = null;
        nextStreakStartedAt = null;
      }

      if (nextHasMovedTowardTarget &&
          nextStreakNote == note &&
          nextStreakStartedAt != null) {
        holdProgress =
            sample.timestamp.difference(nextStreakStartedAt).inMilliseconds /
            _holdDuration.inMilliseconds;
        holdProgress = holdProgress.clamp(0.0, 1.0);
        if (holdProgress >= 1) {
          completedNote = note;
        }
      }
    }

    return _BoundaryProgress(
      comfortNote: nextComfortNote,
      streakNote: nextStreakNote,
      streakStartedAt: nextStreakStartedAt,
      hasMovedTowardTarget: nextHasMovedTowardTarget,
      completedNote: completedNote,
      state: RangeFlowListening(
        target: target,
        lowestNote: lowestNote,
        comfortNote: nextComfortNote,
        currentNote: note,
        hasMovedTowardTarget: nextHasMovedTowardTarget,
        holdProgress: holdProgress,
      ),
    );
  }

  bool _movedTowardTarget(
    ScientificNote comfortNote,
    ScientificNote note,
    RangeDetectionTarget target,
  ) {
    return target.isLowest
        ? note.midi < comfortNote.midi
        : note.midi > comfortNote.midi;
  }

  String _mapFailureMessage(Object error) {
    if (error is! PitchDetectionException) {
      return 'Не удалось определить диапазон. Попробуйте ещё раз.';
    }

    return switch (error.code) {
      PitchDetectionErrorCode.permissionDenied ||
      PitchDetectionErrorCode.permissionPermanentlyDenied =>
        'Нужен доступ к микрофону.',
      PitchDetectionErrorCode.noStablePitch =>
        'Не удалось определить ноту. Попробуйте ещё раз.',
      PitchDetectionErrorCode.unsupportedPlatform =>
        'Определение диапазона недоступно на этом устройстве.',
      PitchDetectionErrorCode.alreadyListening ||
      PitchDetectionErrorCode.nativeFailure =>
        'Не удалось определить диапазон. Попробуйте ещё раз.',
    };
  }
}

class _BoundaryProgress {
  const _BoundaryProgress({
    required this.comfortNote,
    required this.streakNote,
    required this.streakStartedAt,
    required this.hasMovedTowardTarget,
    required this.completedNote,
    required this.state,
  });

  final ScientificNote? comfortNote;
  final ScientificNote? streakNote;
  final DateTime? streakStartedAt;
  final bool hasMovedTowardTarget;
  final ScientificNote? completedNote;
  final RangeFlowListening state;
}
