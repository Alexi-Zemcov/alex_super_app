import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:music_theory/music_theory.dart';
import 'package:pitch_detection/pitch_detection.dart';
import 'package:vocal_warmup/src/features/range_detection/domain/entities/detected_pitch_sample.dart';
import 'package:vocal_warmup/src/features/range_detection/domain/entities/range_detection_target.dart';
import 'package:vocal_warmup/src/features/range_detection/domain/services/pitch_detection_service.dart';

class NativeVocalPitchDetectionService implements PitchDetectionService {
  NativeVocalPitchDetectionService({PitchDetectionClient? client})
    : _client = client ?? PitchDetectionClient();

  final PitchDetectionClient _client;

  static bool get isSupportedPlatform {
    if (kIsWeb) {
      return false;
    }

    return switch (defaultTargetPlatform) {
      TargetPlatform.android || TargetPlatform.iOS => true,
      _ => false,
    };
  }

  @override
  Future<void> prepareDetection() async {
    _log('prepareDetection');
    final status = await _client.requestMicrophonePermission();
    _log('prepareDetection permissionStatus=$status');

    if (status.isGranted) {
      return;
    }

    if (status == MicrophonePermissionStatus.permanentlyDenied) {
      throw PitchDetectionException.permissionPermanentlyDenied();
    }

    throw PitchDetectionException.permissionDenied();
  }

  @override
  Stream<DetectedPitchSample> observeDetectedPitches(
    RangeDetectionTarget target,
  ) {
    _log('observeDetectedPitches target=$target');
    var sampleLogCount = 0;

    return _client.frames().map((frame) {
      final note = frame.isPitched
          ? _nearestScientificNote(frame.frequencyHz)
          : null;
      if (sampleLogCount < 10 || sampleLogCount % 30 == 0) {
        _log(
          'sample[$sampleLogCount] target=$target pitched=${frame.isPitched} freq=${frame.frequencyHz.toStringAsFixed(2)}Hz note=${note?.label() ?? '-'}',
        );
      }
      sampleLogCount += 1;
      return DetectedPitchSample(
        note: note,
        timestamp: frame.timestamp,
        isPitched: frame.isPitched,
      );
    });
  }

  @override
  Future<void> stopDetection() async {
    _log('stopDetection');
    await _client.stop();
  }

  ScientificNote _nearestScientificNote(double frequencyHz) {
    final midi = (69 + 12 * (math.log(frequencyHz / 440) / math.ln2)).round();
    return ScientificNote.fromMidi(midi);
  }

  void _log(String message) {
    debugPrint('[VocalWarmup][NativePitchDetectionService] $message');
  }
}
