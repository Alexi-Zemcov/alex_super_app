import 'package:equatable/equatable.dart';
import 'package:music_theory/music_theory.dart';

class VocalRange extends Equatable {
  const VocalRange({
    required this.lowestNote,
    required this.highestNote,
    required this.detectedAt,
  });

  final ScientificNote lowestNote;
  final ScientificNote highestNote;
  final DateTime detectedAt;

  int get lowestFrequencyHz => lowestNote.frequencyHz.round();

  int get highestFrequencyHz => highestNote.frequencyHz.round();

  VocalRange copyWith({
    ScientificNote? lowestNote,
    ScientificNote? highestNote,
    DateTime? detectedAt,
  }) {
    return VocalRange(
      lowestNote: lowestNote ?? this.lowestNote,
      highestNote: highestNote ?? this.highestNote,
      detectedAt: detectedAt ?? this.detectedAt,
    );
  }

  @override
  List<Object?> get props => [lowestNote, highestNote, detectedAt];
}
