import 'package:equatable/equatable.dart';
import 'package:midi_playback/midi_playback.dart';
import 'package:music_theory/music_theory.dart';
import 'package:vocal_warmup/src/features/warmup/domain/entities/warmup_session_status.dart';
import 'package:vocal_warmup/src/features/warmup/domain/entities/warmup_settings.dart';

class WarmupState extends Equatable {
  const WarmupState({
    required this.isLoading,
    required this.settings,
    required this.availability,
    required this.sessionStatus,
    required this.currentBaseNote,
    required this.currentStep,
    required this.totalSteps,
    required this.isRangeClamped,
  });

  const WarmupState.initial()
    : this(
        isLoading: true,
        settings: WarmupSettings.defaults,
        availability: PlaybackAvailability.unsupported,
        sessionStatus: WarmupSessionStatus.idle,
        currentBaseNote: null,
        currentStep: 0,
        totalSteps: 0,
        isRangeClamped: false,
      );

  final bool isLoading;
  final WarmupSettings settings;
  final PlaybackAvailability availability;
  final WarmupSessionStatus sessionStatus;
  final ScientificNote? currentBaseNote;
  final int currentStep;
  final int totalSteps;
  final bool isRangeClamped;

  bool get hasPlayableAudio => availability.isSupported;

  bool get controlsLocked => sessionStatus.isLocked;

  bool get requiresVoiceSelection => !isLoading && settings.voiceType == null;

  ScientificNote? get displayedBaseNote =>
      currentBaseNote ?? settings.voiceType?.startNote;

  String get tonalityLabel {
    final note = displayedBaseNote;
    if (note == null) {
      return '—';
    }

    return '${note.note.displayName()} major';
  }

  bool get canStart =>
      !isLoading &&
      !controlsLocked &&
      hasPlayableAudio &&
      settings.voiceType != null &&
      (settings.stepsUp > 0 || settings.stepsDown > 0);

  WarmupState copyWith({
    bool? isLoading,
    WarmupSettings? settings,
    PlaybackAvailability? availability,
    WarmupSessionStatus? sessionStatus,
    ScientificNote? currentBaseNote,
    int? currentStep,
    int? totalSteps,
    bool? isRangeClamped,
  }) {
    return WarmupState(
      isLoading: isLoading ?? this.isLoading,
      settings: settings ?? this.settings,
      availability: availability ?? this.availability,
      sessionStatus: sessionStatus ?? this.sessionStatus,
      currentBaseNote: currentBaseNote ?? this.currentBaseNote,
      currentStep: currentStep ?? this.currentStep,
      totalSteps: totalSteps ?? this.totalSteps,
      isRangeClamped: isRangeClamped ?? this.isRangeClamped,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    settings,
    availability,
    sessionStatus,
    currentBaseNote,
    currentStep,
    totalSteps,
    isRangeClamped,
  ];
}
