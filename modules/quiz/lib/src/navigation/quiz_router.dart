import 'package:flutter/material.dart';
import 'package:quiz/src/features/home/di/home_route_scope.dart';
import 'package:quiz/src/features/overview/di/overview_route_scope.dart';
import 'package:quiz/src/features/quiz/domain/entities/quiz_mode.dart';
import 'package:quiz/src/features/quiz_flow/di/quiz_flow_route_scope.dart';
import 'package:quiz/src/features/tickets/di/tickets_route_scope.dart';
import 'package:quiz/src/features/topics/di/topics_route_scope.dart';
import 'package:quiz/src/navigation/quiz_flow_route_args.dart';
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
      case QuizRouteNames.tickets:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (context) {
            return const TicketsRouteScope();
          },
        );
      case QuizRouteNames.topics:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (context) {
            return const TopicsRouteScope();
          },
        );
      case QuizRouteNames.marathon:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (context) {
            return const OverviewRouteScope(mode: QuizMode.marathon);
          },
        );
      case QuizRouteNames.errors:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (context) {
            return const OverviewRouteScope(mode: QuizMode.errors);
          },
        );
      case QuizRouteNames.favorites:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (context) {
            return const OverviewRouteScope(mode: QuizMode.favorites);
          },
        );
      case QuizRouteNames.quizFlow:
        final routeArgs = settings.arguments;
        if (routeArgs is! QuizFlowRouteArgs) {
          return _unknownRoute(settings);
        }

        return MaterialPageRoute<void>(
          settings: settings,
          builder: (context) {
            return QuizFlowRouteScope(routeArgs: routeArgs);
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
