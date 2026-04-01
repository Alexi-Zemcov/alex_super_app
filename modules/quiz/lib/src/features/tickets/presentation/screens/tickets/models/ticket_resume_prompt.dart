import 'package:equatable/equatable.dart';

class TicketResumePrompt extends Equatable {
  const TicketResumePrompt({
    required this.ticketId,
    required this.answeredCount,
    required this.totalCount,
  });

  final int ticketId;
  final int answeredCount;
  final int totalCount;

  @override
  List<Object?> get props => [ticketId, answeredCount, totalCount];
}
