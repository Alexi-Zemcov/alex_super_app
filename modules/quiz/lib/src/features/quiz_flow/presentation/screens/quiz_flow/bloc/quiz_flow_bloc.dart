import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quiz/src/features/quiz/domain/entities/quiz_answer.dart';
import 'package:quiz/src/features/quiz/domain/entities/quiz_mode.dart';
import 'package:quiz/src/features/quiz/domain/entities/quiz_session.dart';
import 'package:quiz/src/features/quiz/domain/entities/quiz_start_request.dart';
import 'package:quiz/src/features/quiz/domain/services/quiz_result_builder.dart';
import 'package:quiz/src/features/quiz/domain/services/quiz_session_navigator.dart';
import 'package:quiz/src/features/quiz/domain/usecases/clear_ticket_session_use_case.dart';
import 'package:quiz/src/features/quiz/domain/usecases/get_favorites_use_case.dart';
import 'package:quiz/src/features/quiz/domain/usecases/start_quiz_flow_use_case.dart';
import 'package:quiz/src/features/quiz/domain/usecases/submit_answer_use_case.dart';
import 'package:quiz/src/features/quiz/domain/usecases/toggle_favorite_use_case.dart';
import 'package:quiz/src/features/quiz_flow/presentation/screens/quiz_flow/bloc/quiz_flow_event.dart';
import 'package:quiz/src/features/quiz_flow/presentation/screens/quiz_flow/bloc/quiz_flow_state.dart';

class QuizFlowBloc extends Bloc<QuizFlowEvent, QuizFlowState> {
  QuizFlowBloc({
    required QuizStartRequest startRequest,
    required StartQuizFlowUseCase startQuizFlow,
    required SubmitAnswerUseCase submitAnswer,
    required GetFavoritesUseCase getFavorites,
    required ToggleFavoriteUseCase toggleFavorite,
    required ClearTicketSessionUseCase clearTicketSession,
    required QuizSessionNavigator sessionNavigator,
    required QuizResultBuilder resultBuilder,
  }) : _startRequest = startRequest,
       _startQuizFlow = startQuizFlow,
       _submitAnswer = submitAnswer,
       _getFavorites = getFavorites,
       _toggleFavorite = toggleFavorite,
       _clearTicketSession = clearTicketSession,
       _sessionNavigator = sessionNavigator,
       _resultBuilder = resultBuilder,
       super(const QuizFlowLoading()) {
    on<QuizFlowStarted>(_onStarted);
    on<QuizAnswerSelected>(_onAnswerSelected);
    on<QuizQuestionRequested>(_onQuestionRequested);
    on<QuizNextPressed>(_onNextPressed);
    on<QuizFavoriteToggled>(_onFavoriteToggled);
    on<QuizRetryPressed>(_onRetryPressed);
    on<QuizTimerTicked>(_onTimerTicked);
  }

  static const _blitzDurationSeconds = 600;

  QuizStartRequest _startRequest;
  final StartQuizFlowUseCase _startQuizFlow;
  final SubmitAnswerUseCase _submitAnswer;
  final GetFavoritesUseCase _getFavorites;
  final ToggleFavoriteUseCase _toggleFavorite;
  final ClearTicketSessionUseCase _clearTicketSession;
  final QuizSessionNavigator _sessionNavigator;
  final QuizResultBuilder _resultBuilder;

  Timer? _timer;

  Future<void> _onStarted(
    QuizFlowStarted event,
    Emitter<QuizFlowState> emit,
  ) async {
    await _load(emit);
  }

  Future<void> _onRetryPressed(
    QuizRetryPressed event,
    Emitter<QuizFlowState> emit,
  ) async {
    _startRequest = _startRequest.freshRetryRequest();
    await _load(emit);
  }

  Future<void> _load(Emitter<QuizFlowState> emit) async {
    _cancelTimer();
    emit(const QuizFlowLoading());

    try {
      final session = await _startQuizFlow(_startRequest);
      final favorites = await _getFavorites();
      final isBlitz = session.mode == QuizMode.blitz;

      emit(
        QuizFlowActive(
          session: session,
          favorites: favorites,
          remainingSeconds: isBlitz ? _blitzDurationSeconds : null,
        ),
      );

      if (isBlitz) {
        _startTimer();
      }
    } on QuizFlowStartFailure catch (error) {
      emit(QuizFlowFailure(message: error.message));
    } catch (_) {
      emit(const QuizFlowFailure(message: 'Не удалось запустить режим.'));
    }
  }

