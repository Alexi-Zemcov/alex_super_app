import 'package:quiz/src/features/quiz/domain/entities/question_stats.dart';
import 'package:quiz/src/features/quiz/domain/entities/quiz_answer.dart';
import 'package:quiz/src/features/quiz/domain/entities/quiz_mode.dart';
import 'package:quiz/src/features/quiz/domain/entities/quiz_question.dart';
import 'package:quiz/src/features/quiz/domain/entities/quiz_session.dart';
import 'package:quiz/src/features/quiz/domain/entities/quiz_start_behavior.dart';
import 'package:quiz/src/features/quiz/domain/entities/quiz_start_request.dart';
import 'package:quiz/src/features/quiz/domain/repositories/progress_repository.dart';
import 'package:quiz/src/features/quiz/domain/repositories/question_repository.dart';
import 'package:quiz/src/features/quiz/domain/services/quiz_question_randomizer.dart';
import 'package:quiz/src/features/quiz/domain/services/quiz_session_navigator.dart';

class StartQuizFlowUseCase {
  const StartQuizFlowUseCase({
    required QuestionRepository questionRepository,
    required ProgressRepository progressRepository,
    required QuizQuestionRandomizer questionRandomizer,
    required QuizSessionNavigator sessionNavigator,
  }) : _questionRepository = questionRepository,
       _progressRepository = progressRepository,
       _questionRandomizer = questionRandomizer,
       _sessionNavigator = sessionNavigator;

  final QuestionRepository _questionRepository;
  final ProgressRepository _progressRepository;
  final QuizQuestionRandomizer _questionRandomizer;
  final QuizSessionNavigator _sessionNavigator;

  Future<QuizSession> call(QuizStartRequest request) async {
    switch (request.mode) {
      case QuizMode.ticket:
        return _startTicket(request);
      case QuizMode.blitz:
        return _startBlitz();
      case QuizMode.topic:
        return _startTopic(request);
      case QuizMode.marathon:
        return _startMarathon();
      case QuizMode.errors:
        return _startErrors();
      case QuizMode.favorites:
        return _startFavorites();
    }
  }

  Future<QuizSession> _startTicket(QuizStartRequest request) async {
    final ticketId = request.ticketId;
    if (ticketId == null) {
      throw const QuizFlowStartFailure('Не удалось определить билет.');
    }

    final ticket = await _questionRepository.getTicketById(ticketId);
    if (ticket == null) {
      throw QuizFlowStartFailure('Билет $ticketId не найден.');
    }

    switch (request.startBehavior) {
      case QuizStartBehavior.resume:
        final session = await _progressRepository.loadTicketSession(ticketId);
        if (session != null) {
          return session.copyWith(
            currentIndex:
                _sessionNavigator.findFirstUnansweredIndex(session) ??
                session.currentIndex,
          );
        }
      case QuizStartBehavior.restartWithReset:
        await _progressRepository.clearTicketSession();
        await _progressRepository.clearStatsForQuestions(
          ticket.questions.map((question) => question.key),
        );
      case QuizStartBehavior.fresh:
        break;
    }

    return _createSession(
      mode: QuizMode.ticket,
      context: {QuizSession.ticketIdContextKey: ticket.id},
      questions: _questionRandomizer.shuffleOptions(ticket.questions),
    );
  }

  Future<QuizSession> _startBlitz() async {
    final questions = await _questionRepository.getAllQuestions();
    return _createSession(
      mode: QuizMode.blitz,
      context: const {},
      questions: _questionRandomizer.pickBlitzQuestions(questions),
    );
  }

  Future<QuizSession> _startTopic(QuizStartRequest request) async {
    final topicId = request.topicId;
    if (topicId == null) {
      throw const QuizFlowStartFailure('Не удалось определить тему.');
    }

    final topic = await _questionRepository.getTopicById(topicId);
    if (topic == null) {
      throw QuizFlowStartFailure('Тема $topicId не найдена.');
    }

    return _createSession(
      mode: QuizMode.topic,
      context: {
        QuizSession.topicIdContextKey: topic.id,
        QuizSession.topicNameContextKey: topic.name,
      },
      questions: _questionRandomizer.shuffleOptions(topic.questions),
    );
  }

  Future<QuizSession> _startMarathon() async {
    final questions = await _questionRepository.getAllQuestions();
    return _createSession(
      mode: QuizMode.marathon,
      context: const {},
      questions: _questionRandomizer.shuffleOptions(questions),
    );
  }

  Future<QuizSession> _startErrors() async {
    final questions = await _questionRepository.getAllQuestions();
    final stats = await _progressRepository.getQuestionStats();
    final filteredQuestions = questions.where(
      (question) => _hasErrors(stats[question.key]),
    );

    final preparedQuestions = _questionRandomizer.shuffleOptions(
      filteredQuestions.toList(growable: false),
    );

    if (preparedQuestions.isEmpty) {
      throw const QuizFlowStartFailure('Ошибок пока нет.');
    }

    return _createSession(
      mode: QuizMode.errors,
      context: const {},
      questions: preparedQuestions,
    );
  }

  Future<QuizSession> _startFavorites() async {
    final questions = await _questionRepository.getAllQuestions();
    final favorites = await _progressRepository.getFavorites();
    final filteredQuestions = questions.where(
      (question) => favorites.contains(question.key),
    );

    final preparedQuestions = _questionRandomizer.shuffleOptions(
      filteredQuestions.toList(growable: false),
    );

    if (preparedQuestions.isEmpty) {
      throw const QuizFlowStartFailure('Избранных вопросов пока нет.');
    }

    return _createSession(
      mode: QuizMode.favorites,
      context: const {},
      questions: preparedQuestions,
    );
  }

  QuizSession _createSession({
    required QuizMode mode,
    required Map<String, Object?> context,
    required List<QuizQuestion> questions,
  }) {
    return QuizSession(
      mode: mode,
      context: Map<String, Object?>.unmodifiable(context),
      currentQuestions: List<QuizQuestion>.unmodifiable(questions),
      answers: List<QuizAnswer?>.filled(questions.length, null),
      currentIndex: 0,
    );
  }

  bool _hasErrors(QuestionStats? stats) {
    if (stats == null) {
      return false;
    }

    return stats.totalAttempts > stats.correctAttempts;
  }
}

class QuizFlowStartFailure implements Exception {
  const QuizFlowStartFailure(this.message);

  final String message;
}
