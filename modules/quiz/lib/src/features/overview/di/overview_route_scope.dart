import 'package:flutter/widgets.dart';
import 'package:quiz/src/features/overview/di/overview_module.dart';
import 'package:quiz/src/features/overview/presentation/screens/overview/overview_screen.dart';
import 'package:quiz/src/features/quiz/domain/entities/quiz_mode.dart';
import 'package:scoped_di/scoped_di.dart';

class OverviewRouteScope extends StatelessWidget {
  const OverviewRouteScope({required this.mode, super.key});

  final QuizMode mode;

  @override
  Widget build(BuildContext context) {
    return RouteScope(
      modules: [OverviewModule(mode: mode)],
      child: OverviewScreen(mode: mode),
    );
  }
}
