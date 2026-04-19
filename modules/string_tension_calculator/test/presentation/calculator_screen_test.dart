import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_instruments/my_instruments.dart';
import 'package:provider/provider.dart';
import 'package:scoped_di/scoped_di.dart';
import 'package:string_tension_calculator/src/di/string_tension_calculator_scope_module.dart';
import 'package:string_tension_calculator/src/features/calculator/di/calculator_route_scope.dart';

import '../test_helpers/fake_my_instruments_repository.dart';

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

    testWidgets('shows My Guitars empty state and hides table actions', (
      tester,
    ) async {
      await _pumpCalculator(tester);

      await tester.tap(find.text('Мои гитары'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('my-instruments-selector')), findsOneWidget);
      expect(
        find.byKey(const Key('my-instruments-empty-state')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('add-string-button')), findsNothing);
      expect(find.byKey(const Key('save-my-instruments-button')), findsNothing);
      expect(find.text('Hz'), findsNothing);
    });

    testWidgets('shows saved instrument in read only mode with edit action', (
      tester,
    ) async {
      await _pumpCalculator(
        tester,
        myInstrumentsRepository: FakeMyInstrumentsRepository(
          initialRecords: [
            buildSavedInstrumentRecord(
              id: 'saved-1',
              name: 'Studio Bass',
              kind: SavedInstrumentKind.bass,
              stringSetId: SavedStringSetId.k1,
            ),
          ],
        ),
      );

      await tester.tap(find.text('Мои гитары'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('my-instruments-selector')), findsOneWidget);
      expect(find.byKey(const Key('scale-preset-selector')), findsNothing);
      expect(find.byKey(const Key('string-set-selector')), findsNothing);
      expect(find.text('Studio Bass · Бас'), findsOneWidget);
      expect(find.text('G2'), findsOneWidget);
      expect(find.byIcon(Icons.keyboard_arrow_up_rounded), findsNothing);
      expect(find.byKey(const Key('add-string-button')), findsNothing);
      expect(find.byKey(const Key('save-my-instruments-button')), findsNothing);
      expect(
        find.byKey(const Key('edit-saved-instrument-button')),
        findsOneWidget,
      );
    });

    testWidgets('opens create save dialog from manual mode', (tester) async {
      await _pumpCalculator(tester);

      await tester.ensureVisible(
        find.byKey(const Key('save-my-instruments-button')),
      );
      await tester.tap(find.byKey(const Key('save-my-instruments-button')));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('save-instrument-name-field')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('save-instrument-kind-switch')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('save-instrument-create-button')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('save-instrument-update-button')),
        findsNothing,
      );
      expect(
        find.byKey(const Key('save-instrument-clone-button')),
        findsNothing,
      );
    });

    testWidgets('edit action redirects saved bass instrument to bass tab', (
      tester,
    ) async {
      await _pumpCalculator(
        tester,
        myInstrumentsRepository: FakeMyInstrumentsRepository(
          initialRecords: [
            buildSavedInstrumentRecord(
              id: 'saved-1',
              name: 'Live Bass',
              kind: SavedInstrumentKind.bass,
              stringSetId: SavedStringSetId.k1,
            ),
          ],
        ),
      );

      await tester.tap(find.text('Мои гитары'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('edit-saved-instrument-button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('my-instruments-selector')), findsNothing);
      expect(find.byKey(const Key('scale-preset-selector')), findsOneWidget);
      expect(find.byKey(const Key('string-set-selector')), findsOneWidget);
      expect(find.byKey(const Key('add-string-button')), findsOneWidget);
      expect(
        find.byKey(const Key('save-my-instruments-button')),
        findsOneWidget,
      );
      expect(find.text('G2'), findsOneWidget);
      expect(find.byIcon(Icons.keyboard_arrow_up_rounded), findsWidgets);
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

Future<void> _pumpCalculator(
  WidgetTester tester, {
  MyInstrumentsRepository? myInstrumentsRepository,
}) async {
  await tester.binding.setSurfaceSize(const Size(1200, 1400));
  await tester.pumpWidget(
    Provider<MyInstrumentsRepository>.value(
      value: myInstrumentsRepository ?? FakeMyInstrumentsRepository(),
      child: const FeatureScope(
        modules: [StringTensionCalculatorScopeModule()],
        child: MaterialApp(home: CalculatorRouteScope()),
      ),
    ),
  );
  await tester.pumpAndSettle();
  addTearDown(() => tester.binding.setSurfaceSize(null));
}
