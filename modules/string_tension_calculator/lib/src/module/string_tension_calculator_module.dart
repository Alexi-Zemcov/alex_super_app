import 'package:flutter/material.dart';
import 'package:module_contracts/module_contracts.dart';
import 'package:string_tension_calculator/src/navigation/string_tension_calculator_routes.dart';

final stringTensionCalculatorModule = AppModuleDescriptor(
  id: 'string_tension_calculator',
  title: 'Калькулятор натяжения струн',
  description:
      'Локальный калькулятор натяжения струн по мензуре, калибру и строю.',
  icon: Icons.straighten_rounded,
  entryLocation: stringTensionCalculatorEntryLocation,
  rootRoute: stringTensionCalculatorModuleRootRoute,
);
