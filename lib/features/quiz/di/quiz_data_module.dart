import 'package:alex_super_app/app/di/app_bootstrap_dependencies.dart';
import 'package:alex_super_app/app/di/scope_module.dart';
import 'package:alex_super_app/features/quiz/data/datasources/progress_local_data_source.dart';
import 'package:alex_super_app/features/quiz/data/datasources/question_local_data_source.dart';
import 'package:alex_super_app/features/quiz/data/repositories/progress_repository_impl.dart';
import 'package:alex_super_app/features/quiz/data/repositories/question_repository_impl.dart';
import 'package:alex_super_app/features/quiz/domain/repositories/progress_repository.dart';
import 'package:alex_super_app/features/quiz/domain/repositories/question_repository.dart';
import 'package:alex_super_app/features/quiz/domain/services/quiz_catalog_builder.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

class QuizDataModule extends ScopeModule {
  const QuizDataModule();

  @override
  List<SingleChildWidget> get providers => [
    Provider<QuizCatalogBuilder>.value(value: const QuizCatalogBuilder()),
    Provider<QuestionLocalDataSource>(
      create: (context) => AssetQuestionLocalDataSource(
        assetBundle: context.read<AppBootstrapDependencies>().assetBundle,
        assetPath: AssetQuestionLocalDataSource.defaultAssetPath,
      ),
    ),
    Provider<ProgressLocalDataSource>(
      create: (context) => SharedPreferencesProgressLocalDataSource(
        sharedPreferences: context
            .read<AppBootstrapDependencies>()
            .sharedPreferences,
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
  ];
}
