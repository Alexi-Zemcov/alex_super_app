import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quiz/src/features/quiz/domain/entities/quiz_start_behavior.dart';
import 'package:quiz/src/features/quiz/domain/repositories/progress_repository.dart';
import 'package:quiz/src/features/quiz/domain/repositories/question_repository.dart';
import 'package:quiz/src/features/tickets/presentation/screens/tickets/bloc/tickets_event.dart';
import 'package:quiz/src/features/tickets/presentation/screens/tickets/bloc/tickets_state.dart';
import 'package:quiz/src/features/tickets/presentation/screens/tickets/models/ticket_list_item.dart';
import 'package:quiz/src/features/tickets/presentation/screens/tickets/models/ticket_resume_prompt.dart';
import 'package:quiz/src/navigation/quiz_flow_route_args.dart';

class TicketsBloc extends Bloc<TicketsEvent, TicketsState> {
  TicketsBloc({
    required QuestionRepository questionRepository,
    required ProgressRepository progressRepository,
  }) : _questionRepository = questionRepository,
       _progressRepository = progressRepository,
       super(const TicketsInitial()) {
    on<TicketsStarted>(_onStarted);
    on<TicketPressed>(_onTicketPressed);
    on<TicketsResumeRequested>(_onResumeRequested);
    on<TicketsRestartRequested>(_onRestartRequested);
    on<TicketsPromptDismissed>(_onPromptDismissed);
    on<TicketsNavigationHandled>(_onNavigationHandled);
  }

  final QuestionRepository _questionRepository;
  final ProgressRepository _progressRepository;

  Future<void> _onStarted(
    TicketsStarted event,
    Emitter<TicketsState> emit,
  ) async {
    emit(const TicketsLoading());

    try {
      final tickets = await _questionRepository.getTickets();
      final stats = await _progressRepository.getQuestionStats();

      emit(
        TicketsLoaded(
          tickets: List<TicketListItem>.unmodifiable(
            tickets.map((ticket) {
              final correctCount = ticket.questions
                  .where(
                    (question) =>
                        stats[question.key]?.hasCorrectAttempt ?? false,
                  )
                  .length;
              final answeredCount = ticket.questions
                  .where(
                    (question) => (stats[question.key]?.totalAttempts ?? 0) > 0,
                  )
                  .length;

              return TicketListItem(
                id: ticket.id,
                correctCount: correctCount,
                answeredCount: answeredCount,
                totalCount: ticket.questions.length,
              );
            }),
          ),
        ),
      );
    } catch (_) {
      emit(
        const TicketsFailure(message: 'Не удалось загрузить список билетов.'),
      );
    }
  }

  void _onTicketPressed(TicketPressed event, Emitter<TicketsState> emit) {
    final currentState = state;
    if (currentState is! TicketsLoaded) {
      return;
    }

    final selectedTicket = currentState.tickets.firstWhere(
      (ticket) => ticket.id == event.ticketId,
      orElse: () => const TicketListItem(
        id: -1,
        correctCount: 0,
        answeredCount: 0,
        totalCount: 0,
      ),
    );

    if (selectedTicket.id == -1) {
      return;
    }

    if (selectedTicket.answeredCount > 0) {
      emit(
        currentState.copyWith(
          pendingResumePrompt: TicketResumePrompt(
            ticketId: selectedTicket.id,
            answeredCount: selectedTicket.answeredCount,
            totalCount: selectedTicket.totalCount,
          ),
          clearNavigation: true,
        ),
      );
      return;
    }

    emit(
      currentState.copyWith(
        pendingNavigation: QuizFlowRouteArgs.ticket(
          ticketId: selectedTicket.id,
        ),
        clearPrompt: true,
      ),
    );
  }

  void _onResumeRequested(
    TicketsResumeRequested event,
    Emitter<TicketsState> emit,
  ) {
    final currentState = state;
    if (currentState is! TicketsLoaded) {
      return;
    }

    emit(
      currentState.copyWith(
        clearPrompt: true,
        pendingNavigation: QuizFlowRouteArgs.ticket(
          ticketId: event.ticketId,
          startBehavior: QuizStartBehavior.resume,
        ),
      ),
    );
  }

  void _onRestartRequested(
    TicketsRestartRequested event,
    Emitter<TicketsState> emit,
  ) {
    final currentState = state;
    if (currentState is! TicketsLoaded) {
      return;
    }

    emit(
      currentState.copyWith(
        clearPrompt: true,
        pendingNavigation: QuizFlowRouteArgs.ticket(
          ticketId: event.ticketId,
          startBehavior: QuizStartBehavior.restartWithReset,
        ),
      ),
    );
  }

  void _onPromptDismissed(
    TicketsPromptDismissed event,
    Emitter<TicketsState> emit,
  ) {
    final currentState = state;
    if (currentState is! TicketsLoaded ||
        currentState.pendingResumePrompt == null) {
      return;
    }

    emit(currentState.copyWith(clearPrompt: true));
  }

  void _onNavigationHandled(
    TicketsNavigationHandled event,
    Emitter<TicketsState> emit,
  ) {
    final currentState = state;
    if (currentState is! TicketsLoaded ||
        currentState.pendingNavigation == null) {
      return;
    }

    emit(currentState.copyWith(clearNavigation: true));
  }
}
