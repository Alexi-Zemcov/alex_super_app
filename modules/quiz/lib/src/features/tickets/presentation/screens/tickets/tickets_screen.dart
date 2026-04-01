import 'package:app_theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quiz/src/features/tickets/presentation/screens/tickets/bloc/tickets_bloc.dart';
import 'package:quiz/src/features/tickets/presentation/screens/tickets/bloc/tickets_event.dart';
import 'package:quiz/src/features/tickets/presentation/screens/tickets/bloc/tickets_state.dart';
import 'package:quiz/src/features/tickets/presentation/screens/tickets/models/ticket_list_item.dart';
import 'package:quiz/src/navigation/quiz_flow_intent.dart';
import 'package:quiz/src/navigation/quiz_routes.dart';

class TicketsScreen extends StatelessWidget {
  const TicketsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<TicketsBloc, TicketsState>(
          listenWhen: (previous, current) {
            final previousPrompt = previous is TicketsLoaded
                ? previous.pendingResumePrompt
                : null;
            final currentPrompt = current is TicketsLoaded
                ? current.pendingResumePrompt
                : null;
            return currentPrompt != null && currentPrompt != previousPrompt;
          },
          listener: (context, state) async {
            final currentState = state as TicketsLoaded;
            final prompt = currentState.pendingResumePrompt!;

            final action = await showDialog<_TicketDialogAction>(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('Продолжить?'),
                  content: Text(
                    'Отвечено ${prompt.answeredCount} из ${prompt.totalCount} вопросов',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(_TicketDialogAction.restart);
                      },
                      child: const Text('Начать заново'),
                    ),
                    FilledButton(
                      onPressed: () {
                        Navigator.of(context).pop(_TicketDialogAction.resume);
                      },
                      child: const Text('Продолжить'),
                    ),
                  ],
                );
              },
            );

            if (!context.mounted) {
              return;
            }

            switch (action) {
              case _TicketDialogAction.resume:
                context.read<TicketsBloc>().add(
                  TicketsResumeRequested(prompt.ticketId),
                );
              case _TicketDialogAction.restart:
                context.read<TicketsBloc>().add(
                  TicketsRestartRequested(prompt.ticketId),
                );
              case null:
                context.read<TicketsBloc>().add(const TicketsPromptDismissed());
            }
          },
        ),
        BlocListener<TicketsBloc, TicketsState>(
          listenWhen: (previous, current) {
            final previousNavigation = previous is TicketsLoaded
                ? previous.pendingNavigation
                : null;
            final currentNavigation = current is TicketsLoaded
                ? current.pendingNavigation
                : null;
            return currentNavigation != null &&
                currentNavigation != previousNavigation;
          },
          listener: (context, state) async {
            final currentState = state as TicketsLoaded;
            final navigation = currentState.pendingNavigation!;

            context.read<TicketsBloc>().add(const TicketsNavigationHandled());
            await QuizTicketRoute(
              ticketId: navigation.ticketId!,
              startBehavior: navigation.startBehavior.queryValue,
            ).push<void>(context);
            if (!context.mounted) {
              return;
            }
            context.read<TicketsBloc>().add(const TicketsStarted());
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(title: const Text('Билеты')),
        body: SafeArea(
          child: BlocBuilder<TicketsBloc, TicketsState>(
            builder: (context, state) {
              return switch (state) {
                TicketsInitial() || TicketsLoading() => const Center(
                  child: CircularProgressIndicator(),
                ),
                TicketsFailure() => _TicketsFailureView(message: state.message),
                TicketsLoaded() => _TicketsLoadedView(tickets: state.tickets),
              };
            },
          ),
        ),
      ),
    );
  }
}

class _TicketsLoadedView extends StatelessWidget {
  const _TicketsLoadedView({required this.tickets});

  final List<TicketListItem> tickets;

  @override
  Widget build(BuildContext context) {
    final colors = context.quizColors;

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: tickets.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final ticket = tickets[index];
        return Material(
          color: ticket.isCompleted ? colors.cardAlt : colors.card,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              context.read<TicketsBloc>().add(TicketPressed(ticket.id));
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: colors.accentBlue.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${ticket.id}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: colors.accentBlue,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Билет ${ticket.id}',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: colors.textStrong,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${ticket.correctCount} / ${ticket.totalCount}',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: colors.textSoft,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: ticket.progressRatio,
                            minHeight: 6,
                            backgroundColor: colors.border,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              ticket.isCompleted
                                  ? colors.accentRed
                                  : colors.accentBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TicketsFailureView extends StatelessWidget {
  const _TicketsFailureView({required this.message});

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
                context.read<TicketsBloc>().add(const TicketsStarted());
              },
              child: const Text('Повторить'),
            ),
          ],
        ),
      ),
    );
  }
}

enum _TicketDialogAction { resume, restart }
