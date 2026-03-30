import 'package:alex_super_app/app/di/app_bootstrap_dependencies.dart';
import 'package:alex_super_app/app/di/app_module.dart';
import 'package:alex_super_app/app/di/feature_scope.dart';
import 'package:alex_super_app/app/di/scope_module.dart';
import 'package:alex_super_app/features/quiz/di/quiz_data_module.dart';
import 'package:alex_super_app/features/theme/di/theme_module.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class AppScope extends StatelessWidget {
  const AppScope({required this.dependencies, required this.child, super.key});

  static const List<ScopeModule> _modules = [
    QuizDataModule(),
    ThemeModule(),
    AppModule(),
  ];

  final AppBootstrapDependencies dependencies;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Provider<AppBootstrapDependencies>.value(
      value: dependencies,
      child: FeatureScope(modules: _modules, child: child),
    );
  }
}
