class PitchDetectionConfig {
  const PitchDetectionConfig({
    this.sampleRate = 44100,
    this.bufferSize = 4096,
    this.bufferOverlap = 2048,
    this.minFrequencyHz = 70,
    this.maxFrequencyHz = 1100,
    this.minAmplitude = 0.01,
    this.minConfidence = 0.75,
    this.timeout = const Duration(seconds: 8),
  });

  final int sampleRate;
  final int bufferSize;
  final int bufferOverlap;
  final double minFrequencyHz;
  final double maxFrequencyHz;
  final double minAmplitude;
  final double minConfidence;
  final Duration timeout;

  Map<String, Object> toMap() {
    return <String, Object>{
      'sampleRate': sampleRate,
      'bufferSize': bufferSize,
      'bufferOverlap': bufferOverlap,
      'minFrequencyHz': minFrequencyHz,
      'maxFrequencyHz': maxFrequencyHz,
      'minAmplitude': minAmplitude,
      'minConfidence': minConfidence,
      'timeoutMillis': timeout.inMilliseconds,
    };
  }
}
