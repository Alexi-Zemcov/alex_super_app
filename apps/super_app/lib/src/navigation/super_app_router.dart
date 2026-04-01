import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:super_app/src/shell/dashboard_page.dart';

part 'super_app_router.g.dart';

final GlobalKey<NavigatorState> superAppRootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'super_app_root');

List<RouteBase> buildSuperAppRoutes() {
  return [...$appRoutes];
}

GoRouter buildSuperAppRouter({
  required List<RouteBase> moduleRoutes,
  String? initialLocation,
}) {
  return GoRouter(
    navigatorKey: superAppRootNavigatorKey,
    initialLocation: initialLocation ?? const DashboardRoute().location,
    routes: [...buildSuperAppRoutes(), ...moduleRoutes],
    redirect: (context, state) => null,
    errorBuilder: (context, state) {
      return _RouterErrorScreen(location: state.uri.toString());
    },
  );
}

@TypedGoRoute<DashboardRoute>(path: '/')
class DashboardRoute extends GoRouteData with $DashboardRoute {
  const DashboardRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const DashboardPage();
  }
}

class _RouterErrorScreen extends StatelessWidget {
  const _RouterErrorScreen({required this.location});

  final String location;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Маршрут не найден')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Не удалось открыть $location.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
