import 'package:flutter/material.dart';
import 'package:vocal_warmup/src/features/range_detection/domain/entities/vocal_range.dart';
import 'package:vocal_warmup/src/features/range_detection/presentation/widgets/range_visuals.dart';

class ExerciseSelectionScreen extends StatelessWidget {
  const ExerciseSelectionScreen({required this.range, super.key});

  final VocalRange range;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VocalWarmupColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 28),
                  const Text(
                    'Распевка',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: VocalWarmupColors.textStrong,
                      fontSize: 30,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Выберите тип упражнения',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: VocalWarmupColors.textMuted,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 36),
                  const _ExerciseCard(
                    title: 'Мычание',
                    pattern: 'Паттерн: 1-2-1',
                    active: true,
                  ),
                  const SizedBox(height: 18),
                  const _ExerciseCard(
                    title: 'Тра-та-та',
                    pattern: 'Паттерн: 1-2-3-2-1',
                    active: false,
                  ),
                  const Spacer(),
                  Text(
                    'Диапазон ${range.lowestNote.label()} - '
                    '${range.highestNote.label()}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: VocalWarmupColors.textMuted,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'Свайп влево / вправо\nдля переключения режимов',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: VocalWarmupColors.textMuted,
                      fontSize: 16,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({
    required this.title,
    required this.pattern,
    required this.active,
  });

  final String title;
  final String pattern;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 96),
      decoration: BoxDecoration(
        color: active ? const Color(0xFFF3F0FF) : VocalWarmupColors.surfaceSoft,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: active ? VocalWarmupColors.accent : Colors.transparent,
        ),
      ),
      child: Row(
        children: [
          ExerciseWaveIcon(active: active),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: active
                        ? VocalWarmupColors.accent
                        : VocalWarmupColors.textStrong,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  pattern,
                  style: const TextStyle(
                    color: VocalWarmupColors.textMuted,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 18),
            child: Icon(
              Icons.chevron_right_rounded,
              color: VocalWarmupColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
