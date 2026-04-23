import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:midi_playback/midi_playback.dart';
import 'package:provider/provider.dart';
import 'package:scoped_di/scoped_di.dart';
import 'package:vocal_warmup/src/di/vocal_warmup_scope_module.dart';
import 'package:vocal_warmup/src/features/warmup/di/warmup_route_scope.dart';

part 'vocal_warmup_routes.g.dart';

const vocalWarmupEntryLocation = '/vocal-warmup';

RouteBase get vocalWarmupModuleRootRoute => $appRoutes.single;

@TypedShellRoute<VocalWarmupModuleShellRoute>(
  routes: <TypedRoute<RouteData>>[
    TypedGoRoute<VocalWarmupHomeRoute>(path: vocalWarmupEntryLocation),
  ],
)
class VocalWarmupModuleShellRoute extends ShellRouteData {
  const VocalWarmupModuleShellRoute();

  @override
  Widget builder(BuildContext context, GoRouterState state, Widget navigator) {
    return FeatureScope(
      modules: const [VocalWarmupScopeModule()],
      child: _VocalWarmupBootstrap(child: navigator),
    );
  }
}

class VocalWarmupHomeRoute extends GoRouteData with $VocalWarmupHomeRoute {
  const VocalWarmupHomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const WarmupRouteScope();
  }
}

class _VocalWarmupBootstrap extends StatefulWidget {
  const _VocalWarmupBootstrap({required this.child});

  final Widget child;

  @override
  State<_VocalWarmupBootstrap> createState() => _VocalWarmupBootstrapState();
}

class _VocalWarmupBootstrapState extends State<_VocalWarmupBootstrap> {
  late final Future<void> _initialization;

  @override
  void initState() {
    super.initState();
    _initialization = context.read<MidiPlaybackService>().initialize();
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
