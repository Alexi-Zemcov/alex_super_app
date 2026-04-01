import 'package:circle_of_fifths/src/features/circle/domain/entities/note.dart';
import 'package:flutter/foundation.dart';

/// Represents the quality/type of a chord.
enum ChordQuality {
  major('', [0, 4, 7]),
  minor('m', [0, 3, 7]),
  diminished('°', [0, 3, 6]);

  const ChordQuality(this.suffix, this.intervals);

  /// Suffix added to chord name (e.g., 'm' for minor, '°' for diminished).
  final String suffix;

  /// Intervals from root in semitones [root, third, fifth].
  final List<int> intervals;
}

/// Represents a chord with a root note and quality.
@immutable
class Chord {
  const Chord(this.root, this.quality);

  /// The root note of the chord.
  final Note root;

  /// The quality/type of the chord.
  final ChordQuality quality;

  /// Display name of the chord (e.g., 'C', 'Am', 'B°').
  String displayName({bool useFlats = false}) {
    return '${root.displayName(useFlats: useFlats)}${quality.suffix}';
  }

  /// Returns the MIDI note numbers for this chord in a given octave.
  /// Returns a list of 3 notes: [root, third, fifth].
  List<int> midiNotes(int octave) {
    final rootMidi = root.midiNote(octave);
    return quality.intervals.map((interval) => rootMidi + interval).toList();
  }

  /// Returns the notes that make up this chord.
  List<Note> get notes {
    return quality.intervals
        .map((interval) => root.transpose(interval))
        .toList();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Chord && other.root == root && other.quality == quality;
  }

  @override
  int get hashCode => Object.hash(root, quality);

  @override
  String toString() => displayName();
}
