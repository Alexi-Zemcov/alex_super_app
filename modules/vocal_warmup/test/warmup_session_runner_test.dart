import 'package:flutter_test/flutter_test.dart';
import 'package:midi_playback/midi_playback.dart';
import 'package:music_theory/music_theory.dart';
import 'package:vocal_warmup/src/features/warmup/domain/entities/voice_type.dart';
import 'package:vocal_warmup/src/features/warmup/domain/entities/warmup_direction.dart';
import 'package:vocal_warmup/src/features/warmup/domain/entities/warmup_plan.dart';
import 'package:vocal_warmup/src/features/warmup/domain/entities/warmup_step.dart';
import 'package:vocal_warmup/src/features/warmup/domain/services/warmup_sequence_planner.dart';
import 'package:vocal_warmup/src/features/warmup/domain/services/warmup_session_runner.dart';

void main() {
  test('emits step updates and a finished event', () async {
    final playbackService = _FakeMidiPlaybackService();
    final runner = WarmupSessionRunner(playbackService);
    final planner = WarmupSequencePlanner();
    final events = <WarmupSessionEvent>[];
    final subscription = runner.events.listen(events.add);

    final plan = planner.plan(
      voiceType: VoiceType.baritone,
      stepsUp: 1,
      stepsDown: 0,
    );

    await runner.start(plan: plan, tempoBpm: 60000);
    await Future<void>.delayed(const Duration(milliseconds: 60));

    expect(events.whereType<WarmupSessionStepStarted>().length, 2);
    expect(events.whereType<WarmupSessionFinished>(), isNotEmpty);
    expect(playbackService.playedChords, isNotEmpty);

    await subscription.cancel();
    await runner.dispose();
  });

  test('supports pause, resume, and stop transitions', () async {
    final playbackService = _FakeMidiPlaybackService();
    final runner = WarmupSessionRunner(playbackService);
    final planner = WarmupSequencePlanner();

    final plan = planner.plan(
      voiceType: VoiceType.mezzo,
      stepsUp: 1,
      stepsDown: 1,
    );

    await runner.start(plan: plan, tempoBpm: 60);
    await Future<void>.delayed(const Duration(milliseconds: 10));

    runner.pause();
    expect(runner.isPaused, isTrue);

    runner.resume();
    expect(runner.isPaused, isFalse);

    await runner.stop();
    expect(runner.isRunning, isFalse);
    expect(playbackService.stopAllCalls, greaterThan(0));
  });

  test('waits for cleanup before playing the next phase', () async {
    final playbackService = _SequencedMidiPlaybackService();
    final runner = WarmupSessionRunner(playbackService);
    final plan = WarmupPlan(
      steps: [
        WarmupStep(
          baseNote: ScientificNote.parse('C4'),
          direction: WarmupDirection.up,
          tonicChord: const Chord(Note.c, ChordQuality.major),
          patternNotes: [ScientificNote.parse('C4')],
        ),
      ],
      isRangeClamped: false,
    );

    await runner.start(plan: plan, tempoBpm: 60000);
    await Future<void>.delayed(const Duration(milliseconds: 30));

    expect(playbackService.log.take(3), [
      'phase-stop-start',
      'phase-stop-end',
      'play-chord',
    ]);

    await runner.dispose();
  });
}

class _FakeMidiPlaybackService implements MidiPlaybackService {
  @override
  PlaybackAvailability get availability => PlaybackAvailability.supported;

  @override
  bool get isMuted => false;

  @override
  double get masterVolume => 0.7;

  final List<Chord> playedChords = [];
  final List<ScientificNote> playedNotes = [];
  int stopAllCalls = 0;

  @override
  Future<void> dispose() async {}

  @override
  Future<void> initialize() async {}

  @override
  Future<void> playChord(Chord chord, {int octave = 4}) async {
    playedChords.add(chord);
  }

  @override
  Future<void> playNote(ScientificNote note) async {
    playedNotes.add(note);
  }

  @override
  void setMasterVolume(double volume) {}

  @override
  void setMutedAndStopAll(bool value) {}

  @override
  Future<void> stopAll() async {
    stopAllCalls += 1;
  }

  @override
  void stopChord(Chord chord, {int octave = 4}) {}

  @override
  void stopNote(ScientificNote note) {}
}

class _SequencedMidiPlaybackService extends _FakeMidiPlaybackService {
  final List<String> log = [];
  int _stopAllCalls = 0;

  @override
  Future<void> playChord(Chord chord, {int octave = 4}) async {
    log.add('play-chord');
  }

  @override
  Future<void> playNote(ScientificNote note) async {
    log.add('play-note');
  }

  @override
  Future<void> stopAll() async {
    _stopAllCalls += 1;
    if (_stopAllCalls == 1) {
      return;
    }

    log.add('phase-stop-start');
    await Future<void>.delayed(const Duration(milliseconds: 10));
    log.add('phase-stop-end');
  }
}
