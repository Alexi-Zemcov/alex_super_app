import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import 'package:quiz/src/di/scope_module.dart';
import 'package:quiz/src/features/home/domain/usecases/get_home_progress_use_case.dart';
import 'package:quiz/src/features/home/presentation/bloc/home_bloc.dart';
import 'package:quiz/src/features/home/presentation/bloc/home_event.dart';
import 'package:quiz/src/features/quiz/domain/repositories/progress_repository.dart';
import 'package:quiz/src/features/quiz/domain/repositories/question_repository.dart';

class HomeModule extends ScopeModule {
  const HomeModule();

  @override
  List<SingleChildWidget> get providers => [
    Provider<GetHomeProgressUseCase>(
      create: (context) => GetHomeProgressUseCase(
        questionRepository: context.read<QuestionRepository>(),
        progressRepository: context.read<ProgressRepository>(),
      ),
    ),
    BlocProvider<HomeBloc>(
      create: (context) =>
          HomeBloc(getHomeProgress: context.read<GetHomeProgressUseCase>())
            ..add(const HomeStarted()),
    ),
  ];
}
