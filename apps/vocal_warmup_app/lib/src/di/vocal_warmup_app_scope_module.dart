import 'package:app_theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:scoped_di/scoped_di.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VocalWarmupAppScopeModule extends ScopeModule {
  VocalWarmupAppScopeModule({
    required this.sharedPreferences,
    required this.themeController,
  });

  final SharedPreferences sharedPreferences;
  final AppThemeController themeController;

  @override
  List<SingleChildWidget> get providers => [
    Provider<SharedPreferences>.value(value: sharedPreferences),
    ChangeNotifierProvider<AppThemeController>.value(value: themeController),
  ];
}
