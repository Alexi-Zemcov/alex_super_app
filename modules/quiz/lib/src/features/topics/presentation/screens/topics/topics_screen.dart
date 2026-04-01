import 'package:app_theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quiz/src/features/topics/presentation/screens/topics/bloc/topics_bloc.dart';
import 'package:quiz/src/features/topics/presentation/screens/topics/bloc/topics_event.dart';
import 'package:quiz/src/features/topics/presentation/screens/topics/bloc/topics_state.dart';
import 'package:quiz/src/features/topics/presentation/screens/topics/models/topic_list_item.dart';
import 'package:quiz/src/navigation/quiz_routes.dart';

class TopicsScreen extends StatelessWidget {
  const TopicsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<TopicsBloc, TopicsState>(
      listenWhen: (previous, current) {
        final previousNavigation = previous is TopicsLoaded
            ? previous.pendingNavigation
            : null;
        final currentNavigation = current is TopicsLoaded
            ? current.pendingNavigation
            : null;
        return currentNavigation != null &&
            currentNavigation != previousNavigation;
      },
      listener: (context, state) async {
        final currentState = state as TopicsLoaded;
        final navigation = currentState.pendingNavigation!;

        context.read<TopicsBloc>().add(const TopicsNavigationHandled());
        await QuizTopicRoute(topicId: navigation.topicId!).push<void>(context);
        if (!context.mounted) {
          return;
        }
        context.read<TopicsBloc>().add(const TopicsStarted());
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Вопросы по темам')),
        body: SafeArea(
          child: BlocBuilder<TopicsBloc, TopicsState>(
            builder: (context, state) {
              return switch (state) {
                TopicsInitial() || TopicsLoading() => const Center(
                  child: CircularProgressIndicator(),
                ),
                TopicsFailure() => _TopicsFailureView(message: state.message),
                TopicsLoaded() => _TopicsLoadedView(topics: state.topics),
              };
            },
          ),
        ),
      ),
    );
  }
}

class _TopicsLoadedView extends StatelessWidget {
  const _TopicsLoadedView({required this.topics});

  final List<TopicListItem> topics;

  @override
  Widget build(BuildContext context) {
    final colors = context.quizColors;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Тренировка по темам',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: colors.textStrong,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Тема считается завершённой, если все вопросы хотя бы раз решены правильно.',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: colors.textMuted),
        ),
        const SizedBox(height: 16),
        for (final topic in topics) ...[
          _TopicCard(topic: topic),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _TopicCard extends StatelessWidget {
  const _TopicCard({required this.topic});

  final TopicListItem topic;

  @override
  Widget build(BuildContext context) {
    final colors = context.quizColors;

    return Material(
      color: topic.isCompleted ? colors.cardAlt : colors.card,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          context.read<TopicsBloc>().add(TopicPressed(topic.id));
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: topic.isCompleted
                      ? colors.accentBlue.withValues(alpha: 0.16)
                      : colors.navDark.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${topic.id}',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: topic.isCompleted
                        ? colors.accentBlue
                        : colors.textStrong,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      topic.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colors.textStrong,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${topic.questionCount} вопросов',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: colors.textMuted),
                    ),
                  ],
                ),
              ),
              if (topic.isCompleted)
                Icon(Icons.check_circle_rounded, color: colors.accentBlue),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopicsFailureView extends StatelessWidget {
  const _TopicsFailureView({required this.message});

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
                context.read<TopicsBloc>().add(const TopicsStarted());
              },
              child: const Text('Повторить'),
            ),
          ],
        ),
      ),
    );
  }
}
