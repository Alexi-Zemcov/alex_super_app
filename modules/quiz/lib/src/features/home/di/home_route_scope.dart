import 'package:flutter/widgets.dart';

import 'package:quiz/src/di/route_scope.dart';
import 'package:quiz/src/features/home/di/home_module.dart';
import 'package:quiz/src/features/home/presentation/pages/home_page.dart';

class HomeRouteScope extends StatelessWidget {
  const HomeRouteScope({super.key});

  @override
  Widget build(BuildContext context) {
    return const RouteScope(modules: [HomeModule()], child: HomePage());
  }
}
