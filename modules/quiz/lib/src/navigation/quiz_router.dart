import 'package:flutter/material.dart';
import 'package:quiz/src/features/home/di/home_route_scope.dart';
import 'package:quiz/src/features/home/presentation/screens/destination_placeholder/home_destination_placeholder_screen.dart';
import 'package:quiz/src/features/home/presentation/screens/home/models/home_destination.dart';
import 'package:quiz/src/navigation/quiz_route_names.dart';

abstract final class QuizRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case QuizRouteNames.home:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (context) {
            return const HomeRouteScope();
          },
        );
      case QuizRouteNames.destination:
        final destination = settings.arguments;
        if (destination is! HomeDestination) {
          return _unknownRoute(settings);
        }

        return MaterialPageRoute<void>(
          settings: settings,
          builder: (context) {
            return HomeDestinationPlaceholderScreen(destination: destination);
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
