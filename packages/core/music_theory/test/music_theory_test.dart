import 'package:flutter_test/flutter_test.dart';
import 'package:music_theory/music_theory.dart';

void main() {
  group('ScientificNote', () {
    test('parses scientific notes and converts to MIDI', () {
      final note = ScientificNote.parse('C4');

      expect(note.note, Note.c);
      expect(note.octave, 4);
      expect(note.midi, 60);
      expect(note.label(), 'C4');
    });

    test('transposes across octaves', () {
      final note = ScientificNote.parse('B3').transpose(1);

      expect(note, ScientificNote.parse('C4'));
      expect(note.frequencyHz, closeTo(261.6255, 0.01));
    });
  });

  group('Note', () {
    test('supports circle of fifths display preferences', () {
      expect(Note.fs.prefersFlats, isFalse);
      expect(Note.cs.prefersFlats, isTrue);
      expect(Note.cs.displayName(useFlats: false), 'C#');
      expect(Note.cs.displayName(useFlats: true), 'Db');
    });

    test('transposes with wrap-around', () {
      expect(Note.c.transpose(-1), Note.b);
      expect(Note.b.transpose(1), Note.c);
    });
  });

  group('Chord', () {
    test('major chord has the expected MIDI notes', () {
      const chord = Chord(Note.c, ChordQuality.major);

      expect(chord.midiNotes(4), [60, 64, 67]);
      expect(chord.notes, [Note.c, Note.e, Note.g]);
    });

    test('minor and diminished chords use expected intervals', () {
      const minor = Chord(Note.a, ChordQuality.minor);
      const diminished = Chord(Note.b, ChordQuality.diminished);

      expect(minor.midiNotes(4), [69, 72, 76]);
      expect(diminished.midiNotes(4), [71, 74, 77]);
    });
  });
}
