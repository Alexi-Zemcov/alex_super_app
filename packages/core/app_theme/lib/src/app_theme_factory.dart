import 'package:app_theme/src/quiz_colors.dart';
import 'package:app_theme/src/theme_preference.dart';
import 'package:flutter/material.dart';

abstract final class AppThemeFactory {
  static ThemeData fromPreference(ThemePreference preference) {
    final palette = _paletteFor(preference);
    final brightness = preference == ThemePreference.white
        ? Brightness.light
        : Brightness.dark;

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: palette.accentBlue,
      onPrimary: palette.navText,
      secondary: palette.accentRed,
      onSecondary: palette.navText,
      error: palette.accentRed,
      onError: palette.navText,
      surface: palette.card,
      onSurface: palette.textSoft,
    );

    final baseTypography = brightness == Brightness.dark
        ? Typography.whiteMountainView
        : Typography.blackMountainView;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: palette.background,
      colorScheme: colorScheme,
      cardColor: palette.card,
      dividerColor: palette.border,
      textTheme: baseTypography.apply(
        bodyColor: palette.textSoft,
        displayColor: palette.textStrong,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: palette.background,
        foregroundColor: palette.textStrong,
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
      ),
      splashColor: palette.accentBlue.withValues(alpha: 0.10),
      highlightColor: Colors.transparent,
      extensions: [palette],
    );
  }

  static QuizColors _paletteFor(ThemePreference preference) {
    switch (preference) {
      case ThemePreference.dark:
        return const QuizColors(
          background: Color(0xFF1A1A2E),
          textStrong: Color(0xFFFFFFFF),
          textSoft: Color(0xFFCCCCCC),
          textMuted: Color(0xFF888888),
          card: Color(0xFF2A2A3E),
          cardAlt: Color(0xFF222236),
          border: Color(0xFF444444),
          accentBlue: Color(0xFF5B9BD5),
          accentRed: Color(0xFFE84545),
          navText: Color(0xFFFFFFFF),
          navDark: Color(0xFF2A3550),
        );
      case ThemePreference.white:
        return const QuizColors(
          background: Color(0xFFFFFFFF),
          textStrong: Color(0xFF000000),
          textSoft: Color(0xFF222222),
          textMuted: Color(0xFF333333),
          card: Color(0xFFF3F3F3),
          cardAlt: Color(0xFFEBEBEB),
          border: Color(0xFF6D6D6D),
          accentBlue: Color(0xFF005FCC),
          accentRed: Color(0xFFB00020),
          navText: Color(0xFFFFFFFF),
          navDark: Color(0xFF1F1F1F),
        );
      case ThemePreference.black:
        return const QuizColors(
          background: Color(0xFF000000),
          textStrong: Color(0xFFFFFFFF),
          textSoft: Color(0xFFF0F0F0),
          textMuted: Color(0xFFD2D2D2),
          card: Color(0xFF101010),
          cardAlt: Color(0xFF1A1A1A),
          border: Color(0xFF7A7A7A),
          accentBlue: Color(0xFF66B2FF),
          accentRed: Color(0xFFFF6B6B),
          navText: Color(0xFFFFFFFF),
          navDark: Color(0xFF1D1D1D),
        );
    }
  }
}
