import 'package:music_theory/music_theory.dart';
import 'package:vocal_warmup/src/features/range_detection/domain/entities/detected_pitch_sample.dart';
import 'package:vocal_warmup/src/features/range_detection/domain/entities/range_detection_target.dart';

abstract interface class PitchDetectionService {
  Future<void> prepareDetection();

  Stream<DetectedPitchSample> observeDetectedPitches(
    RangeDetectionTarget target,
  );

  Future<void> stopDetection();
}
