import 'dart:math';

import 'package:quiz/src/features/quiz/domain/entities/quiz_question.dart';

class QuizQuestionRandomizer {
  QuizQuestionRandomizer({Random? random}) : _random = random ?? Random();

  static const defaultBlitzSize = 10;

  final Random _random;

  List<QuizQuestion> shuffleOptions(List<QuizQuestion> questions) {
    return List<QuizQuestion>.unmodifiable(
      questions.map(_shuffleQuestionOptions),
    );
  }

  List<QuizQuestion> pickBlitzQuestions(
    List<QuizQuestion> questions, {
    int size = defaultBlitzSize,
  }) {
    final shuffledQuestions = [...questions];
    _shuffleInPlace(shuffledQuestions);

    final pickedQuestions = shuffledQuestions
        .take(size)
        .toList(growable: false);
    return shuffleOptions(pickedQuestions);
  }

  QuizQuestion _shuffleQuestionOptions(QuizQuestion question) {
    final indexedOptions = question.options.asMap().entries.toList(
      growable: false,
    );
    final shuffledOptions = [...indexedOptions];
    _shuffleInPlace(shuffledOptions);

    var correctIndex = 0;
    final options = <String>[];

    for (var index = 0; index < shuffledOptions.length; index += 1) {
      final entry = shuffledOptions[index];
      options.add(entry.value);
      if (entry.key == question.correctIndex) {
        correctIndex = index;
      }
    }

    return QuizQuestion(
      key: question.key,
      category: question.category,
      question: question.question,
      options: List<String>.unmodifiable(options),
      correctIndex: correctIndex,
      explanation: question.explanation,
    );
  }

  void _shuffleInPlace<T>(List<T> items) {
    for (var index = items.length - 1; index > 0; index -= 1) {
      final swapIndex = _random.nextInt(index + 1);
      final currentValue = items[index];
      items[index] = items[swapIndex];
      items[swapIndex] = currentValue;
    }
  }
}
