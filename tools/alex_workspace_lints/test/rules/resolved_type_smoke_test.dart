// ignore_for_file: non_constant_identifier_names

import 'package:analyzer/src/lint/registry.dart'; // ignore: implementation_imports
import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../src/support/string_named_type_rule.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(StringNamedTypeRuleTest);
  });
}

@reflectiveTest
class StringNamedTypeRuleTest extends AnalysisRuleTest {
  @override
  void setUp() {
    Registry.ruleRegistry.registerLintRule(StringNamedTypeRule());
    super.setUp();
  }

  @override
  String get analysisRule => 'string_named_type_smoke';

  Future<void> test_reportsResolvedStringType() async {
    await assertDiagnostics(
      '''
class A {
  String value = '';
}
''',
      [lint(12, 6)],
    );
  }

  Future<void> test_nonStringType_hasNoDiagnostics() async {
    await assertNoDiagnostics('''
class A {
  int value = 0;
}
''');
  }
}
