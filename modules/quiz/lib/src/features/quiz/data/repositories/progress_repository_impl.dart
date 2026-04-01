import 'package:quiz/src/features/quiz/data/datasources/progress_local_data_source.dart';
import 'package:quiz/src/features/quiz/data/models/quiz_question_model.dart';
import 'package:quiz/src/features/quiz/domain/entities/question_stats.dart';
import 'package:quiz/src/features/quiz/domain/entities/quiz_answer.dart';
import 'package:quiz/src/features/quiz/domain/entities/quiz_mode.dart';
import 'package:quiz/src/features/quiz/domain/entities/quiz_question.dart';
import 'package:quiz/src/features/quiz/domain/entities/quiz_session.dart';
import 'package:quiz/src/features/quiz/domain/repositories/progress_repository.dart';

class ProgressRepositoryImpl implements ProgressRepository {
  ProgressRepositoryImpl({required ProgressLocalDataSource localDataSource})
    : _localDataSource = localDataSource;

  final ProgressLocalDataSource _localDataSource;

  @override
  Future<Map<QuestionKey, QuestionStats>> getQuestionStats() async {
    final rawStats = await _localDataSource.loadQuestionStats();
    return rawStats.map(
      (key, value) => MapEntry(key, QuestionStats.fromStorageMap(value)),
    );
  }

  @override
  Future<void> recordAnswer(QuizAnswer answer) async {
    final rawStats = Map<String, Map<String, dynamic>>.from(
      await _localDataSource.loadQuestionStats(),
    );
    final currentStats =
        rawStats[answer.questionKey] ?? const <String, dynamic>{};
    final nextCorrectAttempts =
        _readInt(currentStats['correct']) + (answer.isCorrect ? 1 : 0);
    final nextTotalAttempts = _readInt(currentStats['total']) + 1;

    rawStats[answer.questionKey] = {
      'correct': nextCorrectAttempts,
      'total': nextTotalAttempts,
    };

    await _localDataSource.saveQuestionStats(rawStats);
  }

  @override
  Future<Set<QuestionKey>> getFavorites() async {
    return _localDataSource.loadFavorites();
  }

  @override
  Future<bool> toggleFavorite(QuestionKey questionKey) async {
    final favorites = await _localDataSource.loadFavorites();
    final mutableFavorites = {...favorites};
    final wasAdded = mutableFavorites.add(questionKey);

    if (!wasAdded) {
      mutableFavorites.remove(questionKey);
    }

    await _localDataSource.saveFavorites(mutableFavorites);
    return wasAdded;
  }

  @override
  Future<QuizSession?> loadTicketSession(int ticketId) async {
    final rawSession = await _localDataSource.loadTicketSession();
    if (rawSession == null) {
      return null;
    }

    final mode = parseQuizMode(rawSession['mode'] as String?);
    if (mode != QuizMode.ticket) {
      return null;
    }

    final rawContext = rawSession['context'];
    if (rawContext is! Map<dynamic, dynamic>) {
      return null;
    }

    final context = Map<String, Object?>.from(rawContext);
    final savedTicketId = QuizSession(
      mode: QuizMode.ticket,
      context: context,
      currentQuestions: const [],
      answers: const [],
      currentIndex: 0,
    ).ticketId;

    if (savedTicketId != ticketId) {
      return null;
    }

    final rawQuestions = rawSession['currentQuestions'];
    final rawAnswers = rawSession['answers'];

    if (rawQuestions is! List<dynamic> || rawAnswers is! List<dynamic>) {
      return null;
    }

    final questions = rawQuestions
        .map((item) {
          return QuizQuestionModel.fromJson(
            Map<String, dynamic>.from(item as Map<dynamic, dynamic>),
          ).toEntity();
        })
        .toList(growable: false);

    final answers = rawAnswers.map(_deserializeAnswer).toList(growable: false);
    if (questions.isEmpty || answers.length != questions.length) {
      return null;
    }

    final answeredCount = answers.whereType<QuizAnswer>().length;
    if (answeredCount == 0 || answeredCount >= questions.length) {
      return null;
    }

    return QuizSession(
      mode: QuizMode.ticket,
      context: Map<String, Object?>.unmodifiable(context),
      currentQuestions: List<QuizQuestion>.unmodifiable(questions),
      answers: List<QuizAnswer?>.unmodifiable(answers),
      currentIndex: _readInt(
        rawSession['currentIndex'],
      ).clamp(0, questions.length - 1),
    );
  }

  @override
  Future<void> saveTicketSession(QuizSession session) async {
    if (session.mode != QuizMode.ticket) {
      return;
    }

    await _localDataSource.saveTicketSession({
      'mode': session.mode.storageValue,
      'context': session.context,
      'currentQuestions': session.currentQuestions
          .map((question) => QuizQuestionModel.fromEntity(question).toJson())
          .toList(growable: false),
      'answers': session.answers.map(_serializeAnswer).toList(growable: false),
      'currentIndex': session.currentIndex,
    });
  }

  @override
  Future<void> clearTicketSession() {
    return _localDataSource.clearTicketSession();
  }

  @override
  Future<void> clearStatsForQuestions(
    Iterable<QuestionKey> questionKeys,
  ) async {
    final rawStats = Map<String, Map<String, dynamic>>.from(
      await _localDataSource.loadQuestionStats(),
    );
    for (final questionKey in questionKeys) {
      rawStats.remove(questionKey);
    }

    await _localDataSource.saveQuestionStats(rawStats);
  }

  QuizAnswer? _deserializeAnswer(Object? rawAnswer) {
    if (rawAnswer == null) {
      return null;
    }

    if (rawAnswer is! Map<dynamic, dynamic>) {
      return null;
    }

    final answer = Map<String, dynamic>.from(rawAnswer);
    final questionKey = answer['questionKey'];
    final category = answer['category'];
    final selectedIndex = answer['selectedIndex'];
    final isCorrect = answer['correct'];

    if (questionKey is! String ||
        category is! String ||
        selectedIndex is! int ||
        isCorrect is! bool) {
      return null;
    }

    return QuizAnswer(
      questionKey: questionKey,
      category: category,
      selectedIndex: selectedIndex,
      isCorrect: isCorrect,
      timedOut: answer['timedOut'] == true,
    );
  }

  Object? _serializeAnswer(QuizAnswer? answer) {
    if (answer == null) {
      return null;
    }

    return {
      'questionKey': answer.questionKey,
      'category': answer.category,
      'selectedIndex': answer.selectedIndex,
      'correct': answer.isCorrect,
      if (answer.timedOut) 'timedOut': true,
    };
  }

  int _readInt(Object? value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return 0;
  }
}
