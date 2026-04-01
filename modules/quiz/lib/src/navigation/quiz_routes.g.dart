// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quiz_routes.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [$quizModuleShellRoute];

RouteBase get $quizModuleShellRoute => ShellRouteData.$route(
  factory: $QuizModuleShellRouteExtension._fromState,
  routes: [
    GoRouteData.$route(
      path: '/quiz',
      factory: $QuizHomeRoute._fromState,
      routes: [
        GoRouteData.$route(
          path: 'tickets',
          factory: $QuizTicketsRoute._fromState,
          routes: [
            GoRouteData.$route(
              path: ':ticketId',
              factory: $QuizTicketRoute._fromState,
            ),
          ],
        ),
        GoRouteData.$route(
          path: 'topics',
          factory: $QuizTopicsRoute._fromState,
          routes: [
            GoRouteData.$route(
              path: ':topicId',
              factory: $QuizTopicRoute._fromState,
            ),
          ],
        ),
        GoRouteData.$route(
          path: 'marathon',
          factory: $QuizMarathonRoute._fromState,
          routes: [
            GoRouteData.$route(
              path: 'run',
              factory: $QuizMarathonRunRoute._fromState,
            ),
          ],
        ),
        GoRouteData.$route(
          path: 'errors',
          factory: $QuizErrorsRoute._fromState,
          routes: [
            GoRouteData.$route(
              path: 'run',
              factory: $QuizErrorsRunRoute._fromState,
            ),
          ],
        ),
        GoRouteData.$route(
          path: 'favorites',
          factory: $QuizFavoritesRoute._fromState,
          routes: [
            GoRouteData.$route(
              path: 'run',
              factory: $QuizFavoritesRunRoute._fromState,
            ),
          ],
        ),
        GoRouteData.$route(path: 'blitz', factory: $QuizBlitzRoute._fromState),
      ],
    ),
  ],
);

extension $QuizModuleShellRouteExtension on QuizModuleShellRoute {
  static QuizModuleShellRoute _fromState(GoRouterState state) =>
      const QuizModuleShellRoute();
}

mixin $QuizHomeRoute on GoRouteData {
  static QuizHomeRoute _fromState(GoRouterState state) => const QuizHomeRoute();

  @override
  String get location => GoRouteData.$location('/quiz');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $QuizTicketsRoute on GoRouteData {
  static QuizTicketsRoute _fromState(GoRouterState state) =>
      const QuizTicketsRoute();

  @override
  String get location => GoRouteData.$location('/quiz/tickets');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $QuizTicketRoute on GoRouteData {
  static QuizTicketRoute _fromState(GoRouterState state) => QuizTicketRoute(
    ticketId: int.parse(state.pathParameters['ticketId']!),
    startBehavior: state.uri.queryParameters['start-behavior'],
  );

  QuizTicketRoute get _self => this as QuizTicketRoute;

  @override
  String get location => GoRouteData.$location(
    '/quiz/tickets/${Uri.encodeComponent(_self.ticketId.toString())}',
    queryParams: {
      if (_self.startBehavior != null) 'start-behavior': _self.startBehavior,
    },
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $QuizTopicsRoute on GoRouteData {
  static QuizTopicsRoute _fromState(GoRouterState state) =>
      const QuizTopicsRoute();

  @override
  String get location => GoRouteData.$location('/quiz/topics');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $QuizTopicRoute on GoRouteData {
  static QuizTopicRoute _fromState(GoRouterState state) =>
      QuizTopicRoute(topicId: int.parse(state.pathParameters['topicId']!));

  QuizTopicRoute get _self => this as QuizTopicRoute;

  @override
  String get location => GoRouteData.$location(
    '/quiz/topics/${Uri.encodeComponent(_self.topicId.toString())}',
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $QuizMarathonRoute on GoRouteData {
  static QuizMarathonRoute _fromState(GoRouterState state) =>
      const QuizMarathonRoute();

  @override
  String get location => GoRouteData.$location('/quiz/marathon');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $QuizMarathonRunRoute on GoRouteData {
  static QuizMarathonRunRoute _fromState(GoRouterState state) =>
      const QuizMarathonRunRoute();

  @override
  String get location => GoRouteData.$location('/quiz/marathon/run');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $QuizErrorsRoute on GoRouteData {
  static QuizErrorsRoute _fromState(GoRouterState state) =>
      const QuizErrorsRoute();

  @override
  String get location => GoRouteData.$location('/quiz/errors');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $QuizErrorsRunRoute on GoRouteData {
  static QuizErrorsRunRoute _fromState(GoRouterState state) =>
      const QuizErrorsRunRoute();

  @override
  String get location => GoRouteData.$location('/quiz/errors/run');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $QuizFavoritesRoute on GoRouteData {
  static QuizFavoritesRoute _fromState(GoRouterState state) =>
      const QuizFavoritesRoute();

  @override
  String get location => GoRouteData.$location('/quiz/favorites');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $QuizFavoritesRunRoute on GoRouteData {
  static QuizFavoritesRunRoute _fromState(GoRouterState state) =>
      const QuizFavoritesRunRoute();

  @override
  String get location => GoRouteData.$location('/quiz/favorites/run');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $QuizBlitzRoute on GoRouteData {
  static QuizBlitzRoute _fromState(GoRouterState state) =>
      const QuizBlitzRoute();

  @override
  String get location => GoRouteData.$location('/quiz/blitz');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}
