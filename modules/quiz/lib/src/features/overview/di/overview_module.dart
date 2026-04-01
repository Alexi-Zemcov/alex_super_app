import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/single_child_widget.dart';
import 'package:quiz/src/features/overview/presentation/screens/overview/bloc/overview_bloc.dart';
import 'package:quiz/src/features/overview/presentation/screens/overview/bloc/overview_event.dart';
import 'package:quiz/src/features/quiz/domain/entities/quiz_mode.dart';
import 'package:quiz/src/features/quiz/domain/repositories/progress_repository.dart';
import 'package:quiz/src/features/quiz/domain/repositories/question_repository.dart';
import 'package:scoped_di/scoped_di.dart';

class OverviewModule extends ScopeModule {
  const OverviewModule({required this.mode});

  final QuizMode mode;

  @override
  String get moduleId => 'OverviewModule:${mode.name}';

  @override
  List<SingleChildWidget> get providers => [
    BlocProvider<OverviewBloc>(
      create: (context) => OverviewBloc(
        mode: mode,
        questionRepository: context.read<QuestionRepository>(),
        progressRepository: context.read<ProgressRepository>(),
      )..add(const OverviewStarted()),
    ),
  ];
}
