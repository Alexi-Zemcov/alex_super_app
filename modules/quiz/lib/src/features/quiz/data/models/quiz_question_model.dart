import 'package:quiz/src/features/quiz/domain/entities/quiz_question.dart';

class QuizQuestionModel {
  const QuizQuestionModel({
    required this.category,
    required this.question,
    required this.options,
    required this.correct,
    required this.explanation,
  });

  final String category;
  final String question;
  final List<String> options;
  final int correct;
  final String explanation;

  factory QuizQuestionModel.fromEntity(QuizQuestion entity) {
    return QuizQuestionModel(
      category: entity.category,
      question: entity.question,
      options: entity.options,
      correct: entity.correctIndex,
      explanation: entity.explanation,
    );
  }

  factory QuizQuestionModel.fromJson(Map<String, dynamic> json) {
    final options = (json['options'] as List<dynamic>? ?? const [])
        .map((option) => option.toString())
        .toList(growable: false);

    final correct = json['correct'];
    if (options.length != 4 || correct is! int || correct < 0 || correct > 3) {
      throw const FormatException('Question JSON has invalid answer options.');
    }

    return QuizQuestionModel(
      category: json['category'] as String? ?? '',
      question: json['question'] as String? ?? '',
      options: options,
      correct: correct,
      explanation: json['explanation'] as String? ?? '',
    );
  }

  QuizQuestion toEntity() {
    return QuizQuestion(
      key: '$category|$question',
      category: category,
      question: question,
      options: List<String>.unmodifiable(options),
      correctIndex: correct,
      explanation: explanation,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'question': question,
      'options': options,
      'correct': correct,
      'explanation': explanation,
    };
  }
}
