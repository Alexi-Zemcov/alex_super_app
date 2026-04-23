import 'package:app_theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:vocal_warmup/src/features/warmup/domain/entities/vocal_exercise.dart';

Future<void> showExerciseDetailsSheet(
  BuildContext context,
  VocalExercise exercise,
) {
  final colors = context.quizColors;

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: colors.card,
    builder: (context) {
      return SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${exercise.title} / ${exercise.subtitle}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: colors.textStrong,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              _ExerciseSection(title: 'Назначение', body: exercise.purpose),
              _ExerciseSection(
                title: 'Описание процесса',
                body: exercise.description,
              ),
              _ExerciseSection(
                title: 'На что обратить внимание',
                body: exercise.focus,
              ),
              _ExerciseSection(
                title: 'Что делать с воздухом',
                body: exercise.airflow,
              ),
              _ExerciseSection(
                title: 'Типичные ошибки',
                body: exercise.mistakes,
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _ExerciseSection extends StatelessWidget {
  const _ExerciseSection({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final colors = context.quizColors;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: colors.textStrong,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colors.textSoft,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
