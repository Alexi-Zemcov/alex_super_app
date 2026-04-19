import 'package:alex_workspace_lints/src/shared/clean_architecture_layer.dart';
import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

class EnforceLayerImportDirectionRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'enforce_layer_import_direction',
    "The '{0}' layer must not import the '{1}' layer from '{2}'.",
    correctionMessage:
        'Depend only on allowed layers or move the wiring into `di` or a domain-facing contract.',
  );

  EnforceLayerImportDirectionRule()
    : super(
        name: 'enforce_layer_import_direction',
        description:
            'Reports same-package imports that violate the clean-architecture direction between presentation, domain, data, and di.',
      );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    registry.addImportDirective(this, _Visitor(this, context));
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  _Visitor(this.rule, this.context);

  final EnforceLayerImportDirectionRule rule;
  final RuleContext context;

  @override
  void visitImportDirective(ImportDirective node) {
    final sourcePath = LayeredLibraryPath.parse(
      context.libraryElement?.firstFragment.source.fullName,
    );
    if (sourcePath == null) {
      return;
    }

    final targetLibrary = node.libraryImport?.importedLibrary;
    if (targetLibrary == null) {
      return;
    }

    final targetPath = LayeredLibraryPath.parse(
      targetLibrary.firstFragment.source.fullName,
    );
    if (targetPath == null) {
      return;
    }

    if (sourcePath.packageRoot != targetPath.packageRoot) {
      return;
    }

    if (sourcePath.layer.allowsDependencyOn(targetPath.layer)) {
      return;
    }

    rule.reportAtNode(
      node.uri,
      arguments: [
        sourcePath.layer.name,
        targetPath.layer.name,
        targetPath.relativePath,
      ],
    );
  }
}
