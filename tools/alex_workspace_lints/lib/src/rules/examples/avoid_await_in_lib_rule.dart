import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

class AvoidAwaitInLibRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'avoid_await_in_lib',
    'Avoid using await expressions in lib/ sources.',
    correctionMessage: 'Consider moving the asynchronous logic elsewhere.',
  );

  AvoidAwaitInLibRule()
    : super(
        name: 'avoid_await_in_lib',
        description:
            'Example lint used to validate analyzer plugin infrastructure.',
      );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    final visitor = _Visitor(this, context);
    registry.addAwaitExpression(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  _Visitor(this.rule, this.context);

  final AnalysisRule rule;
  final RuleContext context;

  @override
  void visitAwaitExpression(AwaitExpression node) {
    if (context.isInLibDir) {
      rule.reportAtNode(node);
    }
  }
}
