import 'package:alex_workspace_lints/src/rules/register_example_rules.dart';
import 'package:analysis_server_plugin/plugin.dart';
import 'package:analysis_server_plugin/registry.dart';

class AlexWorkspaceLintsPlugin extends Plugin {
  @override
  String get name => 'alex_workspace_lints';

  @override
  void register(PluginRegistry registry) {
    registerExampleRules(registry);
  }
}
