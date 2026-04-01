import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:quiz/src/features/quiz/data/datasources/progress_local_data_source.dart';
import 'package:quiz/src/features/quiz/data/datasources/question_local_data_source.dart';
import 'package:quiz/src/features/quiz/data/repositories/progress_repository_impl.dart';
import 'package:quiz/src/features/quiz/data/repositories/question_repository_impl.dart';
import 'package:quiz/src/features/quiz/domain/repositories/progress_repository.dart';
import 'package:quiz/src/features/quiz/domain/repositories/question_repository.dart';
import 'package:quiz/src/features/quiz/domain/services/quiz_catalog_builder.dart';
import 'package:quiz/src/features/quiz/domain/services/quiz_question_randomizer.dart';
import 'package:quiz/src/features/quiz/domain/services/quiz_result_builder.dart';
import 'package:quiz/src/features/quiz/domain/services/quiz_session_navigator.dart';
import 'package:quiz/src/features/quiz/domain/usecases/clear_ticket_session_use_case.dart';
import 'package:quiz/src/features/quiz/domain/usecases/get_favorites_use_case.dart';
import 'package:quiz/src/features/quiz/domain/usecases/start_quiz_flow_use_case.dart';
import 'package:quiz/src/features/quiz/domain/usecases/submit_answer_use_case.dart';
import 'package:quiz/src/features/quiz/domain/usecases/toggle_favorite_use_case.dart';
import 'package:scoped_di/scoped_di.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuizDataModule extends ScopeModule {
  const QuizDataModule();

  @override
  List<SingleChildWidget> get providers => [
    Provider<QuizCatalogBuilder>.value(value: const QuizCatalogBuilder()),
    Provider<QuizSessionNavigator>.value(value: const QuizSessionNavigator()),
    Provider<QuizResultBuilder>.value(value: const QuizResultBuilder()),
    Provider<QuizQuestionRandomizer>(create: (_) => QuizQuestionRandomizer()),
    Provider<QuestionLocalDataSource>(
      create: (context) => AssetQuestionLocalDataSource(
        assetBundle: context.read<AssetBundle>(),
        assetPath: AssetQuestionLocalDataSource.defaultAssetPath,
      ),
    ),
    Provider<ProgressLocalDataSource>(
      create: (context) => SharedPreferencesProgressLocalDataSource(
        sharedPreferences: context.read<SharedPreferences>(),
      ),
    ),
    RepositoryProvider<QuestionRepository>(
      create: (context) => QuestionRepositoryImpl(
        localDataSource: context.read<QuestionLocalDataSource>(),
        catalogBuilder: context.read<QuizCatalogBuilder>(),
      ),
    ),
    RepositoryProvider<ProgressRepository>(
      create: (context) => ProgressRepositoryImpl(
        localDataSource: context.read<ProgressLocalDataSource>(),
      ),
    ),
    Provider<GetFavoritesUseCase>(
      create: (context) => GetFavoritesUseCase(
        progressRepository: context.read<ProgressRepository>(),
      ),
    ),
    Provider<ToggleFavoriteUseCase>(
      create: (context) => ToggleFavoriteUseCase(
        progressRepository: context.read<ProgressRepository>(),
      ),
    ),
    Provider<SubmitAnswerUseCase>(
      create: (context) => SubmitAnswerUseCase(
        progressRepository: context.read<ProgressRepository>(),
      ),
    ),
    Provider<ClearTicketSessionUseCase>(
      create: (context) => ClearTicketSessionUseCase(
        progressRepository: context.read<ProgressRepository>(),
      ),
    ),
    Provider<StartQuizFlowUseCase>(
      create: (context) => StartQuizFlowUseCase(
        questionRepository: context.read<QuestionRepository>(),
        progressRepository: context.read<ProgressRepository>(),
        questionRandomizer: context.read<QuizQuestionRandomizer>(),
        sessionNavigator: context.read<QuizSessionNavigator>(),
      ),
    ),
  ];
}
