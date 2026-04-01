import 'package:equatable/equatable.dart';
import 'package:quiz/src/features/quiz/domain/entities/quiz_mode.dart';
import 'package:quiz/src/features/quiz/domain/entities/quiz_start_behavior.dart';

class QuizStartRequest extends Equatable {
  const QuizStartRequest({
    required this.mode,
    this.startBehavior = QuizStartBehavior.fresh,
    this.ticketId,
    this.topicId,
  });

  final QuizMode mode;
  final QuizStartBehavior startBehavior;
  final int? ticketId;
  final int? topicId;

  QuizStartRequest freshRetryRequest() {
    return QuizStartRequest(mode: mode, ticketId: ticketId, topicId: topicId);
  }

  @override
  List<Object?> get props => [mode, startBehavior, ticketId, topicId];
}
