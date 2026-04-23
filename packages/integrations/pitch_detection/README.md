# pitch_detection

Shared Flutter plugin for real-time microphone pitch detection.

## API

- `PitchDetectionClient.requestMicrophonePermission()`
- `PitchDetectionClient.frames()`
- `PitchDetectionClient.detectStablePitch()`
- `PitchDetectionClient.stop()`

`detectStablePitch()` is implemented in Dart on top of native pitch frames. A
note is treated as stable when the same nearest MIDI note appears in at least 4
of the last 5 pitched frames.

## Native backends

- Android: `AudioRecord` + TarsosDSP YIN pitch detector
- iOS: AudioKit + SoundpipeAudioKit `PitchTap`

## iOS integration

The package is configured for Flutter Swift Package Manager integration:

```yaml
flutter:
  config:
    enable-swift-package-manager: true
```

Host apps also need `NSMicrophoneUsageDescription` in `Info.plist`.
