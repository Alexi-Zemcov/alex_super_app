class PitchFrame {
  const PitchFrame({
    required this.frequencyHz,
    required this.amplitude,
    required this.confidence,
    required this.isPitched,
    required this.timestamp,
  });

  factory PitchFrame.fromMap(Map<Object?, Object?> map) {
    return PitchFrame(
      frequencyHz: (map['frequencyHz'] as num?)?.toDouble() ?? 0,
      amplitude: (map['amplitude'] as num?)?.toDouble() ?? 0,
      confidence: (map['confidence'] as num?)?.toDouble() ?? 0,
      isPitched: map['isPitched'] as bool? ?? false,
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        (map['timestampMillis'] as num?)?.toInt() ?? 0,
      ),
    );
  }

  final double frequencyHz;
  final double amplitude;
  final double confidence;
  final bool isPitched;
  final DateTime timestamp;
}
