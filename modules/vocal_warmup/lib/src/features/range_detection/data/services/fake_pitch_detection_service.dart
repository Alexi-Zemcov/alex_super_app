import 'package:music_theory/music_theory.dart';
import 'package:vocal_warmup/src/features/range_detection/domain/entities/range_detection_target.dart';
import 'package:vocal_warmup/src/features/range_detection/domain/services/pitch_detection_service.dart';

class FakePitchDetectionService implements PitchDetectionService {
  const FakePitchDetectionService({
    this.delay = const Duration(milliseconds: 700),
  });

  final Duration delay;

  @override
  Future<ScientificNote> detectStableNote(RangeDetectionTarget target) async {
    await Future<void>.delayed(delay);
    return ScientificNote.parse(target.isLowest ? 'E2' : 'C5');
  }
}
