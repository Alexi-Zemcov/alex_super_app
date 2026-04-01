import 'package:app_theme/app_theme.dart';
import 'package:flutter/material.dart';

class AboutItem extends StatelessWidget {
  const AboutItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    super.key,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colors = context.quizColors;

    return ListTile(
      leading: Icon(icon, color: colors.textMuted),
      title: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.bodyLarge?.copyWith(color: colors.textStrong),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: colors.textSoft),
      ),
    );
  }
}
