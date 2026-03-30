import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../features/quiz/domain/repositories/progress_repository.dart';
import '../features/quiz/domain/repositories/question_repository.dart';
import '../features/theme/domain/repositories/theme_repository.dart';
import '../features/theme/domain/usecases/cycle_theme.dart';
import '../features/theme/domain/usecases/load_theme.dart';
import '../features/theme/domain/usecases/set_theme.dart';
import 'bloc/app_bloc.dart';
import 'bloc/app_event.dart';
import 'bloc/app_state.dart';
import 'router/app_route_names.dart';
import 'router/app_router.dart';

class App extends StatelessWidget {
  const App({
    super.key,
    required this.questionRepository,
    required this.progressRepository,
    required this.themeRepository,
  });

  final QuestionRepository questionRepository;
  final ProgressRepository progressRepository;
  final ThemeRepository themeRepository;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<QuestionRepository>.value(value: questionRepository),
        RepositoryProvider<ProgressRepository>.value(value: progressRepository),
        RepositoryProvider<ThemeRepository>.value(value: themeRepository),
      ],
      child: BlocProvider(
        create: (context) => AppBloc(
          loadTheme: LoadTheme(themeRepository),
          cycleTheme: CycleTheme(setTheme: SetTheme(themeRepository)),
        )..add(const AppStarted()),
        child: const AppView(),
      ),
    );
  }
}

class AppView extends StatelessWidget {
  const AppView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        return MaterialApp(
          title: 'Flutter Quiz',
          debugShowCheckedModeBanner: false,
          theme: state.themeData,
          initialRoute: AppRouteNames.home,
          onGenerateRoute: AppRouter.onGenerateRoute,
        );
      },
    );
  }
}
