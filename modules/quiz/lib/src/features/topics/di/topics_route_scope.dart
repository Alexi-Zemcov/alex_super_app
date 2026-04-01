import 'package:flutter/widgets.dart';
import 'package:quiz/src/features/topics/di/topics_module.dart';
import 'package:quiz/src/features/topics/presentation/screens/topics/topics_screen.dart';
import 'package:scoped_di/scoped_di.dart';

class TopicsRouteScope extends StatelessWidget {
  const TopicsRouteScope({super.key});

  @override
  Widget build(BuildContext context) {
    return const RouteScope(modules: [TopicsModule()], child: TopicsScreen());
  }
}
