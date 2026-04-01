import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:quiz/src/features/quiz/domain/entities/quiz_answer.dart';
import 'package:quiz/src/features/quiz/domain/services/quiz_question_randomizer.dart';
import 'package:quiz/src/features/quiz/domain/services/quiz_result_builder.dart';
import 'package:quiz/src/features/quiz/domain/services/quiz_session_navigator.dart';
import 'package:quiz/src/features/quiz/domain/usecases/clear_ticket_session_use_case.dart';
import 'package:quiz/src/features/quiz/domain/usecases/get_favorites_use_case.dart';
import 'package:quiz/src/features/quiz/domain/usecases/start_quiz_flow_use_case.dart';
import 'package:quiz/src/features/quiz/domain/usecases/submit_answer_use_case.dart';
import 'package:quiz/src/features/quiz/domain/usecases/toggle_favorite_use_case.dart';
import 'package:quiz/src/features/quiz_flow/presentation/screens/quiz_flow/bloc/quiz_flow_bloc.dart';
import 'package:quiz/src/features/quiz_flow/presentation/screens/quiz_flow/bloc/quiz_flow_event.dart';
import 'package:quiz/src/features/quiz_flow/presentation/screens/quiz_flow/bloc/quiz_flow_state.dart';
import 'package:quiz/src/navigation/quiz_flow_route_args.dart';

import 'test_support.dart';

void main() {
  group('QuizFlowBloc', () {
    test(
      'prevents double answers and jumps only to answered questions',
      () async {
        final questionRepository = InMemoryQuestionRepository(
          questions: [
            buildQuestion(category: 'A', question: 'Q1'),
            buildQuestion(category: 'B', question: 'Q2'),
          ],
        );
        final progressRepository = InMemoryProgressRepository();
        final bloc = _buildBloc(
          questionRepository: questionRepository,
          progressRepository: progressRepository,
          routeArgs: const QuizFlowRouteArgs.marathon(),
        );

        bloc.add(const QuizFlowStarted());
        await _drainBloc();

        expect(bloc.state, isA<QuizFlowActive>());
        expect((bloc.state as QuizFlowActive).session.currentIndex, 0);

        bloc.add(const QuizQuestionRequested(1));
        await _drainBloc();
        expect((bloc.state as QuizFlowActive).session.currentIndex, 0);

        bloc.add(const QuizAnswerSelected(0));
        await _drainBloc();
        expect(progressRepository.recordedAnswers, hasLength(1));

        bloc.add(const QuizAnswerSelected(1));
        await _drainBloc();
        expect(progressRepository.recordedAnswers, hasLength(1));

        bloc.add(const QuizNextPressed());
        await _drainBloc();
        expect((bloc.state as QuizFlowActive).session.currentIndex, 1);

        await bloc.close();
      },
    );

    test(
      'finishes blitz on timeout without persisting timed out answers',
      () async {
        final questionRepository = InMemoryQuestionRepository(
          questions: buildQuestions(10),
        );
        final progressRepository = InMemoryProgressRepository();
        final bloc = _buildBloc(
          questionRepository: questionRepository,
          progressRepository: progressRepository,
          routeArgs: const QuizFlowRouteArgs.blitz(),
        );

        bloc.add(const QuizFlowStarted());
        await _drainBloc();

        for (var index = 0; index < 600; index += 1) {
          bloc.add(const QuizTimerTicked());
        }
        await _drainBloc();

        expect(bloc.state, isA<QuizFlowResults>());
        final results = bloc.state as QuizFlowResults;
        expect(results.result.correctCount, 0);
        expect(results.result.totalCount, 10);
        expect(
          results.session.answers.whereType<QuizAnswer>().every(
            (answer) => answer.timedOut,
          ),
          isTrue,
        );
        expect(progressRepository.recordedAnswers, isEmpty);

        await bloc.close();
      },
    );
  });
}

QuizFlowBloc _buildBloc({
  required InMemoryQuestionRepository questionRepository,
  required InMemoryProgressRepository progressRepository,
  required QuizFlowRouteArgs routeArgs,
}) {
  final startQuizFlow = StartQuizFlowUseCase(
    questionRepository: questionRepository,
    progressRepository: progressRepository,
    questionRandomizer: QuizQuestionRandomizer(random: Random(0)),
    sessionNavigator: const QuizSessionNavigator(),
  );

  return QuizFlowBloc(
    startRequest: routeArgs.toStartRequest(),
    startQuizFlow: startQuizFlow,
    submitAnswer: SubmitAnswerUseCase(progressRepository: progressRepository),
    getFavorites: GetFavoritesUseCase(progressRepository: progressRepository),
    toggleFavorite: ToggleFavoriteUseCase(
      progressRepository: progressRepository,
    ),
    clearTicketSession: ClearTicketSessionUseCase(
      progressRepository: progressRepository,
    ),
    sessionNavigator: const QuizSessionNavigator(),
    resultBuilder: const QuizResultBuilder(),
  );
}

Future<void> _drainBloc() async {
  await Future<void>.delayed(const Duration(milliseconds: 1));
  await Future<void>.delayed(const Duration(milliseconds: 1));
}
