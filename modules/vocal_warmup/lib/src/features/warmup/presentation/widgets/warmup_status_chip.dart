import 'package:app_theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:vocal_warmup/src/features/warmup/domain/entities/warmup_session_status.dart';

class WarmupStatusChip extends StatelessWidget {
  const WarmupStatusChip({required this.status, super.key});

  final WarmupSessionStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = context.quizColors;
    final color = switch (status) {
      WarmupSessionStatus.idle => colors.textMuted,
      WarmupSessionStatus.playing => colors.accentBlue,
      WarmupSessionStatus.paused => Colors.amber,
      WarmupSessionStatus.finished => Colors.green,
    };

    return Chip(
      label: Text(status.displayName),
      backgroundColor: color.withValues(alpha: 0.18),
      labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: color,
        fontWeight: FontWeight.w700,
      ),
      side: BorderSide(color: color.withValues(alpha: 0.35)),
    );
  }
}
