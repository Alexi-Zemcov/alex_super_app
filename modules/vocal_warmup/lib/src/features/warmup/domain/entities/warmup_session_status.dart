enum WarmupSessionStatus {
  idle('Idle'),
  playing('Playing'),
  paused('Paused'),
  finished('Finished');

  const WarmupSessionStatus(this.displayName);

  final String displayName;

  bool get isLocked =>
      this == WarmupSessionStatus.playing || this == WarmupSessionStatus.paused;
}
