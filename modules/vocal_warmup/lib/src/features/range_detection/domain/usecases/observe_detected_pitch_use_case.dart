import 'package:vocal_warmup/src/features/range_detection/domain/entities/detected_pitch_sample.dart';
import 'package:vocal_warmup/src/features/range_detection/domain/entities/range_detection_target.dart';
import 'package:vocal_warmup/src/features/range_detection/domain/services/pitch_detection_service.dart';

class ObserveDetectedPitchUseCase {
  const ObserveDetectedPitchUseCase(this._pitchDetectionService);

  final PitchDetectionService _pitchDetectionService;

  Stream<DetectedPitchSample> call(RangeDetectionTarget target) {
    return _pitchDetectionService.observeDetectedPitches(target);
  }
}
