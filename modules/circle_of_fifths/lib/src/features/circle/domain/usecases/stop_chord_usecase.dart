import 'package:circle_of_fifths/src/core/audio/audio_playback_service.dart';
import 'package:circle_of_fifths/src/core/domain/usecase.dart';
import 'package:circle_of_fifths/src/features/circle/domain/entities/chord.dart';

/// Use case for stopping a chord.
class StopChordUseCase implements UseCase<Chord, void> {
  final AudioPlaybackService _audioService;

  const StopChordUseCase(this._audioService);

  @override
  void call(Chord params) {
    _audioService.stopChord(params);
  }
}
