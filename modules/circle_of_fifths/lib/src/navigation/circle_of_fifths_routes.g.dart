// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'circle_of_fifths_routes.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [$circleOfFifthsModuleShellRoute];

RouteBase get $circleOfFifthsModuleShellRoute => ShellRouteData.$route(
  factory: $CircleOfFifthsModuleShellRouteExtension._fromState,
  routes: [
    GoRouteData.$route(
      path: '/circle',
      factory: $CircleHomeRoute._fromState,
      routes: [
        GoRouteData.$route(
          path: 'settings',
          factory: $CircleSettingsRoute._fromState,
        ),
      ],
    ),
  ],
);

extension $CircleOfFifthsModuleShellRouteExtension
    on CircleOfFifthsModuleShellRoute {
  static CircleOfFifthsModuleShellRoute _fromState(GoRouterState state) =>
      const CircleOfFifthsModuleShellRoute();
}

mixin $CircleHomeRoute on GoRouteData {
  static CircleHomeRoute _fromState(GoRouterState state) =>
      const CircleHomeRoute();

  @override
  String get location => GoRouteData.$location('/circle');

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

mixin $CircleSettingsRoute on GoRouteData {
  static CircleSettingsRoute _fromState(GoRouterState state) =>
      const CircleSettingsRoute();

  @override
  String get location => GoRouteData.$location('/circle/settings');

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
