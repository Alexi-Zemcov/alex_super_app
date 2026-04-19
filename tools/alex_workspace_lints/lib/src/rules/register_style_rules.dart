import 'package:alex_workspace_lints/src/rules/style/prefer_enum_members_over_extension_rule.dart';
import 'package:analysis_server_plugin/registry.dart';

void registerStyleRules(PluginRegistry registry) {
  registry.registerLintRule(PreferEnumMembersOverExtensionRule());
}
