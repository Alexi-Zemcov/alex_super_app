import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quiz/src/features/overview/presentation/screens/overview/bloc/overview_event.dart';
import 'package:quiz/src/features/overview/presentation/screens/overview/bloc/overview_state.dart';
import 'package:quiz/src/features/quiz/domain/entities/quiz_mode.dart';
import 'package:quiz/src/features/quiz/domain/repositories/progress_repository.dart';
import 'package:quiz/src/features/quiz/domain/repositories/question_repository.dart';
import 'package:quiz/src/navigation/quiz_flow_intent.dart';

class OverviewBloc extends Bloc<OverviewEvent, OverviewState> {
  OverviewBloc({
    required QuizMode mode,
    required QuestionRepository questionRepository,
    required ProgressRepository progressRepository,
  }) : _mode = mode,
       _questionRepository = questionRepository,
       _progressRepository = progressRepository,
       super(const OverviewInitial()) {
    on<OverviewStarted>(_onStarted);
    on<OverviewStartPressed>(_onStartPressed);
    on<OverviewNavigationHandled>(_onNavigationHandled);
  }

  final QuizMode _mode;
  final QuestionRepository _questionRepository;
  final ProgressRepository _progressRepository;

  Future<void> _onStarted(
    OverviewStarted event,
    Emitter<OverviewState> emit,
  ) async {
    emit(const OverviewLoading());

    try {
      final count = await _loadCount();
      emit(OverviewLoaded(count: count));
    } catch (_) {
      emit(const OverviewFailure(message: 'Не удалось загрузить экран.'));
    }
  }

  Future<int> _loadCount() async {
    switch (_mode) {
      case QuizMode.marathon:
        final questions = await _questionRepository.getAllQuestions();
        return questions.length;
      case QuizMode.errors:
        final questions = await _questionRepository.getAllQuestions();
        final stats = await _progressRepository.getQuestionStats();
        return questions.where((question) {
          final stat = stats[question.key];
          return stat != null && stat.totalAttempts > stat.correctAttempts;
        }).length;
      case QuizMode.favorites:
        final questions = await _questionRepository.getAllQuestions();
        final favorites = await _progressRepository.getFavorites();
        return questions
            .where((question) => favorites.contains(question.key))
            .length;
      case QuizMode.ticket:
      case QuizMode.blitz:
      case QuizMode.topic:
        throw StateError('Unsupported overview mode: $_mode');
    }
  }

  void _onStartPressed(
    OverviewStartPressed event,
    Emitter<OverviewState> emit,
  ) {
    final currentState = state;
    if (currentState is! OverviewLoaded || currentState.isEmpty) {
      return;
    }

    final navigation = switch (_mode) {
      QuizMode.marathon => const QuizFlowIntent.marathon(),
      QuizMode.errors => const QuizFlowIntent.errors(),
      QuizMode.favorites => const QuizFlowIntent.favorites(),
      QuizMode.ticket || QuizMode.blitz || QuizMode.topic => null,
    };

    if (navigation == null) {
      return;
    }

    emit(currentState.copyWith(pendingNavigation: navigation));
  }

  void _onNavigationHandled(
    OverviewNavigationHandled event,
    Emitter<OverviewState> emit,
  ) {
    final currentState = state;
    if (currentState is! OverviewLoaded ||
        currentState.pendingNavigation == null) {
      return;
    }

    emit(currentState.copyWith(clearNavigation: true));
  }
}
