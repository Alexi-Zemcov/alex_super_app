import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:music_theory/music_theory.dart';
import 'package:pitch_detection/pitch_detection.dart';
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
  Future<ScientificNote> detectStableNote(RangeDetectionTarget target) async {
    final result = await _client.detectStablePitch();
    return _nearestScientificNote(result.frequencyHz);
  }

  ScientificNote _nearestScientificNote(double frequencyHz) {
    final midi = (69 + 12 * (math.log(frequencyHz / 440) / math.ln2)).round();
    return ScientificNote.fromMidi(midi);
  }
}
