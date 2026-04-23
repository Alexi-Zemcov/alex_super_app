import 'package:music_theory/music_theory.dart';

enum PlaybackAvailability {
  supported,
  unsupported;

  bool get isSupported => this == PlaybackAvailability.supported;
}

abstract interface class MidiPlaybackService {
  PlaybackAvailability get availability;

  bool get isMuted;

  double get masterVolume;

  Future<void> initialize();

  void setMutedAndStopAll(bool value);

  void setMasterVolume(double volume);

  Future<void> playNote(ScientificNote note);

  void stopNote(ScientificNote note);

  Future<void> playChord(Chord chord, {int octave = 4});

  void stopChord(Chord chord, {int octave = 4});

  Future<void> stopAll();

  Future<void> dispose();
}
