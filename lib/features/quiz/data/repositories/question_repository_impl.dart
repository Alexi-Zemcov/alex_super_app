import '../../domain/entities/quiz_question.dart';
import '../../domain/entities/ticket.dart';
import '../../domain/entities/topic.dart';
import '../../domain/repositories/question_repository.dart';
import '../../domain/services/quiz_catalog_builder.dart';
import '../datasources/question_local_data_source.dart';

class QuestionRepositoryImpl implements QuestionRepository {
  QuestionRepositoryImpl({
    required QuestionLocalDataSource localDataSource,
    required QuizCatalogBuilder catalogBuilder,
  }) : _localDataSource = localDataSource,
       _catalogBuilder = catalogBuilder;

  final QuestionLocalDataSource _localDataSource;
  final QuizCatalogBuilder _catalogBuilder;

  Future<List<QuizQuestion>>? _cachedQuestions;

  @override
  Future<List<QuizQuestion>> getAllQuestions() {
    _cachedQuestions ??= _loadQuestions();
    return _cachedQuestions!;
  }

  @override
  Future<List<Ticket>> getTickets() async {
    final questions = await getAllQuestions();
    return _catalogBuilder.buildTickets(questions);
  }

  @override
  Future<List<Topic>> getTopics() async {
    final questions = await getAllQuestions();
    return _catalogBuilder.buildTopics(questions);
  }

  Future<List<QuizQuestion>> _loadQuestions() async {
    final models = await _localDataSource.loadQuestions();
    return List<QuizQuestion>.unmodifiable(
      models.map((model) => model.toEntity()),
    );
  }
}
