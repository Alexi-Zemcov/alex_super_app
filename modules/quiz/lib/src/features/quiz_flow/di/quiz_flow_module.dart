import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/single_child_widget.dart';
import 'package:quiz/src/features/quiz/domain/services/quiz_result_builder.dart';
import 'package:quiz/src/features/quiz/domain/services/quiz_session_navigator.dart';
import 'package:quiz/src/features/quiz/domain/usecases/clear_ticket_session_use_case.dart';
import 'package:quiz/src/features/quiz/domain/usecases/get_favorites_use_case.dart';
import 'package:quiz/src/features/quiz/domain/usecases/start_quiz_flow_use_case.dart';
import 'package:quiz/src/features/quiz/domain/usecases/submit_answer_use_case.dart';
import 'package:quiz/src/features/quiz/domain/usecases/toggle_favorite_use_case.dart';
import 'package:quiz/src/features/quiz_flow/presentation/screens/quiz_flow/bloc/quiz_flow_bloc.dart';
import 'package:quiz/src/features/quiz_flow/presentation/screens/quiz_flow/bloc/quiz_flow_event.dart';
import 'package:quiz/src/navigation/quiz_flow_intent.dart';
import 'package:scoped_di/scoped_di.dart';

class QuizFlowModule extends ScopeModule {
  const QuizFlowModule({required this.intent});

  final QuizFlowIntent intent;

  @override
  String get moduleId =>
      'QuizFlowModule:${intent.mode.name}:${intent.startBehavior.name}:${intent.ticketId}:${intent.topicId}';

  @override
  List<SingleChildWidget> get providers => [
    BlocProvider<QuizFlowBloc>(
      create: (context) => QuizFlowBloc(
        startRequest: intent.toStartRequest(),
        startQuizFlow: context.read<StartQuizFlowUseCase>(),
        submitAnswer: context.read<SubmitAnswerUseCase>(),
        getFavorites: context.read<GetFavoritesUseCase>(),
        toggleFavorite: context.read<ToggleFavoriteUseCase>(),
        clearTicketSession: context.read<ClearTicketSessionUseCase>(),
        sessionNavigator: context.read<QuizSessionNavigator>(),
        resultBuilder: context.read<QuizResultBuilder>(),
      )..add(const QuizFlowStarted()),
    ),
  ];
}
