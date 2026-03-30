import 'package:alex_super_app/app/di/feature_scope.dart';
import 'package:alex_super_app/app/di/scope_module.dart';
import 'package:flutter/widgets.dart';

class RouteScope extends StatelessWidget {
  const RouteScope({required this.modules, required this.child, super.key});

  final List<ScopeModule> modules;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FeatureScope(modules: modules, child: child);
  }
}
