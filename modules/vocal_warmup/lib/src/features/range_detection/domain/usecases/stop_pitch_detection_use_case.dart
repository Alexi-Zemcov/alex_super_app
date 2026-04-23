import 'package:vocal_warmup/src/features/range_detection/domain/services/pitch_detection_service.dart';

class StopPitchDetectionUseCase {
  const StopPitchDetectionUseCase(this._pitchDetectionService);

  final PitchDetectionService _pitchDetectionService;

  Future<void> call() {
    return _pitchDetectionService.stopDetection();
  }
}
