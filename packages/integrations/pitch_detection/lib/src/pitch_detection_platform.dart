import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'method_channel_pitch_detection_platform.dart';
import 'models/microphone_permission_status.dart';
import 'models/pitch_detection_config.dart';
import 'models/pitch_frame.dart';

abstract class PitchDetectionPlatform extends PlatformInterface {
  PitchDetectionPlatform() : super(token: _token);

  static final Object _token = Object();

  static PitchDetectionPlatform _instance =
      MethodChannelPitchDetectionPlatform();

  static PitchDetectionPlatform get instance => _instance;

  static set instance(PitchDetectionPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<MicrophonePermissionStatus> requestMicrophonePermission() {
    throw UnimplementedError(
      'requestMicrophonePermission() has not been implemented.',
    );
  }

  Stream<PitchFrame> pitchFrames() {
    throw UnimplementedError('pitchFrames() has not been implemented.');
  }

  Future<void> startDetection(PitchDetectionConfig config) {
    throw UnimplementedError('startDetection() has not been implemented.');
  }

  Future<void> stop() {
    throw UnimplementedError('stop() has not been implemented.');
  }
}
