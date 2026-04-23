enum Note {
  c(0, 'C', 'C'),
  cs(1, 'C#', 'Db'),
  d(2, 'D', 'D'),
  ds(3, 'D#', 'Eb'),
  e(4, 'E', 'E'),
  f(5, 'F', 'F'),
  fs(6, 'F#', 'Gb'),
  g(7, 'G', 'G'),
  gs(8, 'G#', 'Ab'),
  a(9, 'A', 'A'),
  as_(10, 'A#', 'Bb'),
  b(11, 'B', 'B');

  const Note(this.semitone, this.sharpName, this.flatName);

  final int semitone;
  final String sharpName;
  final String flatName;

  static const List<Note> circleOfFifths = [
    Note.c,
    Note.g,
    Note.d,
    Note.a,
    Note.e,
    Note.b,
    Note.fs,
    Note.cs,
    Note.gs,
    Note.ds,
    Note.as_,
    Note.f,
  ];

  static Note fromSemitone(int semitone) {
    final normalizedSemitone = semitone % 12;
    return Note.values.firstWhere(
      (note) => note.semitone == normalizedSemitone,
    );
  }

  static Note fromLabel(String value) {
    return switch (value) {
      'C' => Note.c,
      'C#' || 'C♯' || 'Db' || 'D♭' => Note.cs,
      'D' => Note.d,
      'D#' || 'D♯' || 'Eb' || 'E♭' => Note.ds,
      'E' => Note.e,
      'F' => Note.f,
      'F#' || 'F♯' || 'Gb' || 'G♭' => Note.fs,
      'G' => Note.g,
      'G#' || 'G♯' || 'Ab' || 'A♭' => Note.gs,
      'A' => Note.a,
      'A#' || 'A♯' || 'Bb' || 'B♭' => Note.as_,
      'B' => Note.b,
      _ => throw FormatException('Unsupported note label: $value'),
    };
  }

  int midiNote(int octave) => 12 + (octave * 12) + semitone;

  Note transpose(int semitones) => Note.fromSemitone(semitone + semitones);

  String displayName({bool useFlats = false}) {
    if (useFlats && flatName != sharpName) {
      return flatName;
    }

    return sharpName;
  }

  int get circleIndex => circleOfFifths.indexOf(this);

  bool get prefersFlats => circleIndex >= 7;
}
