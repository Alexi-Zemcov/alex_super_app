import 'package:music_theory/music_theory.dart';
import 'package:vocal_warmup/src/features/range_detection/domain/entities/vocal_range.dart';
import 'package:vocal_warmup/src/features/range_detection/domain/entities/voice_type.dart';

abstract interface class VoiceClassifier {
  VoiceType classify(VocalRange range);
}

class SimpleVoiceClassifier implements VoiceClassifier {
  const SimpleVoiceClassifier();

  static final _tenorLowest = ScientificNote.parse('E2');
  static final _tenorHighest = ScientificNote.parse('C5');

  @override
  VoiceType classify(VocalRange range) {
    if (range.lowestNote.midi == _tenorLowest.midi &&
        range.highestNote.midi == _tenorHighest.midi) {
      return const VoiceType(title: 'Тенор', description: 'Драматический');
    }

    return const VoiceType(
      title: 'Голос',
      description: 'Комфортный диапазон определён',
    );
  }
}
