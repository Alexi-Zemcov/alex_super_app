/// Represents the 12 chromatic notes in Western music.
///
/// Each note has a semitone offset from C (0-11) and display names
/// for sharp and flat representations.
enum Note {
  c(0, 'C', 'C'),
  cs(1, 'C♯', 'D♭'),
  d(2, 'D', 'D'),
  ds(3, 'D♯', 'E♭'),
  e(4, 'E', 'E'),
  f(5, 'F', 'F'),
  fs(6, 'F♯', 'G♭'),
  g(7, 'G', 'G'),
  gs(8, 'G♯', 'A♭'),
  a(9, 'A', 'A'),
  as_(10, 'A♯', 'B♭'),
  b(11, 'B', 'B');

  const Note(this.semitone, this.sharpName, this.flatName);

  /// Semitone offset from C (0-11).
  final int semitone;

  /// Display name using sharp notation.
  final String sharpName;

  /// Display name using flat notation.
  final String flatName;

  /// Circle of fifths order starting from C (clockwise).
  /// C -> G -> D -> A -> E -> B -> F#/Gb -> Db -> Ab -> Eb -> Bb -> F
  static const List<Note> circleOfFifths = [
    Note.c,
    Note.g,
    Note.d,
    Note.a,
    Note.e,
    Note.b,
    Note.fs, // F#/Gb
    Note.cs, // Db
    Note.gs, // Ab
    Note.ds, // Eb
    Note.as_, // Bb
    Note.f,
  ];

  /// Returns the MIDI note number for this note in a given octave.
  /// C4 (middle C) = 60.
  int midiNote(int octave) => 12 + (octave * 12) + semitone;

  /// Transposes this note by the given number of semitones.
  Note transpose(int semitones) {
    final newSemitone = (semitone + semitones) % 12;
    return Note.values.firstWhere((n) => n.semitone == newSemitone);
  }

  /// Returns the display name based on whether to use flats.
  /// Uses flats for keys on the left side of the circle (F, Bb, Eb, Ab, Db, Gb).
  String displayName({bool useFlats = false}) {
    if (useFlats && flatName != sharpName) {
      return flatName;
    }
    return sharpName;
  }

  /// Index in the circle of fifths (0 = C, 1 = G, etc.).
  int get circleIndex => circleOfFifths.indexOf(this);

  /// Whether this note is typically written with flats (left side of circle).
  bool get prefersFlats => circleIndex >= 7;
}
