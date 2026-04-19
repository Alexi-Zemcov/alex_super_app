import 'package:flutter/widgets.dart';
import 'package:scoped_di/scoped_di.dart';
import 'package:string_tension_calculator/src/features/calculator/di/calculator_module.dart';
import 'package:string_tension_calculator/src/features/calculator/presentation/screens/calculator/calculator_screen.dart';

class CalculatorRouteScope extends StatelessWidget {
  const CalculatorRouteScope({super.key});

  @override
  Widget build(BuildContext context) {
    return const RouteScope(
      modules: [CalculatorModule()],
      child: CalculatorScreen(),
    );
  }
}
