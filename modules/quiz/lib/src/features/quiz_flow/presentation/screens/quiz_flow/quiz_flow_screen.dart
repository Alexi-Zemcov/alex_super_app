import 'package:app_theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quiz/src/features/quiz/domain/entities/quiz_answer.dart';
import 'package:quiz/src/features/quiz/domain/entities/quiz_mode.dart';
import 'package:quiz/src/features/quiz/domain/entities/quiz_question.dart';
import 'package:quiz/src/features/quiz/domain/entities/quiz_result.dart';
import 'package:quiz/src/features/quiz/domain/entities/quiz_session.dart';
import 'package:quiz/src/features/quiz_flow/presentation/screens/quiz_flow/bloc/quiz_flow_bloc.dart';
import 'package:quiz/src/features/quiz_flow/presentation/screens/quiz_flow/bloc/quiz_flow_event.dart';
import 'package:quiz/src/features/quiz_flow/presentation/screens/quiz_flow/bloc/quiz_flow_state.dart';
import 'package:quiz/src/navigation/quiz_routes.dart';

class QuizFlowScreen extends StatelessWidget {
  const QuizFlowScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope<void>(
      canPop: !context.select(
        (QuizFlowBloc bloc) => bloc.requiresExitConfirmation,
      ),
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }

        final shouldExit = await _showExitDialog(context);
        if (shouldExit && context.mounted) {
          _goHome(context);
        }
      },
      child: BlocBuilder<QuizFlowBloc, QuizFlowState>(
        builder: (context, state) {
          return switch (state) {
            QuizFlowLoading() => const Scaffold(
              body: SafeArea(child: Center(child: CircularProgressIndicator())),
            ),
            QuizFlowFailure() => _QuizFlowFailureView(message: state.message),
            QuizFlowActive() => _QuizFlowActiveView(state: state),
            QuizFlowResults() => _QuizFlowResultsView(state: state),
          };
        },
      ),
    );
  }

  static Future<bool> _showExitDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Хотите выйти?'),
          content: const Text('Можно продолжить потом.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Продолжить'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Выйти'),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  static void _goHome(BuildContext context) {
    const QuizHomeRoute().go(context);
  }
}

class _QuizFlowActiveView extends StatelessWidget {
  const _QuizFlowActiveView({required this.state});

  final QuizFlowActive state;

