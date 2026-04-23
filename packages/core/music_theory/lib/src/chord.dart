import 'package:equatable/equatable.dart';
import 'package:music_theory/src/note.dart';

enum ChordQuality {
  major('', [0, 4, 7]),
  minor('m', [0, 3, 7]),
  diminished('°', [0, 3, 6]);

  const ChordQuality(this.suffix, this.intervals);

  final String suffix;
  final List<int> intervals;
}

class Chord extends Equatable {
  const Chord(this.root, this.quality);

  final Note root;
  final ChordQuality quality;

  String displayName({bool useFlats = false}) {
    return '${root.displayName(useFlats: useFlats)}${quality.suffix}';
  }

  List<int> midiNotes(int octave) {
    final rootMidi = root.midiNote(octave);
    return quality.intervals.map((interval) => rootMidi + interval).toList();
  }

  List<Note> get notes {
    return quality.intervals
        .map((interval) => root.transpose(interval))
        .toList(growable: false);
  }

  @override
  List<Object?> get props => [root, quality];

  @override
  String toString() => displayName();
}
