import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import 'models/microphone_permission_status.dart';
import 'models/pitch_detection_config.dart';
import 'models/pitch_detection_exception.dart';
import 'models/pitch_frame.dart';
import 'models/stable_pitch_result.dart';
import 'pitch_detection_platform.dart';

class PitchDetectionClient {
  PitchDetectionClient({PitchDetectionPlatform? platform})
    : _platform = platform ?? PitchDetectionPlatform.instance;

  final PitchDetectionPlatform _platform;

  bool _sessionActive = false;
  Future<void> Function()? _stopSession;

  Future<MicrophonePermissionStatus> requestMicrophonePermission() async {
    _log('requestMicrophonePermission');
    final status = await _platform.requestMicrophonePermission();
    _log('requestMicrophonePermission -> $status');
    return status;
  }

  Stream<PitchFrame> frames({
    PitchDetectionConfig config = const PitchDetectionConfig(),
  }) {
    if (_sessionActive) {
      _log('frames rejected: session already active');
      return Stream<PitchFrame>.error(
        PitchDetectionException.alreadyListening(),
      );
    }

    return Stream<PitchFrame>.multi((controller) {
      StreamSubscription<PitchFrame>? rawSubscription;
      var cleanedUp = false;

      Future<void> cleanup() async {
        if (cleanedUp) {
          return;
        }
        cleanedUp = true;
        _log('frames cleanup');
        _stopSession = null;
        _sessionActive = false;
        await rawSubscription?.cancel();
        await _platform.stop();
      }

      _sessionActive = true;
      _stopSession = cleanup;
      _log('frames start config=${config.toMap()}');
      var frameLogCount = 0;

      unawaited(() async {
        try {
          rawSubscription = _platform.pitchFrames().listen(
            (frame) {
              if (frameLogCount < 5 || frameLogCount % 25 == 0) {
                _log(
                  'frame[$frameLogCount] pitched=${frame.isPitched} freq=${frame.frequencyHz.toStringAsFixed(2)} amp=${frame.amplitude.toStringAsFixed(3)} conf=${frame.confidence.toStringAsFixed(3)}',
                );
              }
              frameLogCount += 1;
              controller.add(frame);
            },
            onError: controller.addError,
            onDone: controller.close,
          );
          await _platform.startDetection(config);
          _log('platform.startDetection completed');
        } catch (error, stackTrace) {
          _log('frames startup failed: $error');
          await cleanup();
          controller.addError(error, stackTrace);
          await controller.close();
        }
      }());

      controller.onCancel = cleanup;
    });
  }

  Future<StablePitchResult> detectStablePitch({
    PitchDetectionConfig config = const PitchDetectionConfig(),
  }) async {
    if (_sessionActive) {
      _log('detectStablePitch rejected: session already active');
      throw PitchDetectionException.alreadyListening();
    }

    _log('detectStablePitch start config=${config.toMap()}');
    final completer = Completer<StablePitchResult>();
    final window = <PitchFrame>[];
    late final StreamSubscription<PitchFrame> subscription;
    Timer? timeoutTimer;

    Future<void> finishWithResult(StablePitchResult result) async {
      _log(
        'detectStablePitch success frequency=${result.frequencyHz.toStringAsFixed(2)} amp=${result.amplitude.toStringAsFixed(3)} conf=${result.confidence.toStringAsFixed(3)} frames=${result.frameCount}',
      );
      timeoutTimer?.cancel();
      await subscription.cancel();
      if (!completer.isCompleted) {
        completer.complete(result);
      }
    }

    Future<void> finishWithError(Object error, [StackTrace? stackTrace]) async {
      _log('detectStablePitch error: $error');
      timeoutTimer?.cancel();
      await subscription.cancel();
      if (!completer.isCompleted) {
        completer.completeError(error, stackTrace);
      }
    }

    timeoutTimer = Timer(config.timeout, () {
      _log(
        'detectStablePitch timeout after ${config.timeout.inMilliseconds}ms',
      );
      unawaited(finishWithError(PitchDetectionException.noStablePitch()));
    });

    subscription = frames(config: config).listen(
      (frame) {
        if (!frame.isPitched) {
          return;
        }

        window.add(frame);
        if (window.length > 5) {
          window.removeAt(0);
        }
        if (window.length < 5) {
          return;
        }

        final buckets = <int, List<PitchFrame>>{};
        for (final current in window) {
          final midi = _frequencyToNearestMidi(current.frequencyHz);
          buckets.putIfAbsent(midi, () => <PitchFrame>[]).add(current);
        }

        final stableEntry = buckets.entries
            .where((entry) => entry.value.length >= 4)
            .fold<MapEntry<int, List<PitchFrame>>?>(
              null,
              (selected, candidate) =>
                  selected == null ||
                      candidate.value.length > selected.value.length
                  ? candidate
                  : selected,
            );

        if (stableEntry == null) {
          return;
        }

        final stableFrames = stableEntry.value;
        _log(
          'stable window hit midi=${stableEntry.key} matches=${stableFrames.length} window=${window.length}',
        );
        final frequencyHz =
            stableFrames
                .map((frame) => frame.frequencyHz)
                .reduce((a, b) => a + b) /
            stableFrames.length;
        final amplitude =
            stableFrames
                .map((frame) => frame.amplitude)
                .reduce((a, b) => a + b) /
            stableFrames.length;
        final confidence =
            stableFrames
                .map((frame) => frame.confidence)
                .reduce((a, b) => a + b) /
            stableFrames.length;

        unawaited(
          finishWithResult(
            StablePitchResult(
              frequencyHz: frequencyHz,
              amplitude: amplitude,
              confidence: confidence,
              frameCount: stableFrames.length,
            ),
          ),
        );
      },
      onError: (error, stackTrace) {
        _log('frames stream error while detecting: $error');
        unawaited(finishWithError(error, stackTrace));
      },
      onDone: () {
        if (!completer.isCompleted) {
          _log('frames stream closed before stable pitch');
          unawaited(finishWithError(PitchDetectionException.noStablePitch()));
        }
      },
    );

    try {
      return await completer.future;
    } finally {
      timeoutTimer.cancel();
    }
  }

  Future<void> stop() async {
    _log('stop requested');
    final stopSession = _stopSession;
    if (stopSession != null) {
      await stopSession();
      return;
    }
    await _platform.stop();
  }

  int _frequencyToNearestMidi(double frequencyHz) {
    if (frequencyHz <= 0) {
      return 0;
    }
    return (69 + 12 * (math.log(frequencyHz / 440) / math.ln2)).round();
  }

  void _log(String message) {
    debugPrint('[PitchDetection][Client] $message');
  }
}
