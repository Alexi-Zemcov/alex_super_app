/// Preference for displaying musical notation (sharps vs flats).
enum NotationPreference {
  /// Prefer sharp notation (C#, D#, F#, G#, A#).
  preferSharps,

  /// Prefer flat notation (Db, Eb, Gb, Ab, Bb).
  preferFlats,

  /// Automatically choose based on key (sharps for sharp keys, flats for flat keys).
  automatic;

  /// Display name for the preference.
  String get displayName {
    switch (this) {
      case NotationPreference.preferSharps:
        return 'Prefer Sharps';
      case NotationPreference.preferFlats:
        return 'Prefer Flats';
      case NotationPreference.automatic:
        return 'Automatic';
    }
  }
}
