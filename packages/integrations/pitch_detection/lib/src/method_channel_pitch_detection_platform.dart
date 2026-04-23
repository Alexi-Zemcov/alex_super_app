import 'package:flutter/foundation.dart';
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
    _log('invoke requestMicrophonePermission');
    try {
      final value = await methodChannel.invokeMethod<String>(
        'requestMicrophonePermission',
      );
      final status = MicrophonePermissionStatus.fromValue(value ?? 'denied');
      _log('requestMicrophonePermission -> $status');
      return status;
    } on PlatformException catch (error) {
      _log(
        'requestMicrophonePermission platform error: ${error.code} ${error.message}',
      );
      throw _mapPlatformException(error);
    }
  }

  @override
  Stream<PitchFrame> pitchFrames() {
    _log('subscribe pitchFrames');
    var frameLogCount = 0;
    return eventChannel
        .receiveBroadcastStream()
        .map((event) {
          final frame = PitchFrame.fromMap(event as Map<Object?, Object?>);
          if (frameLogCount < 5 || frameLogCount % 25 == 0) {
            _log(
              'native frame[$frameLogCount] pitched=${frame.isPitched} freq=${frame.frequencyHz.toStringAsFixed(2)} amp=${frame.amplitude.toStringAsFixed(3)} conf=${frame.confidence.toStringAsFixed(3)}',
            );
          }
          frameLogCount += 1;
          return frame;
        })
        .handleError((Object error) {
          _log('pitchFrames error: $error');
          if (error is PlatformException) {
            throw _mapPlatformException(error);
          }
          throw error;
        });
  }

  @override
  Future<void> startDetection(PitchDetectionConfig config) async {
    _log('invoke startDetection config=${config.toMap()}');
    try {
      await methodChannel.invokeMethod<void>('startDetection', config.toMap());
      _log('startDetection completed');
    } on PlatformException catch (error) {
      _log('startDetection platform error: ${error.code} ${error.message}');
      throw _mapPlatformException(error);
    }
  }

  @override
  Future<void> stop() async {
    _log('invoke stop');
    try {
      await methodChannel.invokeMethod<void>('stop');
      _log('stop completed');
    } on PlatformException catch (error) {
      _log('stop platform error: ${error.code} ${error.message}');
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

  void _log(String message) {
    debugPrint('[PitchDetection][Platform] $message');
  }
}
