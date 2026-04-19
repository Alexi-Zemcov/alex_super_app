import 'package:alex_workspace_lints/src/fixes/style/move_extension_members_into_enum_fix.dart';
import 'package:alex_workspace_lints/src/plugin.dart';
import 'package:analysis_server_plugin/src/registry.dart'; // ignore: implementation_imports
import 'package:test/test.dart';

void main() {
  test('registers quick fix for prefer_enum_members_over_extension', () {
    final registry = PluginRegistryImpl('alex_workspace_lints');

    AlexWorkspaceLintsPlugin().register(registry);

    final codes = registry.fixKinds[MoveExtensionMembersIntoEnumFix.kind];
    expect(codes, isNotNull);
    expect(codes, contains('prefer_enum_members_over_extension'));
  });
}
