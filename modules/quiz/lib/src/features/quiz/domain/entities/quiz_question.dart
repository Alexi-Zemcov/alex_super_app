import 'package:equatable/equatable.dart';

typedef QuestionKey = String;

class QuizQuestion extends Equatable {
  const QuizQuestion({
    required this.key,
    required this.category,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });

  final QuestionKey key;
  final String category;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  @override
  List<Object?> get props => [
    key,
    category,
    question,
    options,
    correctIndex,
    explanation,
  ];
}
