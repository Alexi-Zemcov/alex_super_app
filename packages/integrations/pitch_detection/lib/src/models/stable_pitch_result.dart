class StablePitchResult {
  const StablePitchResult({
    required this.frequencyHz,
    required this.amplitude,
    required this.confidence,
    required this.frameCount,
  });

  final double frequencyHz;
  final double amplitude;
  final double confidence;
  final int frameCount;
}
