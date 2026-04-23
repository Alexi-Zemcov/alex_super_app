import 'package:music_theory/music_theory.dart';
import 'package:vocal_warmup/src/features/range_detection/domain/entities/range_detection_target.dart';
import 'package:vocal_warmup/src/features/range_detection/domain/services/pitch_detection_service.dart';

class DetectStableNoteUseCase {
  const DetectStableNoteUseCase(this._pitchDetectionService);

  final PitchDetectionService _pitchDetectionService;

  Future<ScientificNote> call(RangeDetectionTarget target) {
    return _pitchDetectionService.detectStableNote(target);
  }
}
