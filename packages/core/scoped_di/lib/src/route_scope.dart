import 'package:flutter/widgets.dart';
import 'package:scoped_di/src/feature_scope.dart';
import 'package:scoped_di/src/scope_module.dart';

class RouteScope extends StatelessWidget {
  const RouteScope({required this.modules, required this.child, super.key});

  final List<ScopeModule> modules;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FeatureScope(modules: modules, child: child);
  }
}
