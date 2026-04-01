import 'package:quiz/src/features/quiz/domain/entities/question_stats.dart';
import 'package:quiz/src/features/quiz/domain/entities/quiz_answer.dart';
import 'package:quiz/src/features/quiz/domain/entities/quiz_question.dart';
import 'package:quiz/src/features/quiz/domain/entities/quiz_session.dart';

abstract interface class ProgressRepository {
  Future<Map<QuestionKey, QuestionStats>> getQuestionStats();

  Future<void> recordAnswer(QuizAnswer answer);

  Future<Set<QuestionKey>> getFavorites();

  Future<bool> toggleFavorite(QuestionKey questionKey);

  Future<QuizSession?> loadTicketSession(int ticketId);

  Future<void> saveTicketSession(QuizSession session);

  Future<void> clearTicketSession();

  Future<void> clearStatsForQuestions(Iterable<QuestionKey> questionKeys);
}
