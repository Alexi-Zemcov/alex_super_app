import 'package:alex_super_app/app/di/route_scope.dart';
import 'package:alex_super_app/features/home/di/home_module.dart';
import 'package:alex_super_app/features/home/presentation/pages/home_page.dart';
import 'package:flutter/widgets.dart';

class HomeRouteScope extends StatelessWidget {
  const HomeRouteScope({super.key});

  @override
  Widget build(BuildContext context) {
    return const RouteScope(modules: [HomeModule()], child: HomePage());
  }
}
