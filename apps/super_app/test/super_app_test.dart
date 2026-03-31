import 'package:app_theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:module_contracts/module_contracts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_app/src/app.dart';

void main() {
  testWidgets('shows the module catalog, toggles theme, and opens a module', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final sharedPreferences = await SharedPreferences.getInstance();
    final themeController = AppThemeController();
    final fakeModule = AppModuleDescriptor(
      id: 'quiz',
      title: 'Quiz',
      description: 'Fake module for the dashboard test.',
      icon: Icons.quiz_rounded,
      rootPageBuilder: (context) {
        return const Scaffold(body: Center(child: Text('Fake module page')));
      },
    );

    await tester.pumpWidget(
      SuperApp(
        sharedPreferences: sharedPreferences,
        themeController: themeController,
        modules: [fakeModule],
      ),
    );

    expect(find.text('Quiz'), findsOneWidget);

    await tester.tap(find.text('🌕'));
    await tester.pumpAndSettle();
    expect(themeController.themePreference, ThemePreference.white);

    await tester.tap(find.text('Открыть'));
    await tester.pumpAndSettle();
    expect(find.text('Fake module page'), findsOneWidget);
  });
}
