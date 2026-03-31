import 'package:quiz/src/features/quiz/domain/entities/quiz_question.dart';
import 'package:quiz/src/features/quiz/domain/entities/ticket.dart';
import 'package:quiz/src/features/quiz/domain/entities/topic.dart';

abstract interface class QuestionRepository {
  Future<List<QuizQuestion>> getAllQuestions();

  Future<List<Ticket>> getTickets();

  Future<List<Topic>> getTopics();
}
