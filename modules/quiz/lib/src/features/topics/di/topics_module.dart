import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/single_child_widget.dart';
import 'package:quiz/src/features/quiz/domain/repositories/progress_repository.dart';
import 'package:quiz/src/features/quiz/domain/repositories/question_repository.dart';
import 'package:quiz/src/features/topics/presentation/screens/topics/bloc/topics_bloc.dart';
import 'package:quiz/src/features/topics/presentation/screens/topics/bloc/topics_event.dart';
import 'package:scoped_di/scoped_di.dart';

class TopicsModule extends ScopeModule {
  const TopicsModule();

  @override
  List<SingleChildWidget> get providers => [
    BlocProvider<TopicsBloc>(
      create: (context) => TopicsBloc(
        questionRepository: context.read<QuestionRepository>(),
        progressRepository: context.read<ProgressRepository>(),
      )..add(const TopicsStarted()),
    ),
  ];
}
