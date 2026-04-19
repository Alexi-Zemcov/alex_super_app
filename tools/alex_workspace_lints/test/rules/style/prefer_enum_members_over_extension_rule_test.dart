// ignore_for_file: non_constant_identifier_names

import 'package:alex_workspace_lints/src/rules/style/prefer_enum_members_over_extension_rule.dart';
import 'package:analyzer/diagnostic/diagnostic.dart';
import 'package:analyzer/src/lint/registry.dart'; // ignore: implementation_imports
import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(PreferEnumMembersOverExtensionRuleTest);
  });
}

@reflectiveTest
class PreferEnumMembersOverExtensionRuleTest extends AnalysisRuleTest {
  @override
  void setUp() {
    Registry.ruleRegistry.registerLintRule(
      PreferEnumMembersOverExtensionRule(),
    );
    super.setUp();
  }

  @override
  String get analysisRule => 'prefer_enum_members_over_extension';

  Future<void> test_ignoreForFile_hasNoDiagnostics() async {
    await assertNoDiagnostics('''
// ignore_for_file: prefer_enum_members_over_extension

enum LocalEnum { a }

extension LocalEnumX on LocalEnum {
  String get label => name;
}
''');
  }

  Future<void> test_nonEnumTarget_hasNoDiagnostics() async {
    await assertNoDiagnostics('''
class LocalClass {}

extension LocalClassX on LocalClass {
  String get label => 'local';
}
''');
  }

  Future<void> test_reportsNamedExtensionWithGetter() async {
    const content = '''
enum LocalEnum { a }

extension LocalEnumX on LocalEnum {
  String get label => name;
}
''';

    await assertDiagnostics(content, [
      lint(content.indexOf('LocalEnumX'), 'LocalEnumX'.length),
    ]);
  }

  Future<void> test_reportsNamedExtensionWithStaticHelper() async {
    const content = '''
enum LocalEnum { a }

extension LocalEnumX on LocalEnum {
  static LocalEnum parse(String raw) => LocalEnum.a;
}
''';

    await assertDiagnostics(content, [
      lint(content.indexOf('LocalEnumX'), 'LocalEnumX'.length),
    ]);
  }

  Future<void> test_reportsPartFileExtensionInSameLibrary() async {
    newFile('$testPackageLibPath/test.dart', '''
library test;

part 'part.dart';

enum LocalEnum { a }
''');

    const partContent = '''
part of test;

extension LocalEnumX on LocalEnum {
  String get label => name;
}
''';
    newFile('$testPackageLibPath/part.dart', partContent);

    result = await resolveFile(convertPath('$testPackageLibPath/part.dart'));
    assertDiagnosticsIn(_ruleDiagnostics, [
      lint(partContent.indexOf('LocalEnumX'), 'LocalEnumX'.length),
    ]);
  }

  Future<void> test_reportsUnnamedExtensionOnLocalEnum() async {
    const content = '''
enum LocalEnum { a }

extension on LocalEnum {
  String get label => name;
}
''';

    await assertDiagnostics(content, [
      lint(content.indexOf('extension on'), 'extension'.length),
    ]);
  }

  Future<void> test_unresolvedTargetDoesNotReportLint() async {
    newFile('$testPackageLibPath/test.dart', '''
extension MissingX on Missing {
  String get label => '';
}
''');

    result = await resolveFile(convertPath('$testPackageLibPath/test.dart'));
    assertDiagnosticsIn(_ruleDiagnostics, const []);
  }

  Future<void> test_whenEnumComesFromAnotherLibrary_hasNoDiagnostics() async {
    newFile('$testPackageLibPath/enum_source.dart', '''
enum SharedEnum { a }
''');

    await assertNoDiagnostics('''
import 'enum_source.dart';

extension SharedEnumX on SharedEnum {
  String get label => name;
}
''');
  }

  List<Diagnostic> get _ruleDiagnostics {
    return result.diagnostics
        .where((diagnostic) => diagnostic.diagnosticCode.name == analysisRule)
        .toList(growable: false);
  }
}