  @override
  Widget build(BuildContext context) {
    final session = state.session;
    final question = session.currentQuestion;
    final colors = context.quizColors;
    final isFavorite = state.favorites.contains(question.key);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () async {
            final shouldExit = await QuizFlowScreen._showExitDialog(context);
            if (shouldExit && context.mounted) {
              QuizFlowScreen._goHome(context);
            }
          },
        ),
        title: Text(_headerTitle(session)),
        actions: [
          if (state.remainingSeconds != null)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  _formatTime(state.remainingSeconds!),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: state.remainingSeconds! < 60
                        ? colors.accentRed
                        : colors.textStrong,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 60,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                scrollDirection: Axis.horizontal,
                itemCount: session.currentQuestions.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final answer = session.answers[index];
                  final isCurrent = index == session.currentIndex;
                  final canOpen =
                      index == session.currentIndex || answer != null;

                  final backgroundColor = switch ((
                    isCurrent,
                    answer?.isCorrect,
                  )) {
                    (true, _) => colors.accentBlue,
                    (false, true) => colors.accentBlue.withValues(alpha: 0.18),
                    (false, false) when answer != null =>
                      colors.accentRed.withValues(alpha: 0.18),
                    _ => colors.card,
                  };
                  final textColor = isCurrent
                      ? colors.navText
                      : colors.textStrong;

                  return Material(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: canOpen
                          ? () {
                              context.read<QuizFlowBloc>().add(
                                QuizQuestionRequested(index),
                              );
                            }
                          : null,
                      child: SizedBox(
                        width: 40,
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(
                                  color: textColor,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      question.question,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: colors.textStrong,
                          ),
                    ),
                    const SizedBox(height: 20),
                    for (
                      var index = 0;
                      index < question.options.length;
                      index += 1
                    ) ...[
                      _OptionTile(
                        index: index,
                        question: question,
                        answer: session.currentAnswer,
                      ),
                      const SizedBox(height: 12),
                    ],
                    const SizedBox(height: 4),
                    OutlinedButton.icon(
                      onPressed: () {
                        context.read<QuizFlowBloc>().add(
                          const QuizFavoriteToggled(),
                        );
                      },
                      icon: Icon(
                        isFavorite
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                      ),
                      label: Text(
                        isFavorite
                            ? 'Убрать из избранного'
                            : 'Добавить в избранное',
                      ),
                    ),
                    if (session.currentAnswer != null) ...[
                      const SizedBox(height: 20),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: colors.card,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Комментарий',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: colors.textStrong,
                                    ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Правильный ответ: ${question.correctIndex + 1}',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: colors.textSoft,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                question.explanation,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: colors.textMuted),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (session.currentAnswer != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: FilledButton(
                  onPressed: () {
                    context.read<QuizFlowBloc>().add(const QuizNextPressed());
                  },
                  child: Text(_nextButtonTitle(session)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.index,
    required this.question,
    required this.answer,
  });

  final int index;
  final QuizQuestion question;
  final QuizAnswer? answer;

  @override
  Widget build(BuildContext context) {
    final colors = context.quizColors;
    final isAnswered = answer != null;
    final isCorrect = index == question.correctIndex;
    final isWrongSelected =
        answer != null && !answer!.isCorrect && answer!.selectedIndex == index;

    final backgroundColor = switch ((isAnswered, isCorrect, isWrongSelected)) {
      (true, true, _) => colors.accentBlue.withValues(alpha: 0.16),
      (true, _, true) => colors.accentRed.withValues(alpha: 0.16),
      _ => colors.card,
    };

    final borderColor = switch ((isAnswered, isCorrect, isWrongSelected)) {
      (true, true, _) => colors.accentBlue,
      (true, _, true) => colors.accentRed,
      _ => colors.border,
    };

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: isAnswered
            ? null
            : () {
                context.read<QuizFlowBloc>().add(QuizAnswerSelected(index));
              },
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Text(
              '${index + 1}. ${question.options[index]}',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: colors.textStrong,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _QuizFlowResultsView extends StatelessWidget {
  const _QuizFlowResultsView({required this.state});

  final QuizFlowResults state;

  @override
  Widget build(BuildContext context) {
    final colors = context.quizColors;
    final percentage = state.result.percentage;
    final scoreColor = percentage >= 80
        ? colors.accentBlue
        : percentage >= 50
        ? colors.textSoft
        : colors.accentRed;

    return Scaffold(
      appBar: AppBar(title: const Text('Результаты')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Center(
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      color: scoreColor.withValues(alpha: 0.14),
                      shape: BoxShape.circle,
                      border: Border.all(color: scoreColor, width: 4),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$percentage%',
                          style: Theme.of(context).textTheme.displaySmall
                              ?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: scoreColor,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${state.result.correctCount} из ${state.result.totalCount}',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: colors.textStrong,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                for (final categoryResult in state.result.categoryResults) ...[
                  _CategoryResultCard(categoryResult: categoryResult),
                  const SizedBox(height: 12),
                ],
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () {
                    context.read<QuizFlowBloc>().add(const QuizRetryPressed());
                  },
                  child: const Text('Пройти заново'),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () {
                    QuizFlowScreen._goHome(context);
                  },
                  child: const Text('На главную'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryResultCard extends StatelessWidget {
  const _CategoryResultCard({required this.categoryResult});

  final QuizCategoryResult categoryResult;

  @override
  Widget build(BuildContext context) {
    final colors = context.quizColors;
    final percentage = categoryResult.percentage;
    final scoreColor = percentage >= 80
        ? colors.accentBlue
        : percentage >= 50
        ? colors.textSoft
        : colors.accentRed;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                categoryResult.category,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.textStrong,
                ),
              ),
            ),
            Text(
              '${categoryResult.correctCount}/${categoryResult.totalCount}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: scoreColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuizFlowFailureView extends StatelessWidget {
  const _QuizFlowFailureView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Квиз')),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(message, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () async {
                    await Navigator.of(context).maybePop();
                  },
                  child: const Text('Назад'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _headerTitle(QuizSession session) {
  final questionNumber = session.currentIndex + 1;

  switch (session.mode) {
    case QuizMode.ticket:
      return 'Билет ${session.ticketId}, вопрос $questionNumber';
    case QuizMode.blitz:
      return 'Блиц, вопрос $questionNumber';
    case QuizMode.topic:
      return '${session.topicName}, вопрос $questionNumber';
    case QuizMode.marathon:
      return 'Марафон, вопрос $questionNumber';
    case QuizMode.errors:
      return 'Ошибки, вопрос $questionNumber';
    case QuizMode.favorites:
      return 'Избранное, вопрос $questionNumber';
  }
}

String _nextButtonTitle(QuizSession session) {
  final hasUnanswered = session.answers.any((answer) => answer == null);
  return hasUnanswered ? 'Следующий вопрос' : 'Результаты';
}

String _formatTime(int totalSeconds) {
  final minutes = totalSeconds ~/ 60;
  final seconds = totalSeconds % 60;
  return '$minutes:${seconds.toString().padLeft(2, '0')}';
}
