import 'package:equatable/equatable.dart';

sealed class TicketsEvent extends Equatable {
  const TicketsEvent();

  @override
  List<Object?> get props => const [];
}

final class TicketsStarted extends TicketsEvent {
  const TicketsStarted();
}

final class TicketPressed extends TicketsEvent {
  const TicketPressed(this.ticketId);

  final int ticketId;

  @override
  List<Object?> get props => [ticketId];
}

final class TicketsResumeRequested extends TicketsEvent {
  const TicketsResumeRequested(this.ticketId);

  final int ticketId;

  @override
  List<Object?> get props => [ticketId];
}

final class TicketsRestartRequested extends TicketsEvent {
  const TicketsRestartRequested(this.ticketId);

  final int ticketId;

  @override
  List<Object?> get props => [ticketId];
}

final class TicketsPromptDismissed extends TicketsEvent {
  const TicketsPromptDismissed();
}

final class TicketsNavigationHandled extends TicketsEvent {
  const TicketsNavigationHandled();
}
