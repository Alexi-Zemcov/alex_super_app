import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';

class MoveExtensionMembersIntoEnumFix extends ResolvedCorrectionProducer {
  static const FixKind kind = FixKind(
    'alex_workspace_lints.fix.move_extension_members_into_enum',
    50,
    'Move extension members into enum',
  );

  MoveExtensionMembersIntoEnumFix({required super.context});

  @override
  CorrectionApplicability get applicability =>
      CorrectionApplicability.singleLocation;

  @override
  FixKind get fixKind => kind;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final extensionDeclaration = node
        .thisOrAncestorOfType<ExtensionDeclaration>();
    if (extensionDeclaration == null) {
      return;
    }

    if (extensionDeclaration.typeParameters != null ||
        extensionDeclaration.members.isEmpty) {
      return;
    }

    final extendedType = extensionDeclaration.onClause?.extendedType;
    if (extendedType is! NamedType) {
      return;
    }
    if (extendedType.typeArguments != null) {
      return;
    }

    final extendedElement = extendedType.element;
    if (extendedElement is! EnumElement) {
      return;
    }

    final enumLibrary = extendedElement.library;
    if (enumLibrary.firstFragment.source.fullName !=
        libraryElement2.firstFragment.source.fullName) {
      return;
    }

    final enumDeclaration = await getEnumDeclaration(
      extendedElement.firstFragment,
    );
    if (enumDeclaration == null) {
      return;
    }

    final enumFilePath =
        enumDeclaration.declaredFragment?.libraryFragment.source.fullName;
    if (enumFilePath == null) {
      return;
    }
    final movedMembers = extensionDeclaration.members
        .map(utils.getNodeText)
        .join('\n\n');

    await builder.addDartFileEdit(enumFilePath, (builder) {
      if (enumDeclaration.semicolon == null) {
        final constants = enumDeclaration.constants;
        if (constants.isEmpty) {
          return;
        }
        builder.addSimpleInsertion(constants.last.end, ';');
      }
      builder.addSimpleInsertion(
        enumDeclaration.rightBracket.offset,
        '\n\n$movedMembers\n',
      );
    });

    await builder.addDartFileEdit(file, (builder) {
      builder.addDeletion(
        SourceRange(extensionDeclaration.offset, extensionDeclaration.length),
      );
    });
  }
}
