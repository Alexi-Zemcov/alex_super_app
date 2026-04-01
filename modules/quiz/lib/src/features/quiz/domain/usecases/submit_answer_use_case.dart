import 'package:quiz/src/features/quiz/domain/entities/quiz_answer.dart';
import 'package:quiz/src/features/quiz/domain/entities/quiz_mode.dart';
import 'package:quiz/src/features/quiz/domain/entities/quiz_session.dart';
import 'package:quiz/src/features/quiz/domain/repositories/progress_repository.dart';

class SubmitAnswerUseCase {
  const SubmitAnswerUseCase({required ProgressRepository progressRepository})
    : _progressRepository = progressRepository;

  final ProgressRepository _progressRepository;

  Future<QuizSession> call({
    required QuizSession session,
    required int selectedIndex,
  }) async {
    if (selectedIndex < 0 ||
        selectedIndex >= session.currentQuestion.options.length) {
      return session;
    }

    if (session.currentAnswer != null) {
      return session;
    }

    final answer = QuizAnswer(
      questionKey: session.currentQuestion.key,
      category: session.currentQuestion.category,
      selectedIndex: selectedIndex,
      isCorrect: selectedIndex == session.currentQuestion.correctIndex,
    );

    final answers = [...session.answers];
    answers[session.currentIndex] = answer;

    final updatedSession = session.copyWith(
      answers: List<QuizAnswer?>.unmodifiable(answers),
    );

    await _progressRepository.recordAnswer(answer);

    if (session.mode == QuizMode.ticket) {
      await _progressRepository.saveTicketSession(updatedSession);
    }

    return updatedSession;
  }
}
