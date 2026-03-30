import 'package:alex_super_app/app/bloc/app_bloc.dart';
import 'package:alex_super_app/app/bloc/app_event.dart';
import 'package:alex_super_app/app/di/scope_module.dart';
import 'package:alex_super_app/features/theme/domain/usecases/cycle_theme_use_case.dart';
import 'package:alex_super_app/features/theme/domain/usecases/load_theme_use_case.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/single_child_widget.dart';

class AppModule extends ScopeModule {
  const AppModule();

  @override
  List<SingleChildWidget> get providers => [
    BlocProvider<AppBloc>(
      create: (context) => AppBloc(
        loadTheme: context.read<LoadThemeUseCase>(),
        cycleTheme: context.read<CycleThemeUseCase>(),
      )..add(const AppStarted()),
    ),
  ];
}
