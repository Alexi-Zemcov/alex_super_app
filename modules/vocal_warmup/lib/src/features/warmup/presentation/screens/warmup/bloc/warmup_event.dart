import 'package:equatable/equatable.dart';
import 'package:vocal_warmup/src/features/warmup/domain/entities/vocal_exercise.dart';
import 'package:vocal_warmup/src/features/warmup/domain/entities/voice_type.dart';
import 'package:vocal_warmup/src/features/warmup/domain/services/warmup_session_runner.dart';

sealed class WarmupEvent extends Equatable {
  const WarmupEvent();

  @override
  List<Object?> get props => [];
}

final class WarmupInitialized extends WarmupEvent {
  const WarmupInitialized();
}

final class WarmupVoiceSelected extends WarmupEvent {
  const WarmupVoiceSelected(this.voiceType);

  final VoiceType voiceType;

  @override
  List<Object?> get props => [voiceType];
}

final class WarmupExerciseChanged extends WarmupEvent {
  const WarmupExerciseChanged(this.exercise);

  final VocalExercise exercise;

  @override
  List<Object?> get props => [exercise];
}

final class WarmupTempoChanged extends WarmupEvent {
  const WarmupTempoChanged(this.tempoBpm);

  final int tempoBpm;

  @override
  List<Object?> get props => [tempoBpm];
}

final class WarmupStepsUpChanged extends WarmupEvent {
  const WarmupStepsUpChanged(this.stepsUp);

  final int stepsUp;

  @override
  List<Object?> get props => [stepsUp];
}

final class WarmupStepsDownChanged extends WarmupEvent {
  const WarmupStepsDownChanged(this.stepsDown);

  final int stepsDown;

  @override
  List<Object?> get props => [stepsDown];
}

final class WarmupStartPressed extends WarmupEvent {
  const WarmupStartPressed();
}

final class WarmupPausePressed extends WarmupEvent {
  const WarmupPausePressed();
}

final class WarmupResumePressed extends WarmupEvent {
  const WarmupResumePressed();
}

final class WarmupStopPressed extends WarmupEvent {
  const WarmupStopPressed();
}

final class WarmupSessionEventReceived extends WarmupEvent {
  const WarmupSessionEventReceived(this.event);

  final WarmupSessionEvent event;

  @override
  List<Object?> get props => [event];
}
