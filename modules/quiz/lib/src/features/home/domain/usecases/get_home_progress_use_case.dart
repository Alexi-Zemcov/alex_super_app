import 'package:quiz/src/features/home/domain/entities/home_progress.dart';
import 'package:quiz/src/features/quiz/domain/repositories/progress_repository.dart';
import 'package:quiz/src/features/quiz/domain/repositories/question_repository.dart';

class GetHomeProgressUseCase {
  const GetHomeProgressUseCase({
    required QuestionRepository questionRepository,
    required ProgressRepository progressRepository,
  }) : _questionRepository = questionRepository,
       _progressRepository = progressRepository;

  final QuestionRepository _questionRepository;
  final ProgressRepository _progressRepository;

  Future<HomeProgress> call() async {
    final questions = await _questionRepository.getAllQuestions();
    final tickets = await _questionRepository.getTickets();
    final topics = await _questionRepository.getTopics();
    final stats = await _progressRepository.getQuestionStats();

    final completedQuestions = questions
        .where((question) => stats[question.key]?.hasCorrectAttempt ?? false)
        .length;

    final completedTickets = tickets
        .where(
          (ticket) => ticket.questions.every(
            (question) => stats[question.key]?.hasCorrectAttempt ?? false,
          ),
        )
        .length;

    final completedTopics = topics
        .where(
          (topic) => topic.questions.every(
            (question) => stats[question.key]?.hasCorrectAttempt ?? false,
          ),
        )
        .length;

    return HomeProgress(
      completedQuestions: completedQuestions,
      totalQuestions: questions.length,
      completedTickets: completedTickets,
      totalTickets: tickets.length,
      completedTopics: completedTopics,
      totalTopics: topics.length,
    );
  }
}
