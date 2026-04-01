import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/single_child_widget.dart';
import 'package:quiz/src/features/quiz/domain/repositories/progress_repository.dart';
import 'package:quiz/src/features/quiz/domain/repositories/question_repository.dart';
import 'package:quiz/src/features/tickets/presentation/screens/tickets/bloc/tickets_bloc.dart';
import 'package:quiz/src/features/tickets/presentation/screens/tickets/bloc/tickets_event.dart';
import 'package:scoped_di/scoped_di.dart';

class TicketsModule extends ScopeModule {
  const TicketsModule();

  @override
  List<SingleChildWidget> get providers => [
    BlocProvider<TicketsBloc>(
      create: (context) => TicketsBloc(
        questionRepository: context.read<QuestionRepository>(),
        progressRepository: context.read<ProgressRepository>(),
      )..add(const TicketsStarted()),
    ),
  ];
}
