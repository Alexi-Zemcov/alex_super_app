import 'package:circle_of_fifths/src/core/audio/audio_playback_service.dart';
import 'package:circle_of_fifths/src/core/domain/usecase.dart';

/// Use case for setting the master volume.
class SetMasterVolumeUseCase implements UseCase<double, void> {
  final AudioPlaybackService _audioService;

  const SetMasterVolumeUseCase(this._audioService);

  @override
  void call(double params) {
    _audioService.setMasterVolume(params);
  }
}
