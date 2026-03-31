import 'package:flutter/material.dart';
import 'package:module_contracts/module_contracts.dart';
import 'package:quiz/src/di/feature_scope.dart';
import 'package:quiz/src/features/quiz/di/quiz_data_module.dart';
import 'package:quiz/src/navigation/quiz_route_names.dart';
import 'package:quiz/src/navigation/quiz_router.dart';

const quizModule = AppModuleDescriptor(
  id: 'quiz',
  title: 'Flutter Quiz',
  description: 'Оффлайн-квиз по Flutter и Dart с билетами, темами и прогрессом.',
  icon: Icons.quiz_rounded,
  rootPageBuilder: _buildQuizModuleRoot,
);

Widget _buildQuizModuleRoot(BuildContext context) {
  return const _QuizModuleRoot();
}

class _QuizModuleRoot extends StatelessWidget {
  const _QuizModuleRoot();

  @override
  Widget build(BuildContext context) {
    return const FeatureScope(
      modules: [QuizDataModule()],
      child: Navigator(
        initialRoute: QuizRouteNames.home,
        onGenerateRoute: QuizRouter.onGenerateRoute,
      ),
    );
  }
}
