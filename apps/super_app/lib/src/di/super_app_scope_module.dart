import 'package:app_theme/app_theme.dart';
import 'package:flutter/services.dart';
import 'package:my_instruments/my_instruments.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:scoped_di/scoped_di.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SuperAppScopeModule extends ScopeModule {
  SuperAppScopeModule({
    required this.sharedPreferences,
    required this.themeController,
    AssetBundle? assetBundle,
  }) : assetBundle = assetBundle ?? rootBundle;

  final SharedPreferences sharedPreferences;
  final AppThemeController themeController;
  final AssetBundle assetBundle;

  @override
  List<SingleChildWidget> get providers => [
    Provider<AssetBundle>.value(value: assetBundle),
    Provider<SharedPreferences>.value(value: sharedPreferences),
    Provider<MyInstrumentsRepository>(
      create: (context) => SharedPreferencesMyInstrumentsRepository(
        sharedPreferences: context.read<SharedPreferences>(),
      ),
    ),
    ChangeNotifierProvider<AppThemeController>.value(value: themeController),
  ];
}
