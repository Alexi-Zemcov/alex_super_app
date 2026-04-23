import 'package:equatable/equatable.dart';
import 'package:music_theory/music_theory.dart';
import 'package:vocal_warmup/src/features/warmup/domain/entities/warmup_direction.dart';
import 'package:vocal_warmup/src/features/warmup/domain/entities/warmup_playback_phase.dart';

class WarmupStep extends Equatable {
  const WarmupStep({
    required this.baseNote,
    required this.direction,
    required this.tonicChord,
    required this.patternNotes,
  });

  final ScientificNote baseNote;
  final WarmupDirection direction;
  final Chord tonicChord;
  final List<ScientificNote> patternNotes;

  List<WarmupPlaybackPhase> get phases => [
    WarmupPlaybackPhase.chord(tonicChord, baseNote.octave),
    for (final note in patternNotes) WarmupPlaybackPhase.note(note),
  ];

  @override
  List<Object?> get props => [baseNote, direction, tonicChord, patternNotes];
}
