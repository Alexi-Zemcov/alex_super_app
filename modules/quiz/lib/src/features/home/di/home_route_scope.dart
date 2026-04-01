import 'package:flutter/widgets.dart';
import 'package:quiz/src/features/home/di/home_module.dart';
import 'package:quiz/src/features/home/presentation/screens/home/home_screen.dart';
import 'package:scoped_di/scoped_di.dart';

class HomeRouteScope extends StatelessWidget {
  const HomeRouteScope({super.key});

  @override
  Widget build(BuildContext context) {
    return const RouteScope(modules: [HomeModule()], child: HomeScreen());
  }
}
