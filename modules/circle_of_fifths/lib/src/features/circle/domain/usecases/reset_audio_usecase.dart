import 'package:circle_of_fifths/src/core/audio/audio_playback_service.dart';
import 'package:circle_of_fifths/src/core/domain/usecase.dart';

/// Use case for resetting audio state (unmute and stop all).
class ResetAudioUseCase implements NoParamsUseCase<void> {
  final AudioPlaybackService _audioService;

  const ResetAudioUseCase(this._audioService);

  @override
  void call() {
    _audioService.setMutedAndStopAll(false);
  }
}
