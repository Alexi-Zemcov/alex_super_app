import 'package:flutter/widgets.dart';
import 'package:quiz/src/features/quiz_flow/di/quiz_flow_module.dart';
import 'package:quiz/src/features/quiz_flow/presentation/screens/quiz_flow/quiz_flow_screen.dart';
import 'package:quiz/src/navigation/quiz_flow_intent.dart';
import 'package:scoped_di/scoped_di.dart';

class QuizFlowRouteScope extends StatelessWidget {
  const QuizFlowRouteScope({required this.intent, super.key});

  final QuizFlowIntent intent;

  @override
  Widget build(BuildContext context) {
    return RouteScope(
      modules: [QuizFlowModule(intent: intent)],
      child: const QuizFlowScreen(),
    );
  }
}
