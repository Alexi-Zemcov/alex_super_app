import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:my_instruments/my_instruments.dart';
import 'package:provider/provider.dart';
import 'package:string_tension_calculator/string_tension_calculator.dart';

import 'test_helpers/fake_my_instruments_repository.dart';

void main() {
  testWidgets('opens calculator module through entry route', (tester) async {
    final router = GoRouter(
      initialLocation: stringTensionCalculatorModule.entryLocation,
      routes: [stringTensionCalculatorModule.rootRoute],
    );

    await tester.pumpWidget(
      Provider<MyInstrumentsRepository>.value(
        value: FakeMyInstrumentsRepository(),
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Калькулятор натяжения струн'), findsOneWidget);
    expect(find.byKey(const Key('scale-preset-selector')), findsOneWidget);
    expect(find.byKey(const Key('string-set-selector')), findsOneWidget);
    expect(find.byKey(const Key('save-my-instruments-button')), findsOneWidget);
  });
}
