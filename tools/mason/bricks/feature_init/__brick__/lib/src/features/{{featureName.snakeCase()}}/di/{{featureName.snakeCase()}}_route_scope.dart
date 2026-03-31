import '../../../di/route_scope.dart';
import '../presentation/pages/{{featureName.snakeCase()}}_page.dart';
import '{{featureName.snakeCase()}}_module.dart';
import 'package:flutter/material.dart';

class {{featureName.pascalCase()}}RouteScope extends StatelessWidget {
  const {{featureName.pascalCase()}}RouteScope({super.key});

  @override
  Widget build(BuildContext context) {
    return const RouteScope(
      modules: [{{featureName.pascalCase()}}Module()],
      child: {{featureName.pascalCase()}}Page(),
    );
  }
}
