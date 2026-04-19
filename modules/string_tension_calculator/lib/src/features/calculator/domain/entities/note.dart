import 'dart:math' as math;

import 'package:equatable/equatable.dart';

enum MusicalNote {
  c,
  cSharp,
  d,
  dSharp,
  e,
  f,
  fSharp,
  g,
  gSharp,
  a,
  aSharp,
  b;

  String get label => switch (this) {
    MusicalNote.c => 'C',
    MusicalNote.cSharp => 'C#',
    MusicalNote.d => 'D',
    MusicalNote.dSharp => 'D#',
    MusicalNote.e => 'E',
    MusicalNote.f => 'F',
    MusicalNote.fSharp => 'F#',
    MusicalNote.g => 'G',
    MusicalNote.gSharp => 'G#',
    MusicalNote.a => 'A',
    MusicalNote.aSharp => 'A#',
    MusicalNote.b => 'B',
  };

  int get semitone => index;

  static MusicalNote fromLabel(String value) {
    return switch (value) {
      'C' => MusicalNote.c,
      'C#' => MusicalNote.cSharp,
      'D' => MusicalNote.d,
      'D#' => MusicalNote.dSharp,
      'E' => MusicalNote.e,
      'F' => MusicalNote.f,
      'F#' => MusicalNote.fSharp,
      'G' => MusicalNote.g,
      'G#' => MusicalNote.gSharp,
      'A' => MusicalNote.a,
      'A#' => MusicalNote.aSharp,
      'B' => MusicalNote.b,
      _ => throw FormatException('Unsupported note label: $value'),
    };
  }
}

class ScientificNote extends Equatable {
  const ScientificNote({required this.note, required this.octave});

  factory ScientificNote.parse(String value) {
    final match = RegExp(r'^([A-G]#?)(-?\d)$').firstMatch(value);
    if (match == null) {
      throw FormatException('Unsupported scientific note: $value');
    }

    return ScientificNote(
      note: MusicalNote.fromLabel(match.group(1)!),
      octave: int.parse(match.group(2)!),
    );
  }

  factory ScientificNote.fromMidi(int midi) {
    final clampedMidi = midi.clamp(_midiMin, _midiMax);
    return ScientificNote(
      note: MusicalNote.values[clampedMidi % 12],
      octave: (clampedMidi ~/ 12) - 1,
    );
  }

  static const int _midiMin = 0;
  static const int _midiMax = 127;

  final MusicalNote note;
  final int octave;

  String get label => '${note.label}$octave';

  int get midi => note.semitone + (octave + 1) * 12;

  double get frequencyHz => 440 * math.pow(2, (midi - 69) / 12).toDouble();

  ScientificNote next() => ScientificNote.fromMidi(midi + 1);

  ScientificNote previous() => ScientificNote.fromMidi(midi - 1);

  @override
  List<Object?> get props => [note, octave];
}
