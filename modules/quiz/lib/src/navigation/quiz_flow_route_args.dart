import 'package:equatable/equatable.dart';
import 'package:quiz/src/features/quiz/domain/entities/quiz_mode.dart';
import 'package:quiz/src/features/quiz/domain/entities/quiz_start_behavior.dart';
import 'package:quiz/src/features/quiz/domain/entities/quiz_start_request.dart';

class QuizFlowRouteArgs extends Equatable {
  const QuizFlowRouteArgs._({
    required this.mode,
    required this.startBehavior,
    this.ticketId,
    this.topicId,
  });

  const QuizFlowRouteArgs.ticket({
    required int ticketId,
    QuizStartBehavior startBehavior = QuizStartBehavior.fresh,
  }) : this._(
         mode: QuizMode.ticket,
         startBehavior: startBehavior,
         ticketId: ticketId,
       );

  const QuizFlowRouteArgs.blitz()
    : this._(mode: QuizMode.blitz, startBehavior: QuizStartBehavior.fresh);

  const QuizFlowRouteArgs.topic({required int topicId})
    : this._(
        mode: QuizMode.topic,
        startBehavior: QuizStartBehavior.fresh,
        topicId: topicId,
      );

  const QuizFlowRouteArgs.marathon()
    : this._(mode: QuizMode.marathon, startBehavior: QuizStartBehavior.fresh);

  const QuizFlowRouteArgs.errors()
    : this._(mode: QuizMode.errors, startBehavior: QuizStartBehavior.fresh);

  const QuizFlowRouteArgs.favorites()
    : this._(mode: QuizMode.favorites, startBehavior: QuizStartBehavior.fresh);

  final QuizMode mode;
  final QuizStartBehavior startBehavior;
  final int? ticketId;
  final int? topicId;

  QuizFlowRouteArgs freshRetryArgs() {
    switch (mode) {
      case QuizMode.ticket:
        return QuizFlowRouteArgs.ticket(ticketId: ticketId!);
      case QuizMode.blitz:
        return const QuizFlowRouteArgs.blitz();
      case QuizMode.topic:
        return QuizFlowRouteArgs.topic(topicId: topicId!);
      case QuizMode.marathon:
        return const QuizFlowRouteArgs.marathon();
      case QuizMode.errors:
        return const QuizFlowRouteArgs.errors();
      case QuizMode.favorites:
        return const QuizFlowRouteArgs.favorites();
    }
  }

  @override
  List<Object?> get props => [mode, startBehavior, ticketId, topicId];
}

extension QuizFlowRouteArgsX on QuizFlowRouteArgs {
  QuizStartRequest toStartRequest() {
    return QuizStartRequest(
      mode: mode,
      startBehavior: startBehavior,
      ticketId: ticketId,
      topicId: topicId,
    );
  }
}
