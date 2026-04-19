import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:scoped_di/scoped_di.dart';
import 'package:string_tension_calculator/src/di/string_tension_calculator_scope_module.dart';
import 'package:string_tension_calculator/src/features/calculator/di/calculator_route_scope.dart';

part 'string_tension_calculator_routes.g.dart';

const stringTensionCalculatorEntryLocation = '/string-tension-calculator';

RouteBase get stringTensionCalculatorModuleRootRoute => $appRoutes.single;

@TypedShellRoute<StringTensionCalculatorModuleShellRoute>(
  routes: <TypedRoute<RouteData>>[
    TypedGoRoute<StringTensionCalculatorHomeRoute>(
      path: stringTensionCalculatorEntryLocation,
    ),
  ],
)
class StringTensionCalculatorModuleShellRoute extends ShellRouteData {
  const StringTensionCalculatorModuleShellRoute();

  @override
  Widget builder(BuildContext context, GoRouterState state, Widget navigator) {
    return FeatureScope(
      modules: const [StringTensionCalculatorScopeModule()],
      child: navigator,
    );
  }
}

class StringTensionCalculatorHomeRoute extends GoRouteData
    with $StringTensionCalculatorHomeRoute {
  const StringTensionCalculatorHomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const CalculatorRouteScope();
  }
}
