import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz/src/features/home/di/home_route_scope.dart';
import 'package:quiz/src/features/overview/di/overview_route_scope.dart';
import 'package:quiz/src/features/quiz/di/quiz_data_module.dart';
import 'package:quiz/src/features/quiz/domain/entities/quiz_mode.dart';
import 'package:quiz/src/features/quiz_flow/di/quiz_flow_route_scope.dart';
import 'package:quiz/src/features/tickets/di/tickets_route_scope.dart';
import 'package:quiz/src/features/topics/di/topics_route_scope.dart';
import 'package:quiz/src/navigation/quiz_flow_intent.dart';
import 'package:scoped_di/scoped_di.dart';

part 'quiz_routes.g.dart';

const quizEntryLocation = '/quiz';

RouteBase get quizModuleRootRoute => $appRoutes.single;

@TypedShellRoute<QuizModuleShellRoute>(
  routes: <TypedRoute<RouteData>>[
    TypedGoRoute<QuizHomeRoute>(
      path: quizEntryLocation,
      routes: <TypedRoute<RouteData>>[
        TypedGoRoute<QuizTicketsRoute>(
          path: 'tickets',
          routes: <TypedRoute<RouteData>>[
            TypedGoRoute<QuizTicketRoute>(path: ':ticketId'),
          ],
        ),
        TypedGoRoute<QuizTopicsRoute>(
          path: 'topics',
          routes: <TypedRoute<RouteData>>[
            TypedGoRoute<QuizTopicRoute>(path: ':topicId'),
          ],
        ),
        TypedGoRoute<QuizMarathonRoute>(
          path: 'marathon',
          routes: <TypedRoute<RouteData>>[
            TypedGoRoute<QuizMarathonRunRoute>(path: 'run'),
          ],
        ),
        TypedGoRoute<QuizErrorsRoute>(
          path: 'errors',
          routes: <TypedRoute<RouteData>>[
            TypedGoRoute<QuizErrorsRunRoute>(path: 'run'),
          ],
        ),
        TypedGoRoute<QuizFavoritesRoute>(
          path: 'favorites',
          routes: <TypedRoute<RouteData>>[
            TypedGoRoute<QuizFavoritesRunRoute>(path: 'run'),
          ],
        ),
        TypedGoRoute<QuizBlitzRoute>(path: 'blitz'),
      ],
    ),
  ],
)
class QuizModuleShellRoute extends ShellRouteData {
  const QuizModuleShellRoute();

  @override
  Widget builder(BuildContext context, GoRouterState state, Widget navigator) {
    return FeatureScope(modules: const [QuizDataModule()], child: navigator);
  }
}

class QuizHomeRoute extends GoRouteData with $QuizHomeRoute {
  const QuizHomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const HomeRouteScope();
  }
}

class QuizTicketsRoute extends GoRouteData with $QuizTicketsRoute {
  const QuizTicketsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const TicketsRouteScope();
  }
}

class QuizTicketRoute extends GoRouteData with $QuizTicketRoute {
  const QuizTicketRoute({required this.ticketId, this.startBehavior});

  final int ticketId;
  final String? startBehavior;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return QuizFlowRouteScope(
      intent: QuizFlowIntent.ticket(
        ticketId: ticketId,
        startBehavior: quizStartBehaviorFromQuery(startBehavior),
      ),
    );
  }
}

class QuizTopicsRoute extends GoRouteData with $QuizTopicsRoute {
  const QuizTopicsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const TopicsRouteScope();
  }
}

class QuizTopicRoute extends GoRouteData with $QuizTopicRoute {
  const QuizTopicRoute({required this.topicId});

  final int topicId;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return QuizFlowRouteScope(intent: QuizFlowIntent.topic(topicId: topicId));
  }
}

class QuizMarathonRoute extends GoRouteData with $QuizMarathonRoute {
  const QuizMarathonRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const OverviewRouteScope(mode: QuizMode.marathon);
  }
}

class QuizMarathonRunRoute extends GoRouteData with $QuizMarathonRunRoute {
  const QuizMarathonRunRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const QuizFlowRouteScope(intent: QuizFlowIntent.marathon());
  }
}

class QuizErrorsRoute extends GoRouteData with $QuizErrorsRoute {
  const QuizErrorsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const OverviewRouteScope(mode: QuizMode.errors);
  }
}

class QuizErrorsRunRoute extends GoRouteData with $QuizErrorsRunRoute {
  const QuizErrorsRunRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const QuizFlowRouteScope(intent: QuizFlowIntent.errors());
  }
}

class QuizFavoritesRoute extends GoRouteData with $QuizFavoritesRoute {
  const QuizFavoritesRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const OverviewRouteScope(mode: QuizMode.favorites);
  }
}

class QuizFavoritesRunRoute extends GoRouteData with $QuizFavoritesRunRoute {
  const QuizFavoritesRunRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const QuizFlowRouteScope(intent: QuizFlowIntent.favorites());
  }
}

class QuizBlitzRoute extends GoRouteData with $QuizBlitzRoute {
  const QuizBlitzRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const QuizFlowRouteScope(intent: QuizFlowIntent.blitz());
  }
}
