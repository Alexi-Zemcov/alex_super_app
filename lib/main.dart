import 'package:alex_super_app/app/app.dart';
import 'package:alex_super_app/app/di/app_bootstrap_dependencies.dart';
import 'package:alex_super_app/app/di/app_scope.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    AppScope(
      dependencies: AppBootstrapDependencies(
        sharedPreferences: sharedPreferences,
        assetBundle: rootBundle,
      ),
      child: const App(),
    ),
  );
}
