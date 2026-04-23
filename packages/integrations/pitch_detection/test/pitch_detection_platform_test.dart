import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pitch_detection/pitch_detection.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const methodChannel = MethodChannel(
    'com.alexsuperapp/pitch_detection/methods',
  );
  const eventChannel = EventChannel('com.alexsuperapp/pitch_detection/frames');
  final platform = MethodChannelPitchDetectionPlatform();

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(methodChannel, (call) async {
          switch (call.method) {
            case 'requestMicrophonePermission':
              return 'granted';
            case 'startDetection':
              return null;
            case 'stop':
              return null;
          }
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(methodChannel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockStreamHandler(eventChannel, null);
  });

  test('requestMicrophonePermission maps native status', () async {
    final status = await platform.requestMicrophonePermission();
    expect(status, MicrophonePermissionStatus.granted);
  });

  test('startDetection serializes config values', () async {
    MethodCall? capturedCall;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(methodChannel, (call) async {
          capturedCall = call;
          return null;
        });

    await platform.startDetection(const PitchDetectionConfig());

    expect(capturedCall?.method, 'startDetection');
    expect(capturedCall?.arguments, <String, Object>{
      'sampleRate': 44100,
      'bufferSize': 4096,
      'bufferOverlap': 2048,
      'minFrequencyHz': 70.0,
      'maxFrequencyHz': 1100.0,
      'minAmplitude': 0.01,
      'minConfidence': 0.75,
      'timeoutMillis': 8000,
    });
  });

  test('pitchFrames decodes stream events', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockStreamHandler(
          eventChannel,
          MockStreamHandler.inline(
            onListen: (_, events) async {
              events.success(<String, Object>{
                'frequencyHz': 523.2,
                'amplitude': 0.04,
                'confidence': 0.91,
                'isPitched': true,
                'timestampMillis': 1200,
              });
            },
          ),
        );

    final frame = await platform.pitchFrames().first;

    expect(frame.frequencyHz, 523.2);
    expect(frame.amplitude, 0.04);
    expect(frame.confidence, 0.91);
    expect(frame.isPitched, isTrue);
    expect(frame.timestamp.millisecondsSinceEpoch, 1200);
  });

  test('platform errors map to typed exceptions', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(methodChannel, (call) async {
          throw PlatformException(
            code: 'permissionDenied',
            message: 'Microphone permission denied.',
          );
        });

    expect(
      platform.requestMicrophonePermission(),
      throwsA(
        isA<PitchDetectionException>().having(
          (error) => error.code,
          'code',
          PitchDetectionErrorCode.permissionDenied,
        ),
      ),
    );
  });
}
