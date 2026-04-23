import AVFoundation
import AudioKit
import Flutter
import SoundpipeAudioKit

public final class PitchDetectionPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
  private var eventSink: FlutterEventSink?
  private var audioEngine: AudioEngine?
  private var silentOutput: Mixer?
  private var pitchTap: PitchTap?
  private var emittedFrameCount = 0

  public static func register(with registrar: FlutterPluginRegistrar) {
    let methodChannel = FlutterMethodChannel(
      name: "com.alexsuperapp/pitch_detection/methods",
      binaryMessenger: registrar.messenger()
    )
    let eventChannel = FlutterEventChannel(
      name: "com.alexsuperapp/pitch_detection/frames",
      binaryMessenger: registrar.messenger()
    )

    let instance = PitchDetectionPlugin()
    instance.log("register")
    registrar.addMethodCallDelegate(instance, channel: methodChannel)
    eventChannel.setStreamHandler(instance)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    log("handle method=\(call.method)")
    switch call.method {
    case "requestMicrophonePermission":
      requestMicrophonePermission(result: result)
    case "startDetection":
      guard let config = DetectionConfig(arguments: call.arguments) else {
        result(FlutterError(code: "nativeFailure", message: "Invalid detection config.", details: nil))
        return
      }
      startDetection(config: config, result: result)
    case "stop":
      stopDetection()
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    log("onListen")
    eventSink = events
    return nil
  }

  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    log("onCancel")
    eventSink = nil
    stopDetection()
    return nil
  }

  private func requestMicrophonePermission(result: @escaping FlutterResult) {
    let permission = AVAudioSession.sharedInstance().recordPermission
    log("requestMicrophonePermission current=\(permission.rawValue)")
    switch permission {
    case .granted:
      result("granted")
    case .denied:
      result("permanentlyDenied")
    case .undetermined:
      log("requestMicrophonePermission launching system dialog")
      AVAudioSession.sharedInstance().requestRecordPermission { granted in
        self.log("requestMicrophonePermission completion granted=\(granted)")
        result(granted ? "granted" : "denied")
      }
    @unknown default:
      result("denied")
    }
  }

  private func startDetection(config: DetectionConfig, result: @escaping FlutterResult) {
    log(
      "startDetection sampleRate=\(config.sampleRate) bufferSize=\(config.bufferSize) permission=\(AVAudioSession.sharedInstance().recordPermission.rawValue) sink=\(eventSink != nil)"
    )
    guard eventSink != nil else {
      log("startDetection aborted: missing event sink")
      result(FlutterError(code: "nativeFailure", message: "Pitch frame listener is not attached.", details: nil))
      return
    }
    guard pitchTap == nil else {
      log("startDetection aborted: already listening")
      result(FlutterError(code: "alreadyListening", message: "Pitch detection session is already active.", details: nil))
      return
    }
    guard AVAudioSession.sharedInstance().recordPermission == .granted else {
      log("startDetection aborted: permission denied")
      result(FlutterError(code: "permissionDenied", message: "Microphone permission denied.", details: nil))
      return
    }

    do {
      let session = AVAudioSession.sharedInstance()
      try session.setCategory(.playAndRecord, mode: .measurement, options: [.defaultToSpeaker, .mixWithOthers])
      try session.setPreferredSampleRate(Double(config.sampleRate))
      try session.setActive(true)
      log("audio session activated sampleRate=\(session.sampleRate)")

      let engine = AudioEngine()
      guard let input = engine.input else {
        log("startDetection aborted: engine input unavailable")
        result(FlutterError(code: "unsupportedPlatform", message: "Audio input is unavailable.", details: nil))
        return
      }

      let silent = Mixer(input)
      silent.volume = 0
      engine.output = silent

      let tap = PitchTap(input, bufferSize: config.bufferSize) { [weak self] pitches, amplitudes in
        self?.emitFrames(pitches: pitches, amplitudes: amplitudes, config: config)
      }

      audioEngine = engine
      silentOutput = silent
      pitchTap = tap
      emittedFrameCount = 0

      try engine.start()
      tap.start()
      log("startDetection accepted")
      result(nil)
    } catch {
      log("startDetection failed: \(error.localizedDescription)")
      stopDetection()
      result(FlutterError(code: "nativeFailure", message: error.localizedDescription, details: nil))
    }
  }

  private func emitFrames(pitches: [Float], amplitudes: [Float], config: DetectionConfig) {
    guard let sink = eventSink else { return }

    for index in 0 ..< min(pitches.count, amplitudes.count) {
      let frequency = Double(pitches[index])
      let amplitude = Double(amplitudes[index])
      let confidence = frequency > 0 ? 1.0 : 0.0
      let isPitched =
        frequency >= config.minFrequencyHz &&
        frequency <= config.maxFrequencyHz &&
        amplitude >= config.minAmplitude &&
        confidence >= config.minConfidence

      if emittedFrameCount < 5 || emittedFrameCount % 25 == 0 {
        log(
          "emitFrame[\(emittedFrameCount)] pitched=\(isPitched) freq=\(frequency) amp=\(amplitude) conf=\(confidence)"
        )
      }
      emittedFrameCount += 1

      sink([
        "frequencyHz": frequency,
        "amplitude": amplitude,
        "confidence": confidence,
        "isPitched": isPitched,
        "timestampMillis": Int(Date().timeIntervalSince1970 * 1000),
      ])
    }
  }

  private func stopDetection() {
    log("stopDetection")
    pitchTap?.stop()
    pitchTap = nil
    audioEngine?.stop()
    audioEngine = nil
    silentOutput = nil
    try? AVAudioSession.sharedInstance().setActive(false)
  }

  private func log(_ message: String) {
    NSLog("[PitchDetectionPlugin][iOS] %@", message)
  }
}

private struct DetectionConfig {
  init?(arguments: Any?) {
    guard let map = arguments as? [String: Any] else {
      return nil
    }

    sampleRate = (map["sampleRate"] as? NSNumber)?.intValue ?? 44_100
    bufferSize = (map["bufferSize"] as? NSNumber)?.uint32Value ?? 4_096
    minFrequencyHz = (map["minFrequencyHz"] as? NSNumber)?.doubleValue ?? 70
    maxFrequencyHz = (map["maxFrequencyHz"] as? NSNumber)?.doubleValue ?? 1_100
    minAmplitude = (map["minAmplitude"] as? NSNumber)?.doubleValue ?? 0.01
    minConfidence = (map["minConfidence"] as? NSNumber)?.doubleValue ?? 0.75
  }

  let sampleRate: Int
  let bufferSize: UInt32
  let minFrequencyHz: Double
  let maxFrequencyHz: Double
  let minAmplitude: Double
  let minConfidence: Double
}
