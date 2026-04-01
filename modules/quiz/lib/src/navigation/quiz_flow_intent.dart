import 'package:equatable/equatable.dart';
import 'package:quiz/src/features/quiz/domain/entities/quiz_mode.dart';
import 'package:quiz/src/features/quiz/domain/entities/quiz_start_behavior.dart';
import 'package:quiz/src/features/quiz/domain/entities/quiz_start_request.dart';

class QuizFlowIntent extends Equatable {
  const QuizFlowIntent._({
    required this.mode,
    required this.startBehavior,
    this.ticketId,
    this.topicId,
  });

  const QuizFlowIntent.ticket({
    required int ticketId,
    QuizStartBehavior startBehavior = QuizStartBehavior.fresh,
  }) : this._(
         mode: QuizMode.ticket,
         startBehavior: startBehavior,
         ticketId: ticketId,
       );

  const QuizFlowIntent.blitz()
    : this._(mode: QuizMode.blitz, startBehavior: QuizStartBehavior.fresh);

  const QuizFlowIntent.topic({required int topicId})
    : this._(
        mode: QuizMode.topic,
        startBehavior: QuizStartBehavior.fresh,
        topicId: topicId,
      );

  const QuizFlowIntent.marathon()
    : this._(mode: QuizMode.marathon, startBehavior: QuizStartBehavior.fresh);

  const QuizFlowIntent.errors()
    : this._(mode: QuizMode.errors, startBehavior: QuizStartBehavior.fresh);

  const QuizFlowIntent.favorites()
    : this._(mode: QuizMode.favorites, startBehavior: QuizStartBehavior.fresh);

  final QuizMode mode;
  final QuizStartBehavior startBehavior;
  final int? ticketId;
  final int? topicId;

  QuizFlowIntent freshRetryIntent() {
    switch (mode) {
      case QuizMode.ticket:
        return QuizFlowIntent.ticket(ticketId: ticketId!);
      case QuizMode.blitz:
        return const QuizFlowIntent.blitz();
      case QuizMode.topic:
        return QuizFlowIntent.topic(topicId: topicId!);
      case QuizMode.marathon:
        return const QuizFlowIntent.marathon();
      case QuizMode.errors:
        return const QuizFlowIntent.errors();
      case QuizMode.favorites:
        return const QuizFlowIntent.favorites();
    }
  }

  @override
  List<Object?> get props => [mode, startBehavior, ticketId, topicId];
}

extension QuizFlowIntentX on QuizFlowIntent {
  QuizStartRequest toStartRequest() {
    return QuizStartRequest(
      mode: mode,
      startBehavior: startBehavior,
      ticketId: ticketId,
      topicId: topicId,
    );
  }
}

extension QuizStartBehaviorQueryX on QuizStartBehavior {
  String? get queryValue {
    return switch (this) {
      QuizStartBehavior.fresh => null,
      QuizStartBehavior.resume => QuizStartBehavior.resume.name,
      QuizStartBehavior.restartWithReset =>
        QuizStartBehavior.restartWithReset.name,
    };
  }
}

QuizStartBehavior quizStartBehaviorFromQuery(String? value) {
  if (value == null || value.isEmpty) {
    return QuizStartBehavior.fresh;
  }

  return QuizStartBehavior.values.firstWhere(
    (behavior) => behavior.name == value,
    orElse: () => QuizStartBehavior.fresh,
  );
}
