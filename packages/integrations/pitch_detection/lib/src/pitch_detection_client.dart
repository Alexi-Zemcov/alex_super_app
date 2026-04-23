import 'dart:async';
import 'dart:math' as math;

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

  Future<MicrophonePermissionStatus> requestMicrophonePermission() {
    return _platform.requestMicrophonePermission();
  }

  Stream<PitchFrame> frames({
    PitchDetectionConfig config = const PitchDetectionConfig(),
  }) {
    if (_sessionActive) {
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
        _stopSession = null;
        _sessionActive = false;
        await rawSubscription?.cancel();
        await _platform.stop();
      }

      _sessionActive = true;
      _stopSession = cleanup;

      unawaited(() async {
        try {
          rawSubscription = _platform.pitchFrames().listen(
            controller.add,
            onError: controller.addError,
            onDone: controller.close,
          );
          await _platform.startDetection(config);
        } catch (error, stackTrace) {
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
      throw PitchDetectionException.alreadyListening();
    }

    final completer = Completer<StablePitchResult>();
    final window = <PitchFrame>[];
    late final StreamSubscription<PitchFrame> subscription;
    Timer? timeoutTimer;

    Future<void> finishWithResult(StablePitchResult result) async {
      timeoutTimer?.cancel();
      await subscription.cancel();
      if (!completer.isCompleted) {
        completer.complete(result);
      }
    }

    Future<void> finishWithError(Object error, [StackTrace? stackTrace]) async {
      timeoutTimer?.cancel();
      await subscription.cancel();
      if (!completer.isCompleted) {
        completer.completeError(error, stackTrace);
      }
    }

    timeoutTimer = Timer(config.timeout, () {
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
        unawaited(finishWithError(error, stackTrace));
      },
      onDone: () {
        if (!completer.isCompleted) {
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
}
