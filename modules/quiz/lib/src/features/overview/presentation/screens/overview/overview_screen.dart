import 'package:app_theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quiz/quiz_assets.dart';
import 'package:quiz/src/features/overview/presentation/screens/overview/bloc/overview_bloc.dart';
import 'package:quiz/src/features/overview/presentation/screens/overview/bloc/overview_event.dart';
import 'package:quiz/src/features/overview/presentation/screens/overview/bloc/overview_state.dart';
import 'package:quiz/src/features/quiz/domain/entities/quiz_mode.dart';
import 'package:quiz/src/navigation/quiz_routes.dart';

class OverviewScreen extends StatelessWidget {
  const OverviewScreen({required this.mode, super.key});

  final QuizMode mode;

  @override
  Widget build(BuildContext context) {
    return BlocListener<OverviewBloc, OverviewState>(
      listenWhen: (previous, current) {
        final previousNavigation = previous is OverviewLoaded
            ? previous.pendingNavigation
            : null;
        final currentNavigation = current is OverviewLoaded
            ? current.pendingNavigation
            : null;
        return currentNavigation != null &&
            currentNavigation != previousNavigation;
      },
      listener: (context, state) async {
        final currentState = state as OverviewLoaded;
        final navigation = currentState.pendingNavigation!;

        context.read<OverviewBloc>().add(const OverviewNavigationHandled());
        await _pushOverviewNavigation(context, navigation.mode);
        if (!context.mounted) {
          return;
        }
        context.read<OverviewBloc>().add(const OverviewStarted());
      },
      child: Scaffold(
        appBar: AppBar(title: Text(_titleForMode(mode))),
        body: SafeArea(
          child: BlocBuilder<OverviewBloc, OverviewState>(
            builder: (context, state) {
              return switch (state) {
                OverviewInitial() || OverviewLoading() => const Center(
                  child: CircularProgressIndicator(),
                ),
                OverviewFailure() => _OverviewFailureView(
                  message: state.message,
                ),
                OverviewLoaded() => _OverviewLoadedView(
                  mode: mode,
                  count: state.count,
                ),
              };
            },
          ),
        ),
      ),
    );
  }
}

class _OverviewLoadedView extends StatelessWidget {
  const _OverviewLoadedView({required this.mode, required this.count});

  final QuizMode mode;
  final int count;

  @override
  Widget build(BuildContext context) {
    final colors = context.quizColors;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (mode == QuizMode.marathon) ...[
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.cardAlt,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
                    child: Column(
                      children: [
                        Image.asset(
                          QuizAssets.dashatars,
                          package: 'quiz',
                          height: 180,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Все $count вопросов',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: colors.textStrong,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Проверь себя на прочность!',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(color: colors.textMuted),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        FilledButton(
                          onPressed: () {
                            context.read<OverviewBloc>().add(
                              const OverviewStartPressed(),
                            );
                          },
                          child: const Text('Начать марафон'),
                        ),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.card,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: count == 0
                        ? _EmptyOverview(mode: mode)
                        : _FilledOverview(mode: mode, count: count),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _FilledOverview extends StatelessWidget {
  const _FilledOverview({required this.mode, required this.count});

  final QuizMode mode;
  final int count;

  @override
  Widget build(BuildContext context) {
    final colors = context.quizColors;

    final text = switch (mode) {
      QuizMode.errors => '$count вопросов с ошибками',
      QuizMode.favorites => '$count избранных вопросов',
      QuizMode.ticket ||
      QuizMode.blitz ||
      QuizMode.topic ||
      QuizMode.marathon => '',
    };

    final buttonTitle = switch (mode) {
      QuizMode.errors => 'Работа над ошибками',
      QuizMode.favorites => 'Начать',
      QuizMode.ticket ||
      QuizMode.blitz ||
      QuizMode.topic ||
      QuizMode.marathon => '',
    };

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          text,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: colors.textStrong,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        FilledButton(
          onPressed: () {
            context.read<OverviewBloc>().add(const OverviewStartPressed());
          },
          child: Text(buttonTitle),
        ),
      ],
    );
  }
}

class _EmptyOverview extends StatelessWidget {
  const _EmptyOverview({required this.mode});

  final QuizMode mode;

  @override
  Widget build(BuildContext context) {
    final colors = context.quizColors;

    final message = switch (mode) {
      QuizMode.errors => 'Ошибок пока нет!\nНачни тренировку',
      QuizMode.favorites =>
        'Здесь появятся вопросы, которые ты отметишь как избранные',
      QuizMode.ticket ||
      QuizMode.blitz ||
      QuizMode.topic ||
      QuizMode.marathon => '',
    };

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          message,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: colors.textStrong,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        if (mode == QuizMode.errors) ...[
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () {
              const QuizHomeRoute().go(context);
            },
            child: const Text('На главную'),
          ),
        ],
      ],
    );
  }
}

Future<void> _pushOverviewNavigation(BuildContext context, QuizMode mode) {
  switch (mode) {
    case QuizMode.marathon:
      return const QuizMarathonRunRoute().push<void>(context);
    case QuizMode.errors:
      return const QuizErrorsRunRoute().push<void>(context);
    case QuizMode.favorites:
      return const QuizFavoritesRunRoute().push<void>(context);
    case QuizMode.ticket:
    case QuizMode.blitz:
    case QuizMode.topic:
      throw StateError('Unsupported overview navigation mode: $mode');
  }
}

class _OverviewFailureView extends StatelessWidget {
  const _OverviewFailureView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                context.read<OverviewBloc>().add(const OverviewStarted());
              },
              child: const Text('Повторить'),
            ),
          ],
        ),
      ),
    );
  }
}

String _titleForMode(QuizMode mode) {
  switch (mode) {
    case QuizMode.marathon:
      return 'Марафон';
    case QuizMode.errors:
      return 'Ошибки';
    case QuizMode.favorites:
      return 'Избранное';
    case QuizMode.ticket:
    case QuizMode.blitz:
    case QuizMode.topic:
      return mode.title;
  }
}
