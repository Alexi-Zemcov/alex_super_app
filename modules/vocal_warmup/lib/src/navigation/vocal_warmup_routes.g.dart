// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vocal_warmup_routes.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [$vocalWarmupModuleShellRoute];

RouteBase get $vocalWarmupModuleShellRoute => ShellRouteData.$route(
  factory: $VocalWarmupModuleShellRouteExtension._fromState,
  routes: [
    GoRouteData.$route(
      path: '/vocal-warmup',
      factory: $VocalWarmupHomeRoute._fromState,
    ),
  ],
);

extension $VocalWarmupModuleShellRouteExtension on VocalWarmupModuleShellRoute {
  static VocalWarmupModuleShellRoute _fromState(GoRouterState state) =>
      const VocalWarmupModuleShellRoute();
}

mixin $VocalWarmupHomeRoute on GoRouteData {
  static VocalWarmupHomeRoute _fromState(GoRouterState state) =>
      const VocalWarmupHomeRoute();

  @override
  String get location => GoRouteData.$location('/vocal-warmup');

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
