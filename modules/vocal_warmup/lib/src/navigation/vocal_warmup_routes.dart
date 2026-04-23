import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:scoped_di/scoped_di.dart';
import 'package:vocal_warmup/src/di/vocal_warmup_scope_module.dart';
import 'package:vocal_warmup/src/features/range_detection/di/range_flow_route_scope.dart';

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
      child: navigator,
    );
  }
}

class VocalWarmupHomeRoute extends GoRouteData with $VocalWarmupHomeRoute {
  const VocalWarmupHomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const RangeFlowRouteScope();
  }
}
