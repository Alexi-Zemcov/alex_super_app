import 'package:circle_of_fifths/src/core/audio/audio_playback_service.dart';
import 'package:circle_of_fifths/src/core/domain/usecase.dart';

/// Use case for toggling the mute state.
class ToggleMuteUseCase implements UseCase<bool, void> {
  final AudioPlaybackService _audioService;

  const ToggleMuteUseCase(this._audioService);

  @override
  void call(bool params) {
    _audioService.setMutedAndStopAll(params);
  }
}
