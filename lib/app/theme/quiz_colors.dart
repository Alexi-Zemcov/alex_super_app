import 'package:flutter/material.dart';

@immutable
class QuizColors extends ThemeExtension<QuizColors> {
  const QuizColors({
    required this.background,
    required this.textStrong,
    required this.textSoft,
    required this.textMuted,
    required this.card,
    required this.cardAlt,
    required this.border,
    required this.accentBlue,
    required this.accentRed,
    required this.navText,
    required this.navDark,
  });

  final Color background;
  final Color textStrong;
  final Color textSoft;
  final Color textMuted;
  final Color card;
  final Color cardAlt;
  final Color border;
  final Color accentBlue;
  final Color accentRed;
  final Color navText;
  final Color navDark;

  @override
  QuizColors copyWith({
    Color? background,
    Color? textStrong,
    Color? textSoft,
    Color? textMuted,
    Color? card,
    Color? cardAlt,
    Color? border,
    Color? accentBlue,
    Color? accentRed,
    Color? navText,
    Color? navDark,
  }) {
    return QuizColors(
      background: background ?? this.background,
      textStrong: textStrong ?? this.textStrong,
      textSoft: textSoft ?? this.textSoft,
      textMuted: textMuted ?? this.textMuted,
      card: card ?? this.card,
      cardAlt: cardAlt ?? this.cardAlt,
      border: border ?? this.border,
      accentBlue: accentBlue ?? this.accentBlue,
      accentRed: accentRed ?? this.accentRed,
      navText: navText ?? this.navText,
      navDark: navDark ?? this.navDark,
    );
  }

  @override
  QuizColors lerp(ThemeExtension<QuizColors>? other, double t) {
    if (other is! QuizColors) {
      return this;
    }

    return QuizColors(
      background: Color.lerp(background, other.background, t)!,
      textStrong: Color.lerp(textStrong, other.textStrong, t)!,
      textSoft: Color.lerp(textSoft, other.textSoft, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      card: Color.lerp(card, other.card, t)!,
      cardAlt: Color.lerp(cardAlt, other.cardAlt, t)!,
      border: Color.lerp(border, other.border, t)!,
      accentBlue: Color.lerp(accentBlue, other.accentBlue, t)!,
      accentRed: Color.lerp(accentRed, other.accentRed, t)!,
      navText: Color.lerp(navText, other.navText, t)!,
      navDark: Color.lerp(navDark, other.navDark, t)!,
    );
  }
}

extension QuizColorsBuildContext on BuildContext {
  QuizColors get quizColors {
    final colors = Theme.of(this).extension<QuizColors>();
    assert(
      colors != null,
      'QuizColors extension must be configured in ThemeData.',
    );
    return colors!;
  }
}
