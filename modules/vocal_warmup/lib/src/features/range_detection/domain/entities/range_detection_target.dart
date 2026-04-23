enum RangeDetectionTarget {
  lowest,
  highest;

  bool get isLowest => this == RangeDetectionTarget.lowest;
}
