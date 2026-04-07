// ignore_for_file: non_constant_identifier_names

import 'package:alex_workspace_lints/src/rules/examples/avoid_await_in_lib_rule.dart';
import 'package:analyzer/src/lint/registry.dart'; // ignore: implementation_imports
import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(AvoidAwaitInLibRuleTest);
  });
}

@reflectiveTest
class AvoidAwaitInLibRuleTest extends AnalysisRuleTest {
  @override
  void setUp() {
    Registry.ruleRegistry.registerLintRule(AvoidAwaitInLibRule());
    super.setUp();
  }

  @override
  String get analysisRule => 'avoid_await_in_lib';

  Future<void> test_reportsAwaitExpression() async {
    await assertDiagnostics(
      '''
Future<void> f(Future<void> value) async {
  await value;
}
''',
      [lint(45, 11)],
    );
  }

  Future<void> test_respectsIgnoreForFile() async {
    await assertNoDiagnostics('''
// ignore_for_file: avoid_await_in_lib

Future<void> f(Future<void> value) async {
  await value;
}
''');
  }

  Future<void> test_withoutAwait_hasNoDiagnostics() async {
    await assertNoDiagnostics('''
Future<void> f() async {}
''');
  }
}
