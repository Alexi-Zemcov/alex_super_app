import 'package:music_theory/music_theory.dart';
import 'package:vocal_warmup/src/features/range_detection/domain/entities/detected_pitch_sample.dart';
import 'package:vocal_warmup/src/features/range_detection/domain/entities/range_detection_target.dart';
import 'package:vocal_warmup/src/features/range_detection/domain/services/pitch_detection_service.dart';

class FakePitchDetectionService implements PitchDetectionService {
  const FakePitchDetectionService({
    this.delay = const Duration(milliseconds: 700),
  });

  final Duration delay;

  @override
  Future<void> prepareDetection() async {}

  @override
  Stream<DetectedPitchSample> observeDetectedPitches(
    RangeDetectionTarget target,
  ) async* {
    final scriptedNotes = target.isLowest
        ? ['G3', 'F3', 'E3', 'E2', 'E2', 'E2', 'E2']
        : ['G3', 'A3', 'B3', 'C5', 'C5', 'C5', 'C5'];
    final startedAt = DateTime.now();

    for (var index = 0; index < scriptedNotes.length; index++) {
      if (delay > Duration.zero) {
        await Future<void>.delayed(delay);
      }
      yield DetectedPitchSample(
        note: ScientificNote.parse(scriptedNotes[index]),
        timestamp: startedAt.add(Duration(milliseconds: index * 1000)),
        isPitched: true,
      );
    }
  }

  @override
  Future<void> stopDetection() async {}

  ScientificNote fallbackNote(RangeDetectionTarget target) {
    return ScientificNote.parse(target.isLowest ? 'E2' : 'C5');
  }
}