  Future<void> _onAnswerSelected(
    QuizAnswerSelected event,
    Emitter<QuizFlowState> emit,
  ) async {
    final currentState = state;
    if (currentState is! QuizFlowActive) {
      return;
    }

    if (currentState.session.currentAnswer != null) {
      return;
    }

    final updatedSession = await _submitAnswer(
      session: currentState.session,
      selectedIndex: event.selectedIndex,
    );

    emit(currentState.copyWith(session: updatedSession));
  }

  void _onQuestionRequested(
    QuizQuestionRequested event,
    Emitter<QuizFlowState> emit,
  ) {
    final currentState = state;
    if (currentState is! QuizFlowActive) {
      return;
    }

    if (!_sessionNavigator.canOpenQuestion(currentState.session, event.index)) {
      return;
    }

    if (event.index == currentState.session.currentIndex) {
      return;
    }

    emit(
      currentState.copyWith(
        session: currentState.session.copyWith(currentIndex: event.index),
      ),
    );
  }

  Future<void> _onNextPressed(
    QuizNextPressed event,
    Emitter<QuizFlowState> emit,
  ) async {
    final currentState = state;
    if (currentState is! QuizFlowActive) {
      return;
    }

    if (currentState.session.currentAnswer == null) {
      return;
    }

    final nextIndex = _sessionNavigator.findNextUnansweredIndex(
      currentState.session,
    );
    if (nextIndex != null) {
      emit(
        currentState.copyWith(
          session: currentState.session.copyWith(currentIndex: nextIndex),
        ),
      );
      return;
    }

    await _showResults(currentState.session, emit);
  }

  Future<void> _onFavoriteToggled(
    QuizFavoriteToggled event,
    Emitter<QuizFlowState> emit,
  ) async {
    final currentState = state;
    if (currentState is! QuizFlowActive) {
      return;
    }

    final questionKey = currentState.session.currentQuestion.key;
    final wasAdded = await _toggleFavorite(questionKey);
    final updatedFavorites = {...currentState.favorites};

    if (wasAdded) {
      updatedFavorites.add(questionKey);
    } else {
      updatedFavorites.remove(questionKey);
    }

    emit(currentState.copyWith(favorites: updatedFavorites));
  }

  Future<void> _onTimerTicked(
    QuizTimerTicked event,
    Emitter<QuizFlowState> emit,
  ) async {
    final currentState = state;
    if (currentState is! QuizFlowActive ||
        currentState.remainingSeconds == null) {
      return;
    }

    if (currentState.remainingSeconds! <= 1) {
      final completedSession = _markRemainingAnswersAsTimedOut(
        currentState.session,
      );
      await _showResults(completedSession, emit);
      return;
    }

    emit(
      currentState.copyWith(
        remainingSeconds: currentState.remainingSeconds! - 1,
      ),
    );
  }

  QuizSession _markRemainingAnswersAsTimedOut(QuizSession session) {
    final answers = [...session.answers];
    for (var index = 0; index < answers.length; index += 1) {
      if (answers[index] != null) {
        continue;
      }

      final question = session.currentQuestions[index];
      answers[index] = QuizAnswer(
        questionKey: question.key,
        category: question.category,
        selectedIndex: -1,
        isCorrect: false,
        timedOut: true,
      );
    }

    return session.copyWith(answers: List<QuizAnswer?>.unmodifiable(answers));
  }

  Future<void> _showResults(
    QuizSession session,
    Emitter<QuizFlowState> emit,
  ) async {
    _cancelTimer();
    if (session.mode == QuizMode.ticket) {
      await _clearTicketSession();
    }

    emit(
      QuizFlowResults(session: session, result: _resultBuilder.build(session)),
    );
  }

  void _startTimer() {
    _cancelTimer();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      add(const QuizTimerTicked());
    });
  }

  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }

  bool get requiresExitConfirmation => state is QuizFlowActive;

  @override
  Future<void> close() {
    _cancelTimer();
    return super.close();
  }
}
