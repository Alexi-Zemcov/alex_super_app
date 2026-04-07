import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

class StringNamedTypeRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'string_named_type_smoke',
    'Smoke-test rule that flags String named types.',
  );

  StringNamedTypeRule()
    : super(
        name: 'string_named_type_smoke',
        description: 'Test-only rule that exercises resolved type lookups.',
      );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    registry.addNamedType(this, _Visitor(this));
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  _Visitor(this.rule);

  final AnalysisRule rule;

  @override
  void visitNamedType(NamedType node) {
    if (node.type?.isDartCoreString ?? false) {
      rule.reportAtNode(node);
    }
  }
}
