import 'package:circle_of_fifths/src/core/audio/audio_playback_service.dart';
import 'package:circle_of_fifths/src/core/domain/usecase.dart';
import 'package:circle_of_fifths/src/features/circle/domain/entities/chord.dart';

/// Use case for playing a chord.
class PlayChordUseCase implements AsyncUseCase<Chord, void> {
  final AudioPlaybackService _audioService;

  const PlayChordUseCase(this._audioService);

  @override
  Future<void> call(Chord params) async {
    await _audioService.playChord(params);
  }
}
