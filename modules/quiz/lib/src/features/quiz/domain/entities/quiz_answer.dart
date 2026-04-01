import 'package:equatable/equatable.dart';

import 'package:quiz/src/features/quiz/domain/entities/quiz_question.dart';

class QuizAnswer extends Equatable {
  const QuizAnswer({
    required this.questionKey,
    required this.category,
    required this.selectedIndex,
    required this.isCorrect,
    this.timedOut = false,
  });

  final QuestionKey questionKey;
  final String category;
  final int selectedIndex;
  final bool isCorrect;
  final bool timedOut;

  @override
  List<Object?> get props => [
    questionKey,
    category,
    selectedIndex,
    isCorrect,
    timedOut,
  ];
}
