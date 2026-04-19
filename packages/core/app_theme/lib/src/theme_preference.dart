enum ThemePreference {
  dark,
  white,
  black;

  String get storageValue {
    switch (this) {
      case ThemePreference.dark:
        return 'dark';
      case ThemePreference.white:
        return 'white';
      case ThemePreference.black:
        return 'black';
    }
  }

  String get icon {
    switch (this) {
      case ThemePreference.dark:
        return '🌕';
      case ThemePreference.white:
        return '☀️';
      case ThemePreference.black:
        return '🌙';
    }
  }

  String get semanticsLabel {
    switch (this) {
      case ThemePreference.dark:
        return 'Theme: dark. Tap to switch theme';
      case ThemePreference.white:
        return 'Theme: white. Tap to switch theme';
      case ThemePreference.black:
        return 'Theme: black. Tap to switch theme';
    }
  }

  ThemePreference get next {
    switch (this) {
      case ThemePreference.dark:
        return ThemePreference.white;
      case ThemePreference.white:
        return ThemePreference.black;
      case ThemePreference.black:
        return ThemePreference.dark;
    }
  }
}
