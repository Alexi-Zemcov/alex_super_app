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
    final status = await _client.requestMicrophonePermission();

    if (status.isGranted) {
      return;
    }

    if (status == MicrophonePermissionStatus.permanentlyDenied) {
      throw PitchDetectionException.permissionPermanentlyDenied();
    }

    throw PitchDetectionException.permissionDenied();
  }

  @override
  Stream<DetectedPitchSample> observeDetectedPitches(RangeDetectionTarget _) {
    return _client.frames().map((frame) {
      final note = frame.isPitched
          ? _nearestScientificNote(frame.frequencyHz)
          : null;
      return DetectedPitchSample(
        note: note,
        timestamp: frame.timestamp,
        isPitched: frame.isPitched,
      );
    });
  }

  @override
  Future<void> stopDetection() async {
    await _client.stop();
  }

  ScientificNote _nearestScientificNote(double frequencyHz) {
    final midi = (69 + 12 * (math.log(frequencyHz / 440) / math.ln2)).round();
    return ScientificNote.fromMidi(midi);
  }
}
