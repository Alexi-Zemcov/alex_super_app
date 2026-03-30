import 'package:alex_super_app/app/di/scope_module.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class FeatureScope extends StatelessWidget {
  const FeatureScope({required this.modules, required this.child, super.key});

  final List<ScopeModule> modules;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: resolveScopeModules(modules), child: child);
  }
}
