import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:string_tension_calculator/string_tension_calculator.dart';

void main() {
  testWidgets('opens calculator module through entry route', (tester) async {
    final router = GoRouter(
      initialLocation: stringTensionCalculatorModule.entryLocation,
      routes: [stringTensionCalculatorModule.rootRoute],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    expect(find.text('Калькулятор натяжения струн'), findsOneWidget);
    expect(find.byKey(const Key('scale-preset-selector')), findsOneWidget);
    expect(find.byKey(const Key('string-set-selector')), findsOneWidget);
    expect(find.byKey(const Key('add-string-button')), findsOneWidget);
  });
}
