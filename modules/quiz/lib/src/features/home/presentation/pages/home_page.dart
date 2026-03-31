import 'package:app_theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:quiz/src/features/home/domain/entities/home_progress.dart';
import 'package:quiz/src/features/home/presentation/bloc/home_bloc.dart';
import 'package:quiz/src/features/home/presentation/bloc/home_event.dart';
import 'package:quiz/src/features/home/presentation/bloc/home_state.dart';
import 'package:quiz/src/features/home/presentation/models/home_destination.dart';
import 'package:quiz/src/navigation/quiz_route_names.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeBloc, HomeState>(
      listenWhen: (previous, current) {
        final previousDestination = previous is HomeLoaded
            ? previous.pendingDestination
            : null;
        final currentDestination = current is HomeLoaded
            ? current.pendingDestination
            : null;

        return currentDestination != null &&
            currentDestination != previousDestination;
      },
      listener: (context, state) async {
        final currentState = state as HomeLoaded;
        final destination = currentState.pendingDestination!;

        context.read<HomeBloc>().add(const HomeNavigationHandled());
        await Navigator.of(
          context,
        ).pushNamed(QuizRouteNames.destination, arguments: destination);
      },
      child: Scaffold(
        body: SafeArea(
          child: BlocBuilder<HomeBloc, HomeState>(
            builder: (context, state) {
              return switch (state) {
                HomeInitial() || HomeLoading() => const Center(
                  child: CircularProgressIndicator(),
                ),
                HomeFailure() => _HomeFailureView(message: state.message),
                HomeLoaded() => _HomeLoadedView(state: state),
              };
            },
          ),
        ),
      ),
    );
  }
}

class _HomeLoadedView extends StatelessWidget {
  const _HomeLoadedView({required this.state});

  final HomeLoaded state;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _HomeTitle(),
              const SizedBox(height: 16),
              _HeroCard(progress: state.progress),
              const SizedBox(height: 16),
              _DestinationGrid(destinations: state.destinations),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeFailureView extends StatelessWidget {
  const _HomeFailureView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                context.read<HomeBloc>().add(const HomeStarted());
              },
              child: const Text('Повторить'),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeTitle extends StatelessWidget {
  const _HomeTitle();

  @override
  Widget build(BuildContext context) {
    final colors = context.quizColors;
    final titleStyle = Theme.of(context).textTheme.headlineMedium?.copyWith(
      fontWeight: FontWeight.w800,
      color: colors.textStrong,
    );

    return Center(
      child: Text.rich(
        TextSpan(
          style: titleStyle,
          children: [
            const TextSpan(text: 'Flutter '),
            TextSpan(
              text: 'Quiz',
              style: titleStyle?.copyWith(color: colors.accentRed),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.progress});

  final HomeProgress progress;

  @override
  Widget build(BuildContext context) {
    final colors = context.quizColors;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: colors.cardAlt,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: _ThemeToggleButton(
                      themePreference: context.select(
                        (AppThemeController controller) =>
                            controller.themePreference,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Center(
                      child: Image.asset(
                        'assets/images/dashatars.png',
                        package: 'quiz',
                        height: 188,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.flutter_dash_rounded,
                            size: 112,
                            color: colors.accentBlue,
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 18, 12, 18),
            child: Row(
              children: [
                Expanded(
                  child: _ProgressStat(
                    completed: progress.completedQuestions,
                    total: progress.totalQuestions,
                    ratio: progress.questionsRatio,
                    label: 'Вопросы',
                  ),
                ),
                Expanded(
                  child: _ProgressStat(
                    completed: progress.completedTickets,
                    total: progress.totalTickets,
                    ratio: progress.ticketsRatio,
                    label: 'Билеты',
                  ),
                ),
                Expanded(
                  child: _ProgressStat(
                    completed: progress.completedTopics,
                    total: progress.totalTopics,
                    ratio: progress.topicsRatio,
                    label: 'Темы',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeToggleButton extends StatelessWidget {
  const _ThemeToggleButton({required this.themePreference});

  final ThemePreference themePreference;

  @override
  Widget build(BuildContext context) {
    final colors = context.quizColors;

    return Semantics(
      button: true,
      label: themePreference.semanticsLabel,
      child: Material(
        color: colors.card.withValues(alpha: 0.18),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () {
            context.read<AppThemeController>().cycleTheme();
          },
          child: SizedBox.square(
            dimension: 48,
            child: Center(
              child: Text(
                themePreference.icon,
                style: const TextStyle(fontSize: 26),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgressStat extends StatelessWidget {
  const _ProgressStat({
    required this.completed,
    required this.total,
    required this.ratio,
    required this.label,
  });

  final int completed;
  final int total;
  final double ratio;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.quizColors;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        children: [
          Text(
            '$completed / $total',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: colors.textSoft,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 4,
              backgroundColor: colors.border,
              valueColor: AlwaysStoppedAnimation<Color>(colors.accentBlue),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: colors.textMuted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _DestinationGrid extends StatelessWidget {
  const _DestinationGrid({required this.destinations});

  final List<HomeDestination> destinations;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: destinations.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.5,
      ),
      itemBuilder: (context, index) {
        final destination = destinations[index];
        return _DestinationButton(destination: destination);
      },
    );
  }
}

class _DestinationButton extends StatelessWidget {
  const _DestinationButton({required this.destination});

  final HomeDestination destination;

  @override
  Widget build(BuildContext context) {
    final colors = context.quizColors;
    final backgroundColor = switch (destination.tone) {
      HomeDestinationTone.blue => colors.accentBlue,
      HomeDestinationTone.red => colors.accentRed,
      HomeDestinationTone.dark => colors.navDark,
    };

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          context.read<HomeBloc>().add(HomeDestinationPressed(destination));
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(destination.icon, color: colors.navText, size: 26),
              const SizedBox(height: 8),
              Text(
                destination.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: colors.navText,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
