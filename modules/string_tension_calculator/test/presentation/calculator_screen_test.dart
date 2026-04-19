import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scoped_di/scoped_di.dart';
import 'package:string_tension_calculator/src/di/string_tension_calculator_scope_module.dart';
import 'package:string_tension_calculator/src/features/calculator/di/calculator_route_scope.dart';

void main() {
  group('CalculatorScreen', () {
    testWidgets('renders default guitar state and toggles to bass', (
      tester,
    ) async {
      await _pumpCalculator(tester);

      expect(find.text('E4'), findsOneWidget);
      expect(find.text('E2'), findsOneWidget);
      expect(find.text('0.009'), findsOneWidget);
      expect(find.text('0.013'), findsOneWidget);
      expect(find.text('0.017'), findsOneWidget);
      expect(find.text('0.026'), findsOneWidget);
      expect(find.text('0.037'), findsOneWidget);
      expect(find.text('0.049'), findsOneWidget);
      expect(find.text('Hz'), findsNWidgets(6));

      await tester.tap(find.text('Бас'));
      await tester.pumpAndSettle();

      expect(find.text('G2'), findsOneWidget);
      expect(find.text('E1'), findsOneWidget);
      expect(find.text('Hz'), findsNWidgets(4));
    });

    testWidgets('updates scale values when preset changes', (tester) async {
      await _pumpCalculator(tester);

      expect(find.text('25.5"'), findsNWidgets(6));

      await tester.tap(find.byKey(const Key('scale-preset-selector')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Обычная мензура: 24"').last);
      await tester.pumpAndSettle();

      expect(find.text('24"'), findsNWidgets(6));
    });

    testWidgets('opens and closes help card', (tester) async {
      await _pumpCalculator(tester);

      expect(find.byKey(const Key('calculator-help-card')), findsNothing);

      await tester.ensureVisible(find.byKey(const Key('toggle-help-button')));
      await tester.tap(find.byKey(const Key('toggle-help-button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('calculator-help-card')), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('calculator-help-card')), findsNothing);
    });

    testWidgets('adds a new string row', (tester) async {
      await _pumpCalculator(tester);

      expect(find.text('Hz'), findsNWidgets(6));
      expect(find.text('B1'), findsNothing);

      await tester.ensureVisible(find.byKey(const Key('add-string-button')));
      await tester.tap(find.byKey(const Key('add-string-button')));
      await tester.pumpAndSettle();

      expect(find.text('Hz'), findsNWidgets(7));
      expect(find.text('B1'), findsOneWidget);
    });
  });
}

Future<void> _pumpCalculator(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(1200, 1400));
  await tester.pumpWidget(
    const FeatureScope(
      modules: [StringTensionCalculatorScopeModule()],
      child: MaterialApp(home: CalculatorRouteScope()),
    ),
  );
  await tester.pumpAndSettle();
  addTearDown(() => tester.binding.setSurfaceSize(null));
}
