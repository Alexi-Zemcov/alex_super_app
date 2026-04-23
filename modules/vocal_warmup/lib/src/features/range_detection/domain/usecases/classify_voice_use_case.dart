import 'package:vocal_warmup/src/features/range_detection/domain/entities/vocal_range.dart';
import 'package:vocal_warmup/src/features/range_detection/domain/entities/voice_type.dart';
import 'package:vocal_warmup/src/features/range_detection/domain/services/voice_classifier.dart';

class ClassifyVoiceUseCase {
  const ClassifyVoiceUseCase(this._classifier);

  final VoiceClassifier _classifier;

  VoiceType call(VocalRange range) => _classifier.classify(range);
}
