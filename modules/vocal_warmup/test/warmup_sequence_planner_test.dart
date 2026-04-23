import 'package:flutter_test/flutter_test.dart';
import 'package:music_theory/music_theory.dart';
import 'package:vocal_warmup/src/features/warmup/domain/entities/voice_type.dart';
import 'package:vocal_warmup/src/features/warmup/domain/entities/warmup_direction.dart';
import 'package:vocal_warmup/src/features/warmup/domain/services/warmup_sequence_planner.dart';

void main() {
  final planner = WarmupSequencePlanner();

  test('builds an up-reset-down route from the selected start note', () {
    final plan = planner.plan(
      voiceType: VoiceType.baritone,
      stepsUp: 2,
      stepsDown: 2,
    );

    expect(plan.steps.map((step) => step.baseNote).toList(), [
      ScientificNote.parse('C3'),
      ScientificNote.parse('C#3'),
      ScientificNote.parse('D3'),
      ScientificNote.parse('C3'),
      ScientificNote.parse('B2'),
      ScientificNote.parse('A#2'),
    ]);
    expect(
      plan.steps.take(3).every((step) => step.direction == WarmupDirection.up),
      isTrue,
    );
    expect(
      plan.steps
          .skip(3)
          .every((step) => step.direction == WarmupDirection.down),
      isTrue,
    );
  });

  test('adds pattern notes to every step in each direction', () {
    final plan = planner.plan(
      voiceType: VoiceType.tenor,
      stepsUp: 4,
      stepsDown: 4,
    );

    expect(plan.steps, hasLength(10));
    expect(plan.steps.every((step) => step.patternNotes.length == 5), isTrue);
    expect(plan.steps.every((step) => step.phases.length == 6), isTrue);
  });

  test('clamps the route when the requested range exceeds the preset', () {
    final plan = planner.plan(
      voiceType: VoiceType.bass,
      stepsUp: 24,
      stepsDown: 0,
    );

    expect(plan.isRangeClamped, isTrue);
    expect(plan.steps.last.baseNote, ScientificNote.parse('C4'));
  });
}
