enum PitchDetectionErrorCode {
  permissionDenied('permissionDenied'),
  permissionPermanentlyDenied('permissionPermanentlyDenied'),
  noStablePitch('noStablePitch'),
  unsupportedPlatform('unsupportedPlatform'),
  alreadyListening('alreadyListening'),
  nativeFailure('nativeFailure');

  const PitchDetectionErrorCode(this.value);

  final String value;

  static PitchDetectionErrorCode fromValue(String value) {
    return PitchDetectionErrorCode.values.firstWhere(
      (code) => code.value == value,
      orElse: () => PitchDetectionErrorCode.nativeFailure,
    );
  }
}

class PitchDetectionException implements Exception {
  const PitchDetectionException({
    required this.code,
    required this.message,
    this.details,
  });

  final PitchDetectionErrorCode code;
  final String message;
  final Object? details;

  factory PitchDetectionException.permissionDenied([String? message]) {
    return PitchDetectionException(
      code: PitchDetectionErrorCode.permissionDenied,
      message: message ?? 'Microphone permission denied.',
    );
  }

  factory PitchDetectionException.permissionPermanentlyDenied([
    String? message,
  ]) {
    return PitchDetectionException(
      code: PitchDetectionErrorCode.permissionPermanentlyDenied,
      message: message ?? 'Microphone permission permanently denied.',
    );
  }

  factory PitchDetectionException.noStablePitch([String? message]) {
    return PitchDetectionException(
      code: PitchDetectionErrorCode.noStablePitch,
      message: message ?? 'No stable pitch detected.',
    );
  }

  factory PitchDetectionException.unsupportedPlatform([String? message]) {
    return PitchDetectionException(
      code: PitchDetectionErrorCode.unsupportedPlatform,
      message: message ?? 'Pitch detection is not supported on this platform.',
    );
  }

  factory PitchDetectionException.alreadyListening([String? message]) {
    return PitchDetectionException(
      code: PitchDetectionErrorCode.alreadyListening,
      message: message ?? 'Pitch detection session is already active.',
    );
  }

  factory PitchDetectionException.nativeFailure([
    String? message,
    Object? details,
  ]) {
    return PitchDetectionException(
      code: PitchDetectionErrorCode.nativeFailure,
      message: message ?? 'Native pitch detection failed.',
      details: details,
    );
  }

  @override
  String toString() => 'PitchDetectionException(${code.value}, $message)';
}
