import 'package:alex_super_app/app/bloc/app_bloc.dart';
import 'package:alex_super_app/app/bloc/app_state.dart';
import 'package:alex_super_app/app/router/app_route_names.dart';
import 'package:alex_super_app/app/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppView();
  }
}

class AppView extends StatelessWidget {
  const AppView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        return MaterialApp(
          title: 'Flutter Quiz',
          debugShowCheckedModeBanner: false,
          theme: state.themeData,
          initialRoute: AppRouteNames.home,
          onGenerateRoute: AppRouter.onGenerateRoute,
        );
      },
    );
  }
}
