import 'package:quiz/src/features/quiz/domain/entities/question_stats.dart';
import 'package:quiz/src/features/quiz/domain/entities/quiz_answer.dart';
import 'package:quiz/src/features/quiz/domain/entities/quiz_mode.dart';
import 'package:quiz/src/features/quiz/domain/entities/quiz_question.dart';
import 'package:quiz/src/features/quiz/domain/entities/quiz_session.dart';
import 'package:quiz/src/features/quiz/domain/entities/ticket.dart';
import 'package:quiz/src/features/quiz/domain/entities/topic.dart';
import 'package:quiz/src/features/quiz/domain/repositories/progress_repository.dart';
import 'package:quiz/src/features/quiz/domain/repositories/question_repository.dart';
import 'package:quiz/src/features/quiz/domain/services/quiz_catalog_builder.dart';

QuizQuestion buildQuestion({
  required String category,
  required String question,
  int correctIndex = 0,
}) {
  return QuizQuestion(
    key: '$category|$question',
    category: category,
    question: question,
    options: const ['A', 'B', 'C', 'D'],
    correctIndex: correctIndex,
    explanation: 'Explanation for $question',
  );
}

List<QuizQuestion> buildQuestions(int count, {String category = 'Category'}) {
  return List<QuizQuestion>.generate(
    count,
    (index) => buildQuestion(
      category: '$category ${index % 2}',
      question: 'Question $index',
      correctIndex: index % 4,
    ),
    growable: false,
  );
}

class InMemoryQuestionRepository implements QuestionRepository {
  InMemoryQuestionRepository({
    required List<QuizQuestion> questions,
    QuizCatalogBuilder? catalogBuilder,
  }) : _questions = List<QuizQuestion>.unmodifiable(questions),
       _catalogBuilder = catalogBuilder ?? const QuizCatalogBuilder();

  final List<QuizQuestion> _questions;
  final QuizCatalogBuilder _catalogBuilder;

  @override
  Future<List<QuizQuestion>> getAllQuestions() async => _questions;

  @override
  Future<List<Ticket>> getTickets() async =>
      _catalogBuilder.buildTickets(_questions);

  @override
  Future<Ticket?> getTicketById(int id) async {
    final tickets = await getTickets();
    for (final ticket in tickets) {
      if (ticket.id == id) {
        return ticket;
      }
    }

    return null;
  }

  @override
  Future<List<Topic>> getTopics() async =>
      _catalogBuilder.buildTopics(_questions);

  @override
  Future<Topic?> getTopicById(int id) async {
    final topics = await getTopics();
    for (final topic in topics) {
      if (topic.id == id) {
        return topic;
      }
    }

    return null;
  }
}

class InMemoryProgressRepository implements ProgressRepository {
  InMemoryProgressRepository({
    Map<QuestionKey, QuestionStats>? questionStats,
    Set<QuestionKey>? favorites,
    this.ticketSession,
  }) : questionStats = {...?questionStats},
       favorites = {...?favorites};

  final Map<QuestionKey, QuestionStats> questionStats;
  final Set<QuestionKey> favorites;
  final List<QuizAnswer> recordedAnswers = <QuizAnswer>[];
  final List<List<QuestionKey>> clearedStatsBatches = <List<QuestionKey>>[];

  QuizSession? ticketSession;
  int clearTicketSessionCalls = 0;
  int saveTicketSessionCalls = 0;

  @override
  Future<void> clearStatsForQuestions(
    Iterable<QuestionKey> questionKeys,
  ) async {
    final keys = questionKeys.toList(growable: false);
    clearedStatsBatches.add(keys);
    for (final key in keys) {
      questionStats.remove(key);
    }
  }

  @override
  Future<void> clearTicketSession() async {
    clearTicketSessionCalls += 1;
    ticketSession = null;
  }

  @override
  Future<Set<QuestionKey>> getFavorites() async => {...favorites};

  @override
  Future<Map<QuestionKey, QuestionStats>> getQuestionStats() async => {
    ...questionStats,
  };

  @override
  Future<QuizSession?> loadTicketSession(int ticketId) async {
    if (ticketSession?.mode != QuizMode.ticket ||
        ticketSession?.ticketId != ticketId) {
      return null;
    }

    final answeredCount = ticketSession!.answers.whereType<QuizAnswer>().length;
    if (answeredCount == 0 ||
        answeredCount >= ticketSession!.currentQuestions.length) {
      return null;
    }

    return ticketSession;
  }

  @override
  Future<void> recordAnswer(QuizAnswer answer) async {
    recordedAnswers.add(answer);
    final stats =
        questionStats[answer.questionKey] ??
        const QuestionStats(correctAttempts: 0, totalAttempts: 0);
    questionStats[answer.questionKey] = QuestionStats(
      correctAttempts: stats.correctAttempts + (answer.isCorrect ? 1 : 0),
      totalAttempts: stats.totalAttempts + 1,
    );
  }

  @override
  Future<void> saveTicketSession(QuizSession session) async {
    saveTicketSessionCalls += 1;
    ticketSession = session;
  }

  @override
  Future<bool> toggleFavorite(QuestionKey questionKey) async {
    if (favorites.add(questionKey)) {
      return true;
    }

    favorites.remove(questionKey);
    return false;
  }
}
