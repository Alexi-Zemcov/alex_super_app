import 'package:app_theme/app_theme.dart';
import 'package:flutter/material.dart';

class SettingSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const SettingSection({
    required this.title,
    required this.children,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.quizColors;

    return Card(
      color: colors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              title,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: colors.textMuted,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}
