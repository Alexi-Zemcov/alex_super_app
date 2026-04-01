import 'package:flutter/widgets.dart';
import 'package:quiz/src/features/quiz_flow/di/quiz_flow_module.dart';
import 'package:quiz/src/features/quiz_flow/presentation/screens/quiz_flow/quiz_flow_screen.dart';
import 'package:quiz/src/navigation/quiz_flow_route_args.dart';
import 'package:scoped_di/scoped_di.dart';

class QuizFlowRouteScope extends StatelessWidget {
  const QuizFlowRouteScope({required this.routeArgs, super.key});

  final QuizFlowRouteArgs routeArgs;

  @override
  Widget build(BuildContext context) {
    return RouteScope(
      modules: [QuizFlowModule(routeArgs: routeArgs)],
      child: const QuizFlowScreen(),
    );
  }
}
