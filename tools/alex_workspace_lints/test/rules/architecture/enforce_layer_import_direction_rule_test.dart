// ignore_for_file: non_constant_identifier_names

import 'package:alex_workspace_lints/src/rules/architecture/enforce_layer_import_direction_rule.dart';
import 'package:analyzer/diagnostic/diagnostic.dart';
import 'package:analyzer/src/lint/registry.dart'; // ignore: implementation_imports
import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:analyzer_testing/src/analysis_rule/pub_package_resolution.dart'
    show ExpectedDiagnostic; // ignore: implementation_imports
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(EnforceLayerImportDirectionRuleTest);
  });
}

@reflectiveTest
class EnforceLayerImportDirectionRuleTest extends AnalysisRuleTest {
  @override
  void setUp() {
    Registry.ruleRegistry.registerLintRule(EnforceLayerImportDirectionRule());
    super.setUp();
  }

  @override
  String get analysisRule => 'enforce_layer_import_direction';

  Future<void> test_data_canImportDomain() async {
    newFile('$testPackageLibPath/src/domain/repositories/repository.dart', '''
abstract class Repository {}
''');

    await _assertDiagnosticsFor(
      '$testPackageLibPath/src/data/repositories/repository_impl.dart',
      '''
import 'package:test/src/domain/repositories/repository.dart';

final class RepositoryImpl implements Repository {}
''',
      const [],
    );
  }

  Future<void> test_data_importsPresentation_reportsLint() async {
    newFile('$testPackageLibPath/src/presentation/screens/screen.dart', '''
class Screen {}
''');

    const uri = "'package:test/src/presentation/screens/screen.dart'";
    const content =
        '''
import $uri;

final class RepositoryImpl {}
''';

    await _assertDiagnosticsFor(
      '$testPackageLibPath/src/data/repositories/repository_impl.dart',
      content,
      [
        lint(
          content.indexOf(uri),
          uri.length,
          messageContains: "'data' layer must not import the 'presentation'",
        ),
      ],
    );
  }

  Future<void> test_di_canImportPresentationAndData() async {
    newFile('$testPackageLibPath/src/presentation/screens/screen.dart', '''
class Screen {}
''');
    newFile(
      '$testPackageLibPath/src/data/repositories/repository_impl.dart',
      '''
final class RepositoryImpl {}
''',
    );

    await _assertDiagnosticsFor(
      '$testPackageLibPath/src/di/feature_module.dart',
      '''
import 'package:test/src/data/repositories/repository_impl.dart';
import 'package:test/src/presentation/screens/screen.dart';

final class FeatureModule {}
''',
      const [],
    );
  }

  Future<void> test_domain_importsData_reportsLint() async {
    newFile(
      '$testPackageLibPath/src/data/repositories/repository_impl.dart',
      '''
final class RepositoryImpl {}
''',
    );

    const uri = "'package:test/src/data/repositories/repository_impl.dart'";
    const content =
        '''
import $uri;

abstract class UseCase {}
''';

    await _assertDiagnosticsFor(
      '$testPackageLibPath/src/domain/usecases/use_case.dart',
      content,
      [
        lint(
          content.indexOf(uri),
          uri.length,
          messageContains: "'domain' layer must not import the 'data'",
        ),
      ],
    );
  }

  Future<void> test_fileOutsideLib_isIgnored() async {
    newFile(
      '$testPackageLibPath/src/data/repositories/repository_impl.dart',
      '''
final class RepositoryImpl {}
''',
    );

    await _assertDiagnosticsFor(
      '$testPackageRootPath/test/presentation_test.dart',
      '''
import 'package:test/src/data/repositories/repository_impl.dart';

void main() {}
''',
      const [],
    );
  }

  Future<void> test_presentation_canImportDomain() async {
    newFile('$testPackageLibPath/src/domain/entities/entity.dart', '''
class Entity {}
''');

    await _assertDiagnosticsFor(
      '$testPackageLibPath/src/presentation/screens/screen.dart',
      '''
import 'package:test/src/domain/entities/entity.dart';

class Screen {
  Entity build() => Entity();
}
''',
      const [],
    );
  }

  Future<void> test_presentation_importsData_reportsLint() async {
    newFile('$testPackageLibPath/src/data/mappers/entity_mapper.dart', '''
final class EntityMapper {}
''');

    const uri = "'package:test/src/data/mappers/entity_mapper.dart'";
    const content =
        '''
import $uri;

class ScreenBloc {}
''';

    await _assertDiagnosticsFor(
      '$testPackageLibPath/src/presentation/screens/screen_bloc.dart',
      content,
      [
        lint(
          content.indexOf(uri),
          uri.length,
          messageContains: "'presentation' layer must not import the 'data'",
        ),
      ],
    );
  }

  Future<void> test_presentation_relativeImportToData_reportsLint() async {
    newFile('$testPackageLibPath/src/data/mappers/entity_mapper.dart', '''
final class EntityMapper {}
''');

    const uri = "'../../data/mappers/entity_mapper.dart'";
    const content =
        '''
import $uri;

class ScreenBloc {}
''';

    await _assertDiagnosticsFor(
      '$testPackageLibPath/src/presentation/screens/screen_bloc.dart',
      content,
      [lint(content.indexOf(uri), uri.length)],
    );
  }

  Future<void> test_unknownSourceLayer_isIgnored() async {
    newFile('$testPackageLibPath/src/di/feature_module.dart', '''
final class FeatureModule {}
''');

    await _assertDiagnosticsFor(
      '$testPackageLibPath/src/navigation/routes.dart',
      '''
import 'package:test/src/di/feature_module.dart';

final class Routes {}
''',
      const [],
    );
  }

  Future<void> _assertDiagnosticsFor(
    String path,
    String content,
    List<ExpectedDiagnostic> expectedDiagnostics,
  ) async {
    newFile(path, content);
    result = await resolveFile(convertPath(path));
    assertDiagnosticsIn(_ruleDiagnostics, expectedDiagnostics);
  }

  List<Diagnostic> get _ruleDiagnostics {
    return result.diagnostics
        .where((diagnostic) => diagnostic.diagnosticCode.name == analysisRule)
        .toList(growable: false);
  }
}
