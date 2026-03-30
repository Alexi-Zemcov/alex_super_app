import 'package:alex_super_app/app/router/app_route_names.dart';
import 'package:alex_super_app/features/home/di/home_route_scope.dart';
import 'package:alex_super_app/features/home/presentation/models/home_destination.dart';
import 'package:alex_super_app/features/home/presentation/pages/home_destination_placeholder_page.dart';
import 'package:flutter/material.dart';

abstract final class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRouteNames.home:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (context) {
            return const HomeRouteScope();
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
