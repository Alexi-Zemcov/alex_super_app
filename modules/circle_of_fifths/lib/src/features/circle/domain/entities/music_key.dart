import 'package:circle_of_fifths/src/features/circle/domain/entities/chord.dart';
import 'package:circle_of_fifths/src/features/circle/domain/entities/note.dart';
import 'package:flutter/material.dart';

/// Represents a musical key (scale) with its diatonic chords.
@immutable
class MusicKey {
  const MusicKey(this.root, this.isMajor);

  /// The root note of the key.
  final Note root;

  /// Whether this is a major key (true) or minor key (false).
  final bool isMajor;

  /// Default key: C major.
  static const MusicKey cMajor = MusicKey(Note.c, true);

  /// Intervals for major scale in semitones from root.
  static const List<int> majorScaleIntervals = [0, 2, 4, 5, 7, 9, 11];

  /// Intervals for natural minor scale in semitones from root.
  static const List<int> minorScaleIntervals = [0, 2, 3, 5, 7, 8, 10];

  /// Chord qualities for each degree of major scale.
  /// I=maj, ii=min, iii=min, IV=maj, V=maj, vi=min, vii°=dim
  static const List<ChordQuality> majorChordQualities = [
    ChordQuality.major,
    ChordQuality.minor,
    ChordQuality.minor,
    ChordQuality.major,
    ChordQuality.major,
    ChordQuality.minor,
    ChordQuality.diminished,
  ];

  /// Chord qualities for each degree of minor scale.
  /// i=min, ii°=dim, III=maj, iv=min, v=min, VI=maj, VII=maj
  static const List<ChordQuality> minorChordQualities = [
    ChordQuality.minor,
    ChordQuality.diminished,
    ChordQuality.major,
    ChordQuality.minor,
    ChordQuality.minor,
    ChordQuality.major,
    ChordQuality.major,
  ];

  /// Roman numerals for major scale degrees.
  static const List<String> majorDegreeNames = [
    'I',
    'ii',
    'iii',
    'IV',
    'V',
    'vi',
    'vii°',
  ];

  /// Roman numerals for minor scale degrees.
  static const List<String> minorDegreeNames = [
    'i',
    'ii°',
    'III',
    'iv',
    'v',
    'VI',
    'VII',
  ];

  /// Colors for each scale degree (matching the screenshot design).
  static const List<Color> degreeColors = [
    Colors.orange, // I/i - tonic
    Color(0xFFF48FB1), // ii/II - pink 300
    Color(0xFFF8BBD0), // iii/III - pink 200
    Colors.amber, // IV/iv
    Color(0xFFFFD54F), // V/v - amber 300
    Color(0xFFFCE4EC), // vi/VI - pink 100
    Color(0xFFFFE082), // vii°/VII - amber 200
  ];

  /// Returns the parallel key (major -> relative minor, minor -> relative major).
  MusicKey get parallelKey {
    if (isMajor) {
      // Relative minor is 3 semitones below the major root.
      return MusicKey(root.transpose(-3), false);
    } else {
      // Relative major is 3 semitones above the minor root.
      return MusicKey(root.transpose(3), true);
    }
  }

  /// Returns the scale degrees (notes) for this key.
  List<Note> get scaleNotes {
    final intervals = isMajor ? majorScaleIntervals : minorScaleIntervals;
    return intervals.map((i) => root.transpose(i)).toList();
  }

  /// Returns the diatonic chords for this key.
  List<Chord> get diatonicChords {
    final notes = scaleNotes;
    final qualities = isMajor ? majorChordQualities : minorChordQualities;
    return List.generate(7, (i) => Chord(notes[i], qualities[i]));
  }

  /// Returns the degree names for this key.
  List<String> get degreeNames => isMajor ? majorDegreeNames : minorDegreeNames;

  /// Whether this key prefers flat notation.
  bool get useFlats => root.prefersFlats;

  /// Display name of the key (e.g., 'C', 'Am', 'F♯', 'B♭m').
  String get displayName {
    final noteName = root.displayName(useFlats: useFlats);
    return isMajor ? noteName : '${noteName}m';
  }

  /// Returns all chords that belong to this key (both major and parallel minor).
  /// Used for highlighting on the circle of fifths.
  Set<Chord> get allDiatonicChords {
    final chords = <Chord>{};
    chords.addAll(diatonicChords);
    chords.addAll(parallelKey.diatonicChords);
    return chords;
  }

  /// Returns the degree (0-6) of a chord in this key, or null if not diatonic.
  int? getDegree(Chord chord) {
    final chords = diatonicChords;
    for (var i = 0; i < chords.length; i++) {
      if (chords[i].root == chord.root && chords[i].quality == chord.quality) {
        return i;
      }
    }
    return null;
  }

  /// Returns the color for a chord based on its degree in this key.
  Color? getChordColor(Chord chord) {
    final degree = getDegree(chord);
    if (degree != null) {
      return degreeColors[degree];
    }

    // Check parallel key.
    final parallelDegree = parallelKey.getDegree(chord);
    if (parallelDegree != null) {
      return degreeColors[parallelDegree];
    }

    return null;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MusicKey && other.root == root && other.isMajor == isMajor;
  }

  @override
  int get hashCode => Object.hash(root, isMajor);

  @override
  String toString() => displayName;
}
