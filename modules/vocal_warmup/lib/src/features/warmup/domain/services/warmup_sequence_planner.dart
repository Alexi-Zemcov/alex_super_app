import 'package:music_theory/music_theory.dart';
import 'package:vocal_warmup/src/features/warmup/domain/entities/entities.dart';

class WarmupSequencePlanner {
  static const List<int> _patternIntervals = [0, 2, 4, 2, 0];

  WarmupPlan plan({
    required VoiceType voiceType,
    required int stepsUp,
    required int stepsDown,
  }) {
    var isRangeClamped = false;
    final steps = <WarmupStep>[
      ..._buildDirectionSteps(
        voiceType: voiceType,
        direction: WarmupDirection.up,
        transpositionSteps: stepsUp,
        onRangeClamp: () => isRangeClamped = true,
      ),
      ..._buildDirectionSteps(
        voiceType: voiceType,
        direction: WarmupDirection.down,
        transpositionSteps: stepsDown,
        onRangeClamp: () => isRangeClamped = true,
      ),
    ];

    return WarmupPlan(steps: steps, isRangeClamped: isRangeClamped);
  }

  List<WarmupStep> _buildDirectionSteps({
    required VoiceType voiceType,
    required WarmupDirection direction,
    required int transpositionSteps,
    required void Function() onRangeClamp,
  }) {
    if (transpositionSteps <= 0) {
      return const [];
    }

    final steps = <WarmupStep>[];
    final startNote = voiceType.startNote;
    for (var offset = 0; offset <= transpositionSteps; offset++) {
      final semitoneOffset = direction == WarmupDirection.up ? offset : -offset;
      final baseNote = startNote.transpose(semitoneOffset);
      final includesPattern = steps.length < 3;

      if (!_isBaseNoteAllowed(baseNote, voiceType) ||
          (includesPattern && !_doesPatternFit(baseNote, voiceType))) {
        onRangeClamp();
        break;
      }

      steps.add(
        WarmupStep(
          baseNote: baseNote,
          direction: direction,
          includesPattern: includesPattern,
          tonicChord: Chord(baseNote.note, ChordQuality.major),
          patternNotes: _patternIntervals
              .map(baseNote.transpose)
              .toList(growable: false),
        ),
      );
    }

    return steps;
  }

  bool _isBaseNoteAllowed(ScientificNote note, VoiceType voiceType) {
    return note.midi >= voiceType.minNote.midi &&
        note.midi <= voiceType.maxNote.midi;
  }

  bool _doesPatternFit(ScientificNote baseNote, VoiceType voiceType) {
    final topPatternNote = baseNote.transpose(
      _patternIntervals.reduce((a, b) => a > b ? a : b),
    );
    return topPatternNote.midi <= voiceType.maxNote.midi;
  }
}
