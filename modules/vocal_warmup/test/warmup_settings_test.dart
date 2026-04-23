import 'package:flutter_test/flutter_test.dart';
import 'package:vocal_warmup/src/features/warmup/domain/entities/vocal_exercise.dart';
import 'package:vocal_warmup/src/features/warmup/domain/entities/voice_type.dart';
import 'package:vocal_warmup/src/features/warmup/domain/entities/warmup_settings.dart';

void main() {
  test('clamps restored scalar settings to supported UI ranges', () {
    final settings = WarmupSettings.fromJson({
      'voiceType': VoiceType.mezzo.name,
      'exercise': VocalExercise.lipTrill.name,
      'tempoBpm': 1000,
      'stepsUp': -3,
      'stepsDown': 99,
    });

    expect(settings.voiceType, VoiceType.mezzo);
    expect(settings.exercise, VocalExercise.lipTrill);
    expect(settings.tempoBpm, WarmupSettings.maxTempoBpm);
    expect(settings.stepsUp, WarmupSettings.minSteps);
    expect(settings.stepsDown, WarmupSettings.maxSteps);
  });
}
