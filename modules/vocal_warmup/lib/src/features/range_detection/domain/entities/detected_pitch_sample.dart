import 'package:equatable/equatable.dart';
import 'package:music_theory/music_theory.dart';

class DetectedPitchSample extends Equatable {
  const DetectedPitchSample({
    required this.note,
    required this.timestamp,
    required this.isPitched,
  });

  final ScientificNote? note;
  final DateTime timestamp;
  final bool isPitched;

  @override
  List<Object?> get props => [note, timestamp, isPitched];
}
