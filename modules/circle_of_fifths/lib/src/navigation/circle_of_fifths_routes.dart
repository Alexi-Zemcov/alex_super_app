import 'package:circle_of_fifths/src/core/audio/audio_playback_service.dart';
import 'package:circle_of_fifths/src/di/circle_of_fifths_scope_module.dart';
import 'package:circle_of_fifths/src/features/circle/di/circle_route_scope.dart';
import 'package:circle_of_fifths/src/features/settings/presentation/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:scoped_di/scoped_di.dart';

part 'circle_of_fifths_routes.g.dart';

const circleEntryLocation = '/circle';

RouteBase get circleOfFifthsModuleRootRoute => $appRoutes.single;

@TypedShellRoute<CircleOfFifthsModuleShellRoute>(
  routes: <TypedRoute<RouteData>>[
    TypedGoRoute<CircleHomeRoute>(
      path: circleEntryLocation,
      routes: <TypedRoute<RouteData>>[
        TypedGoRoute<CircleSettingsRoute>(path: 'settings'),
      ],
    ),
  ],
)
class CircleOfFifthsModuleShellRoute extends ShellRouteData {
  const CircleOfFifthsModuleShellRoute();

  @override
  Widget builder(BuildContext context, GoRouterState state, Widget navigator) {
    return FeatureScope(
      modules: const [CircleOfFifthsScopeModule()],
      child: _CircleOfFifthsBootstrap(child: navigator),
    );
  }
}

class CircleHomeRoute extends GoRouteData with $CircleHomeRoute {
  const CircleHomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const CircleRouteScope();
  }
}

class CircleSettingsRoute extends GoRouteData with $CircleSettingsRoute {
  const CircleSettingsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const SettingsScreen();
  }
}

class _CircleOfFifthsBootstrap extends StatefulWidget {
  const _CircleOfFifthsBootstrap({required this.child});

  final Widget child;

  @override
  State<_CircleOfFifthsBootstrap> createState() =>
      _CircleOfFifthsBootstrapState();
}

class _CircleOfFifthsBootstrapState extends State<_CircleOfFifthsBootstrap> {
  late final Future<void> _initialization;

  @override
  void initState() {
    super.initState();
    _initialization = context.read<AudioPlaybackService>().initialize();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return widget.child;
      },
    );
  }
}
