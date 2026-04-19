import 'package:app_theme/app_theme.dart';

ThemePreference parseThemePreference(String? rawValue) {
  switch (rawValue) {
    case 'white':
    case 'white-contrast':
      return ThemePreference.white;
    case 'black':
    case 'black-contrast':
      return ThemePreference.black;
    case 'dark':
    case 'default':
    default:
      return ThemePreference.dark;
  }
}
