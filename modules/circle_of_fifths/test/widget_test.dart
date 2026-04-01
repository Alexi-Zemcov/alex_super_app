import 'package:circle_of_fifths/src/features/circle/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Note', () {
    test('circle of fifths has 12 notes', () {
      expect(Note.circleOfFifths.length, 12);
    });

    test('C is at index 0 in circle of fifths', () {
      expect(Note.circleOfFifths[0], Note.c);
    });

    test('transpose works correctly', () {
      expect(Note.c.transpose(7), Note.g); // Perfect fifth
      expect(Note.c.transpose(-3), Note.a); // Minor third down
    });

    test('MIDI note for C4 is 60', () {
      expect(Note.c.midiNote(4), 60);
    });
  });

  group('Chord', () {
    test('major chord has correct intervals', () {
      const cMajor = Chord(Note.c, ChordQuality.major);
      final midiNotes = cMajor.midiNotes(4);
      expect(midiNotes, [60, 64, 67]); // C4, E4, G4
    });

    test('minor chord has correct intervals', () {
      const aMinor = Chord(Note.a, ChordQuality.minor);
      final midiNotes = aMinor.midiNotes(4);
      expect(midiNotes, [69, 72, 76]); // A4, C5, E5
    });

    test('diminished chord has correct intervals', () {
      const bDim = Chord(Note.b, ChordQuality.diminished);
      final midiNotes = bDim.midiNotes(4);
      expect(midiNotes, [71, 74, 77]); // B4, D5, F5
    });

    test('display name includes quality suffix', () {
      expect(const Chord(Note.c, ChordQuality.major).displayName(), 'C');
      expect(const Chord(Note.a, ChordQuality.minor).displayName(), 'Am');
      expect(const Chord(Note.b, ChordQuality.diminished).displayName(), 'B°');
    });
  });

  group('MusicKey', () {
    test('C major has correct diatonic chords', () {
      const cMajor = MusicKey.cMajor;
      final chords = cMajor.diatonicChords;

      expect(chords[0], const Chord(Note.c, ChordQuality.major)); // I
      expect(chords[1], const Chord(Note.d, ChordQuality.minor)); // ii
      expect(chords[2], const Chord(Note.e, ChordQuality.minor)); // iii
      expect(chords[3], const Chord(Note.f, ChordQuality.major)); // IV
      expect(chords[4], const Chord(Note.g, ChordQuality.major)); // V
      expect(chords[5], const Chord(Note.a, ChordQuality.minor)); // vi
      expect(chords[6], const Chord(Note.b, ChordQuality.diminished)); // vii°
    });

    test('parallel key relationship is correct', () {
      const cMajor = MusicKey.cMajor;
      final aMinor = cMajor.parallelKey;

      expect(aMinor.root, Note.a);
      expect(aMinor.isMajor, false);
      expect(aMinor.parallelKey, cMajor);
    });
  });
}
