import 'package:equatable/equatable.dart';
import 'package:vocal_warmup/src/features/warmup/domain/entities/vocal_exercise.dart';
import 'package:vocal_warmup/src/features/warmup/domain/entities/voice_type.dart';

class WarmupSettings extends Equatable {
  const WarmupSettings({
    required this.voiceType,
    required this.exercise,
    required this.tempoBpm,
    required this.stepsUp,
    required this.stepsDown,
  });

  static const WarmupSettings defaults = WarmupSettings(
    voiceType: null,
    exercise: VocalExercise.humming,
    tempoBpm: 80,
    stepsUp: 6,
    stepsDown: 6,
  );
  static const int minTempoBpm = 60;
  static const int maxTempoBpm = 120;
  static const int minSteps = 0;
  static const int maxSteps = 12;

  final VoiceType? voiceType;
  final VocalExercise exercise;
  final int tempoBpm;
  final int stepsUp;
  final int stepsDown;

  WarmupSettings copyWith({
    VoiceType? voiceType,
    bool clearVoiceType = false,
    VocalExercise? exercise,
    int? tempoBpm,
    int? stepsUp,
    int? stepsDown,
  }) {
    return WarmupSettings(
      voiceType: clearVoiceType ? null : voiceType ?? this.voiceType,
      exercise: exercise ?? this.exercise,
      tempoBpm: tempoBpm ?? this.tempoBpm,
      stepsUp: stepsUp ?? this.stepsUp,
      stepsDown: stepsDown ?? this.stepsDown,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'voiceType': voiceType?.name,
      'exercise': exercise.name,
      'tempoBpm': tempoBpm,
      'stepsUp': stepsUp,
      'stepsDown': stepsDown,
    };
  }

  factory WarmupSettings.fromJson(Map<String, dynamic> json) {
    final tempoBpm = switch (json['tempoBpm']) {
      final int value => value,
      _ => defaults.tempoBpm,
    };
    final stepsUp = switch (json['stepsUp']) {
      final int value => value,
      _ => defaults.stepsUp,
    };
    final stepsDown = switch (json['stepsDown']) {
      final int value => value,
      _ => defaults.stepsDown,
    };

    return WarmupSettings(
      voiceType: switch (json['voiceType']) {
        final String name => VoiceType.values.byName(name),
        _ => null,
      },
      exercise: switch (json['exercise']) {
        final String name => VocalExercise.values.byName(name),
        _ => VocalExercise.humming,
      },
      tempoBpm: _clampInt(tempoBpm, minTempoBpm, maxTempoBpm),
      stepsUp: _clampInt(stepsUp, minSteps, maxSteps),
      stepsDown: _clampInt(stepsDown, minSteps, maxSteps),
    );
  }

  static int _clampInt(int value, int min, int max) {
    return value.clamp(min, max);
  }

  @override
  List<Object?> get props => [
    voiceType,
    exercise,
    tempoBpm,
    stepsUp,
    stepsDown,
  ];
}
