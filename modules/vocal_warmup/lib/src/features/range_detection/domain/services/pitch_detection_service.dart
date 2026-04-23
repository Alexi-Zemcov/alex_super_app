import 'package:music_theory/music_theory.dart';
import 'package:vocal_warmup/src/features/range_detection/domain/entities/range_detection_target.dart';

abstract interface class PitchDetectionService {
  Future<ScientificNote> detectStableNote(RangeDetectionTarget target);
}
