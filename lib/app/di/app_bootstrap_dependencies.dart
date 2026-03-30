import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppBootstrapDependencies {
  const AppBootstrapDependencies({
    required this.sharedPreferences,
    required this.assetBundle,
  });

  final SharedPreferences sharedPreferences;
  final AssetBundle assetBundle;
}
