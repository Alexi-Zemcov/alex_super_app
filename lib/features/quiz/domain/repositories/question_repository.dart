import '../entities/quiz_question.dart';
import '../entities/ticket.dart';
import '../entities/topic.dart';

abstract interface class QuestionRepository {
  Future<List<QuizQuestion>> getAllQuestions();

  Future<List<Ticket>> getTickets();

  Future<List<Topic>> getTopics();
}
