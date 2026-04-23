import 'package:equatable/equatable.dart';
import 'package:music_theory/music_theory.dart';

class WarmupPlaybackPhase extends Equatable {
  const WarmupPlaybackPhase._({this.chord, this.octave, this.note});

  const WarmupPlaybackPhase.chord(Chord chord, int octave)
    : this._(chord: chord, octave: octave);

  const WarmupPlaybackPhase.note(ScientificNote note) : this._(note: note);

  const WarmupPlaybackPhase.rest() : this._();

  final Chord? chord;
  final int? octave;
  final ScientificNote? note;

  bool get isRest => chord == null && note == null;

  @override
  List<Object?> get props => [chord, octave, note];
}
