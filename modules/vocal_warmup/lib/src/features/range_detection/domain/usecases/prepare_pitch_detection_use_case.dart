import 'package:vocal_warmup/src/features/range_detection/domain/services/pitch_detection_service.dart';

class PreparePitchDetectionUseCase {
  const PreparePitchDetectionUseCase(this._pitchDetectionService);

  final PitchDetectionService _pitchDetectionService;

  Future<void> call() {
    return _pitchDetectionService.prepareDetection();
  }
}
