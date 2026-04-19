// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'string_tension_calculator_routes.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [$stringTensionCalculatorModuleShellRoute];

RouteBase get $stringTensionCalculatorModuleShellRoute => ShellRouteData.$route(
  factory: $StringTensionCalculatorModuleShellRouteExtension._fromState,
  routes: [
    GoRouteData.$route(
      path: '/string-tension-calculator',
      factory: $StringTensionCalculatorHomeRoute._fromState,
    ),
  ],
);

extension $StringTensionCalculatorModuleShellRouteExtension
    on StringTensionCalculatorModuleShellRoute {
  static StringTensionCalculatorModuleShellRoute _fromState(
    GoRouterState state,
  ) => const StringTensionCalculatorModuleShellRoute();
}

mixin $StringTensionCalculatorHomeRoute on GoRouteData {
  static StringTensionCalculatorHomeRoute _fromState(GoRouterState state) =>
      const StringTensionCalculatorHomeRoute();

  @override
  String get location => GoRouteData.$location('/string-tension-calculator');

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
