import 'package:circle_of_fifths/src/features/circle/domain/entities/chord.dart';

abstract interface class AudioPlaybackService {
  bool get isMuted;

  double get masterVolume;

  Future<void> initialize();

  void setMutedAndStopAll(bool value);

  void setMasterVolume(double volume);

  Future<void> playChord(Chord chord);

  void stopChord(Chord chord);

  Future<void> stopAll();

  Future<void> dispose();
}
