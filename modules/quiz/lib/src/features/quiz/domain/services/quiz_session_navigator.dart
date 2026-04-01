import 'package:quiz/src/features/quiz/domain/entities/quiz_session.dart';

class QuizSessionNavigator {
  const QuizSessionNavigator();

  bool canOpenQuestion(QuizSession session, int index) {
    if (index < 0 || index >= session.currentQuestions.length) {
      return false;
    }

    return index == session.currentIndex || session.answers[index] != null;
  }

  int? findFirstUnansweredIndex(QuizSession session) {
    for (var index = 0; index < session.answers.length; index += 1) {
      if (session.answers[index] == null) {
        return index;
      }
    }

    return null;
  }

  int? findNextUnansweredIndex(QuizSession session) {
    for (
      var index = session.currentIndex + 1;
      index < session.answers.length;
      index += 1
    ) {
      if (session.answers[index] == null) {
        return index;
      }
    }

    for (var index = 0; index < session.currentIndex; index += 1) {
      if (session.answers[index] == null) {
        return index;
      }
    }

    return null;
  }
}
