import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:scoped_di/src/scope_module.dart';

class FeatureScope extends StatelessWidget {
  const FeatureScope({required this.modules, required this.child, super.key});

  final List<ScopeModule> modules;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: resolveScopeModules(modules), child: child);
  }
}
