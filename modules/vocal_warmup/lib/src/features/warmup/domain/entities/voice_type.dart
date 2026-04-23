import 'package:music_theory/music_theory.dart';

enum VoiceType {
  bass('Bass'),
  baritone('Baritone'),
  tenor('Tenor'),
  alto('Alto'),
  mezzo('Mezzo'),
  soprano('Soprano');

  const VoiceType(this.displayName);

  final String displayName;

  ScientificNote get startNote => switch (this) {
    VoiceType.bass => ScientificNote.parse('G2'),
    VoiceType.baritone => ScientificNote.parse('C3'),
    VoiceType.tenor => ScientificNote.parse('G3'),
    VoiceType.alto => ScientificNote.parse('G3'),
    VoiceType.mezzo => ScientificNote.parse('C4'),
    VoiceType.soprano => ScientificNote.parse('G4'),
  };

  ScientificNote get minNote => switch (this) {
    VoiceType.bass => ScientificNote.parse('E2'),
    VoiceType.baritone => ScientificNote.parse('A2'),
    VoiceType.tenor => ScientificNote.parse('C3'),
    VoiceType.alto => ScientificNote.parse('F3'),
    VoiceType.mezzo => ScientificNote.parse('A3'),
    VoiceType.soprano => ScientificNote.parse('C4'),
  };

  ScientificNote get maxNote => switch (this) {
    VoiceType.bass => ScientificNote.parse('E4'),
    VoiceType.baritone => ScientificNote.parse('A4'),
    VoiceType.tenor => ScientificNote.parse('C5'),
    VoiceType.alto => ScientificNote.parse('F5'),
    VoiceType.mezzo => ScientificNote.parse('A5'),
    VoiceType.soprano => ScientificNote.parse('C6'),
  };
}
