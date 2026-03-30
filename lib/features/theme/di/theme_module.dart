import 'package:alex_super_app/app/di/app_bootstrap_dependencies.dart';
import 'package:alex_super_app/app/di/scope_module.dart';
import 'package:alex_super_app/features/theme/data/datasources/theme_local_data_source.dart';
import 'package:alex_super_app/features/theme/data/repositories/theme_repository_impl.dart';
import 'package:alex_super_app/features/theme/domain/repositories/theme_repository.dart';
import 'package:alex_super_app/features/theme/domain/usecases/cycle_theme_use_case.dart';
import 'package:alex_super_app/features/theme/domain/usecases/load_theme_use_case.dart';
import 'package:alex_super_app/features/theme/domain/usecases/set_theme_use_case.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

class ThemeModule extends ScopeModule {
  const ThemeModule();

  @override
  List<SingleChildWidget> get providers => [
    Provider<ThemeLocalDataSource>(
      create: (context) => SharedPreferencesThemeLocalDataSource(
        sharedPreferences: context
            .read<AppBootstrapDependencies>()
            .sharedPreferences,
      ),
    ),
    RepositoryProvider<ThemeRepository>(
      create: (context) => ThemeRepositoryImpl(
        localDataSource: context.read<ThemeLocalDataSource>(),
      ),
    ),
    Provider<LoadThemeUseCase>(
      create: (context) => LoadThemeUseCase(context.read<ThemeRepository>()),
    ),
    Provider<SetThemeUseCase>(
      create: (context) => SetThemeUseCase(context.read<ThemeRepository>()),
    ),
    Provider<CycleThemeUseCase>(
      create: (context) => CycleThemeUseCase(setTheme: context.read<SetThemeUseCase>()),
    ),
  ];
}
