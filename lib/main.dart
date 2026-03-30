import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'features/quiz/data/datasources/progress_local_data_source.dart';
import 'features/quiz/data/datasources/question_local_data_source.dart';
import 'features/quiz/data/repositories/progress_repository_impl.dart';
import 'features/quiz/data/repositories/question_repository_impl.dart';
import 'features/quiz/domain/services/quiz_catalog_builder.dart';
import 'features/theme/data/datasources/theme_local_data_source.dart';
import 'features/theme/data/repositories/theme_repository_impl.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final sharedPreferences = await SharedPreferences.getInstance();

  final questionRepository = QuestionRepositoryImpl(
    localDataSource: AssetQuestionLocalDataSource(
      assetBundle: rootBundle,
      assetPath: AssetQuestionLocalDataSource.defaultAssetPath,
    ),
    catalogBuilder: const QuizCatalogBuilder(),
  );

  final progressRepository = ProgressRepositoryImpl(
    localDataSource: SharedPreferencesProgressLocalDataSource(
      sharedPreferences: sharedPreferences,
    ),
  );

  final themeRepository = ThemeRepositoryImpl(
    localDataSource: SharedPreferencesThemeLocalDataSource(
      sharedPreferences: sharedPreferences,
    ),
  );

  runApp(
    App(
      questionRepository: questionRepository,
      progressRepository: progressRepository,
      themeRepository: themeRepository,
    ),
  );
}
