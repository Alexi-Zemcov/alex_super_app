import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:pitch_detection/pitch_detection.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class FakePitchDetectionPlatform extends PitchDetectionPlatform
    with MockPlatformInterfaceMixin {
  MicrophonePermissionStatus permissionStatus =
      MicrophonePermissionStatus.granted;
  Stream<PitchFrame> frameStream = const Stream<PitchFrame>.empty();
  PitchDetectionConfig? lastConfig;
  var startCallCount = 0;
  var stopCallCount = 0;

  @override
  Stream<PitchFrame> pitchFrames() => frameStream;

  @override
  Future<MicrophonePermissionStatus> requestMicrophonePermission() async {
    return permissionStatus;
  }

  @override
  Future<void> startDetection(PitchDetectionConfig config) async {
    lastConfig = config;
    startCallCount += 1;
  }

  @override
  Future<void> stop() async {
    stopCallCount += 1;
  }
}

void main() {
  group('PitchDetectionClient', () {
    test(
      'detectStablePitch aggregates stable note from native frames',
      () async {
        final platform = FakePitchDetectionPlatform()
          ..frameStream = Stream<PitchFrame>.fromIterable([
            _frame(82.0, amplitude: 0.02, confidence: 0.8),
            _frame(82.5, amplitude: 0.03, confidence: 0.82),
            _frame(81.9, amplitude: 0.025, confidence: 0.85),
            _frame(82.1, amplitude: 0.02, confidence: 0.78),
            _frame(82.2, amplitude: 0.03, confidence: 0.8),
          ]);
        final client = PitchDetectionClient(platform: platform);

        final result = await client.detectStablePitch();

        expect(platform.startCallCount, 1);
        expect(platform.stopCallCount, 1);
        expect(result.frequencyHz, closeTo(82.14, 0.2));
        expect(result.frameCount, 5);
      },
    );

    test('detectStablePitch times out when no stable pitch appears', () async {
      final controller = StreamController<PitchFrame>();
      final platform = FakePitchDetectionPlatform()
        ..frameStream = controller.stream;
      final client = PitchDetectionClient(platform: platform);

      expect(
        client.detectStablePitch(
          config: const PitchDetectionConfig(
            timeout: Duration(milliseconds: 20),
          ),
        ),
        throwsA(
          isA<PitchDetectionException>().having(
            (error) => error.code,
            'code',
            PitchDetectionErrorCode.noStablePitch,
          ),
        ),
      );

      await controller.close();
    });

    test('frames rejects concurrent sessions', () async {
      final controller = StreamController<PitchFrame>();
      final platform = FakePitchDetectionPlatform()
        ..frameStream = controller.stream;
      final client = PitchDetectionClient(platform: platform);

      final subscription = client.frames().listen((_) {});

      await expectLater(
        client.frames(),
        emitsError(
          isA<PitchDetectionException>().having(
            (error) => error.code,
            'code',
            PitchDetectionErrorCode.alreadyListening,
          ),
        ),
      );

      await subscription.cancel();
      await controller.close();
    });
  });
}

PitchFrame _frame(
  double frequencyHz, {
  double amplitude = 0.02,
  double confidence = 0.8,
  bool isPitched = true,
}) {
  return PitchFrame(
    frequencyHz: frequencyHz,
    amplitude: amplitude,
    confidence: confidence,
    isPitched: isPitched,
    timestamp: DateTime.fromMillisecondsSinceEpoch(1000),
  );
}
