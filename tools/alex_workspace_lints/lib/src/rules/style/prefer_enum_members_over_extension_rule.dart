import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/error/error.dart';

class PreferEnumMembersOverExtensionRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'prefer_enum_members_over_extension',
    'Prefer enum members over local enum extensions when the enum is declared in the same library.',
    correctionMessage:
        'Move the members into the enum or suppress this rule if the separation is intentional.',
  );

  PreferEnumMembersOverExtensionRule()
    : super(
        name: 'prefer_enum_members_over_extension',
        description:
            'Reports extension-on-enum declarations when the enum is declared in the same library.',
      );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    registry.addExtensionDeclaration(this, _Visitor(this));
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  _Visitor(this.rule);

  final PreferEnumMembersOverExtensionRule rule;

  @override
  void visitExtensionDeclaration(ExtensionDeclaration node) {
    final extendedType = node.onClause?.extendedType;
    if (extendedType is! NamedType) {
      return;
    }

    final extendedElement = extendedType.element;
    if (extendedElement is! EnumElement) {
      return;
    }

    final extensionLibrary = node.declaredFragment?.element.library;
    final enumLibrary = extendedElement.library;
    if (extensionLibrary == null || enumLibrary == null) {
      return;
    }

    if (!identical(enumLibrary, extensionLibrary)) {
      return;
    }

    final nameToken = node.name;
    if (nameToken != null) {
      rule.reportAtToken(nameToken);
      return;
    }

    rule.reportAtToken(node.extensionKeyword);
  }
}
