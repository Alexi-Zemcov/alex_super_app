import 'package:flutter_test/flutter_test.dart';
import 'package:music_theory/music_theory.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vocal_warmup/src/features/range_detection/data/datasources/vocal_range_storage_datasource.dart';
import 'package:vocal_warmup/src/features/range_detection/data/repositories/shared_preferences_vocal_range_repository.dart';
import 'package:vocal_warmup/src/features/range_detection/data/services/fake_pitch_detection_service.dart';
import 'package:vocal_warmup/src/features/range_detection/domain/entities/range_detection_target.dart';
import 'package:vocal_warmup/src/features/range_detection/domain/entities/vocal_range.dart';
import 'package:vocal_warmup/src/features/range_detection/domain/services/voice_classifier.dart';

void main() {
  group('VocalRangeRepository', () {
    test('returns null when no range is stored', () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final repository = SharedPreferencesVocalRangeRepository(
        SharedPreferencesVocalRangeStorageDataSource(preferences),
      );

      expect(await repository.loadRange(), isNull);
    });

    test('saves, loads, and overwrites the vocal range', () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final repository = SharedPreferencesVocalRangeRepository(
        SharedPreferencesVocalRangeStorageDataSource(preferences),
      );
      final firstRange = VocalRange(
        lowestNote: ScientificNote.parse('E2'),
        highestNote: ScientificNote.parse('C5'),
        detectedAt: DateTime.utc(2026, 4, 23),
      );
      final secondRange = VocalRange(
        lowestNote: ScientificNote.parse('F2'),
        highestNote: ScientificNote.parse('D5'),
        detectedAt: DateTime.utc(2026, 4, 24),
      );

      await repository.saveRange(firstRange);
      expect(await repository.loadRange(), firstRange);

      await repository.saveRange(secondRange);
      expect(await repository.loadRange(), secondRange);
    });
  });

  group('FakePitchDetectionService', () {
    test('returns deterministic low and high notes', () async {
      const service = FakePitchDetectionService(delay: Duration.zero);

      expect(
        await service.detectStableNote(RangeDetectionTarget.lowest),
        ScientificNote.parse('E2'),
      );
      expect(
        await service.detectStableNote(RangeDetectionTarget.highest),
        ScientificNote.parse('C5'),
      );
    });
  });

  group('SimpleVoiceClassifier', () {
    test('classifies E2-C5 as dramatic tenor', () {
      const classifier = SimpleVoiceClassifier();
      final voiceType = classifier.classify(
        VocalRange(
          lowestNote: ScientificNote.parse('E2'),
          highestNote: ScientificNote.parse('C5'),
          detectedAt: DateTime.utc(2026, 4, 23),
        ),
      );

      expect(voiceType.title, 'Тенор');
      expect(voiceType.description, 'Драматический');
    });
  });
}
