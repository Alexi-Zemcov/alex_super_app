import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/home/domain/usecases/get_home_progress.dart';
import '../../features/home/presentation/bloc/home_bloc.dart';
import '../../features/home/presentation/bloc/home_event.dart';
import '../../features/home/presentation/models/home_destination.dart';
import '../../features/home/presentation/pages/home_destination_placeholder_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/quiz/domain/repositories/progress_repository.dart';
import '../../features/quiz/domain/repositories/question_repository.dart';
import 'app_route_names.dart';

abstract final class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRouteNames.home:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (context) {
            return BlocProvider(
              create: (context) => HomeBloc(
                getHomeProgress: GetHomeProgress(
                  questionRepository: context.read<QuestionRepository>(),
                  progressRepository: context.read<ProgressRepository>(),
                ),
              )..add(const HomeStarted()),
              child: const HomePage(),
            );
          },
        );
      case AppRouteNames.destination:
        final destination = settings.arguments;
        if (destination is! HomeDestination) {
          return _unknownRoute(settings);
        }

        return MaterialPageRoute<void>(
          settings: settings,
          builder: (context) {
            return HomeDestinationPlaceholderPage(destination: destination);
          },
        );
      default:
        return _unknownRoute(settings);
    }
  }

  static MaterialPageRoute<void> _unknownRoute(RouteSettings settings) {
    return MaterialPageRoute<void>(
      settings: settings,
      builder: (context) {
        return Scaffold(
          appBar: AppBar(title: const Text('Маршрут не найден')),
          body: const Center(child: Text('Этот экран ещё не реализован.')),
        );
      },
    );
  }
}
