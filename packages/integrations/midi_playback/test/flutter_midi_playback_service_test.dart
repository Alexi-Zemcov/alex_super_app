import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:midi_playback/midi_playback.dart';
import 'package:music_theory/music_theory.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('reports unsupported availability on desktop platforms', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);

    final service = FlutterMidiPlaybackService();

    expect(service.availability, PlaybackAvailability.unsupported);
  });

  test(
    'keeps mute and volume state even when playback is unavailable',
    () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);

      final service = FlutterMidiPlaybackService();

      service.setMasterVolume(0.3);
      service.setMutedAndStopAll(true);

      expect(service.masterVolume, 0.3);
      expect(service.isMuted, isTrue);

      await service.initialize();
      await service.playNote(ScientificNote.parse('C4'));
      service.stopNote(ScientificNote.parse('C4'));
      await service.playChord(const Chord(Note.c, ChordQuality.major));
      service.stopChord(const Chord(Note.c, ChordQuality.major));
      await service.stopAll();
      await service.dispose();
    },
  );
}
