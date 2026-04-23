enum MicrophonePermissionStatus {
  granted,
  denied,
  permanentlyDenied;

  bool get isGranted => this == MicrophonePermissionStatus.granted;

  static MicrophonePermissionStatus fromValue(String value) {
    return switch (value) {
      'granted' => MicrophonePermissionStatus.granted,
      'permanentlyDenied' => MicrophonePermissionStatus.permanentlyDenied,
      _ => MicrophonePermissionStatus.denied,
    };
  }
}
