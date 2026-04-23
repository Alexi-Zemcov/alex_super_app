import 'dart:math' as math;

import 'package:equatable/equatable.dart';
import 'package:music_theory/src/note.dart';

class ScientificNote extends Equatable {
  const ScientificNote({required this.note, required this.octave});

  factory ScientificNote.parse(String value) {
    final match = RegExp(r'^([A-G](?:#|b|♯|♭)?)(-?\d+)$').firstMatch(value);
    if (match == null) {
      throw FormatException('Unsupported scientific note: $value');
    }

    return ScientificNote(
      note: Note.fromLabel(match.group(1)!),
      octave: int.parse(match.group(2)!),
    );
  }

  factory ScientificNote.fromMidi(int midi) {
    final clampedMidi = midi.clamp(_midiMin, _midiMax);
    return ScientificNote(
      note: Note.fromSemitone(clampedMidi % 12),
      octave: (clampedMidi ~/ 12) - 1,
    );
  }

  static const int _midiMin = 0;
  static const int _midiMax = 127;

  final Note note;
  final int octave;

  String label({bool useFlats = false}) =>
      '${note.displayName(useFlats: useFlats)}$octave';

  int get midi => note.semitone + (octave + 1) * 12;

  double get frequencyHz => 440 * math.pow(2, (midi - 69) / 12).toDouble();

  ScientificNote transpose(int semitones) =>
      ScientificNote.fromMidi(midi + semitones);

  ScientificNote next() => transpose(1);

  ScientificNote previous() => transpose(-1);

  @override
  List<Object?> get props => [note, octave];
}
