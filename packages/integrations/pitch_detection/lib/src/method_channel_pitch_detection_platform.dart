import 'package:flutter/services.dart';

import 'models/microphone_permission_status.dart';
import 'models/pitch_detection_config.dart';
import 'models/pitch_detection_exception.dart';
import 'models/pitch_frame.dart';
import 'pitch_detection_platform.dart';

class MethodChannelPitchDetectionPlatform extends PitchDetectionPlatform {
  static const MethodChannel methodChannel = MethodChannel(
    'com.alexsuperapp/pitch_detection/methods',
  );
  static const EventChannel eventChannel = EventChannel(
    'com.alexsuperapp/pitch_detection/frames',
  );

  @override
  Future<MicrophonePermissionStatus> requestMicrophonePermission() async {
    try {
      final value = await methodChannel.invokeMethod<String>(
        'requestMicrophonePermission',
      );
      return MicrophonePermissionStatus.fromValue(value ?? 'denied');
    } on PlatformException catch (error) {
      throw _mapPlatformException(error);
    }
  }

  @override
  Stream<PitchFrame> pitchFrames() {
    return eventChannel
        .receiveBroadcastStream()
        .map((event) => PitchFrame.fromMap(event as Map<Object?, Object?>))
        .handleError((Object error) {
          if (error is PlatformException) {
            throw _mapPlatformException(error);
          }
          throw error;
        });
  }

  @override
  Future<void> startDetection(PitchDetectionConfig config) async {
    try {
      await methodChannel.invokeMethod<void>('startDetection', config.toMap());
    } on PlatformException catch (error) {
      throw _mapPlatformException(error);
    }
  }

  @override
  Future<void> stop() async {
    try {
      await methodChannel.invokeMethod<void>('stop');
    } on PlatformException catch (error) {
      throw _mapPlatformException(error);
    }
  }

  PitchDetectionException _mapPlatformException(PlatformException error) {
    final code = PitchDetectionErrorCode.fromValue(error.code);
    return switch (code) {
      PitchDetectionErrorCode.permissionDenied =>
        PitchDetectionException.permissionDenied(error.message),
      PitchDetectionErrorCode.permissionPermanentlyDenied =>
        PitchDetectionException.permissionPermanentlyDenied(error.message),
      PitchDetectionErrorCode.noStablePitch =>
        PitchDetectionException.noStablePitch(error.message),
      PitchDetectionErrorCode.unsupportedPlatform =>
        PitchDetectionException.unsupportedPlatform(error.message),
      PitchDetectionErrorCode.alreadyListening =>
        PitchDetectionException.alreadyListening(error.message),
      PitchDetectionErrorCode.nativeFailure =>
        PitchDetectionException.nativeFailure(error.message, error.details),
    };
  }
}
