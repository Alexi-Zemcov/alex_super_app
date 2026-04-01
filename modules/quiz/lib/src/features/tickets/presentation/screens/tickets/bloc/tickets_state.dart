import 'package:equatable/equatable.dart';
import 'package:quiz/src/features/tickets/presentation/screens/tickets/models/ticket_list_item.dart';
import 'package:quiz/src/features/tickets/presentation/screens/tickets/models/ticket_resume_prompt.dart';
import 'package:quiz/src/navigation/quiz_flow_route_args.dart';

sealed class TicketsState extends Equatable {
  const TicketsState();

  @override
  List<Object?> get props => const [];
}

final class TicketsInitial extends TicketsState {
  const TicketsInitial();
}

final class TicketsLoading extends TicketsState {
  const TicketsLoading();
}

final class TicketsLoaded extends TicketsState {
  const TicketsLoaded({
    required this.tickets,
    this.pendingResumePrompt,
    this.pendingNavigation,
  });

  final List<TicketListItem> tickets;
  final TicketResumePrompt? pendingResumePrompt;
  final QuizFlowRouteArgs? pendingNavigation;

  TicketsLoaded copyWith({
    TicketResumePrompt? pendingResumePrompt,
    bool clearPrompt = false,
    QuizFlowRouteArgs? pendingNavigation,
    bool clearNavigation = false,
  }) {
    return TicketsLoaded(
      tickets: tickets,
      pendingResumePrompt: clearPrompt
          ? null
          : (pendingResumePrompt ?? this.pendingResumePrompt),
      pendingNavigation: clearNavigation
          ? null
          : (pendingNavigation ?? this.pendingNavigation),
    );
  }

  @override
  List<Object?> get props => [tickets, pendingResumePrompt, pendingNavigation];
}

final class TicketsFailure extends TicketsState {
  const TicketsFailure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
