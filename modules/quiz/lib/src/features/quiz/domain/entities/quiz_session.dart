import 'package:equatable/equatable.dart';

import 'package:quiz/src/features/quiz/domain/entities/quiz_answer.dart';
import 'package:quiz/src/features/quiz/domain/entities/quiz_mode.dart';
import 'package:quiz/src/features/quiz/domain/entities/quiz_question.dart';

class QuizSession extends Equatable {
  const QuizSession({
    required this.mode,
    required this.context,
    required this.currentQuestions,
    required this.answers,
    required this.currentIndex,
  });

  static const ticketIdContextKey = 'ticketId';
  static const topicIdContextKey = 'topicId';
  static const topicNameContextKey = 'topicName';

  final QuizMode mode;
  final Map<String, Object?> context;
  final List<QuizQuestion> currentQuestions;
  final List<QuizAnswer?> answers;
  final int currentIndex;

  QuizQuestion get currentQuestion => currentQuestions[currentIndex];

  QuizAnswer? get currentAnswer => answers[currentIndex];

  bool get isCompleted => answers.every((answer) => answer != null);

  int? get ticketId => _readInt(context[ticketIdContextKey]);

  int? get topicId => _readInt(context[topicIdContextKey]);

  String? get topicName {
    final value = context[topicNameContextKey];
    return value is String ? value : null;
  }

  QuizSession copyWith({
    Map<String, Object?>? context,
    List<QuizQuestion>? currentQuestions,
    List<QuizAnswer?>? answers,
    int? currentIndex,
  }) {
    return QuizSession(
      mode: mode,
      context: context ?? this.context,
      currentQuestions: currentQuestions ?? this.currentQuestions,
      answers: answers ?? this.answers,
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }

  static int? _readInt(Object? value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return null;
  }

  @override
  List<Object?> get props => [
    mode,
    context,
    currentQuestions,
    answers,
    currentIndex,
  ];
}
