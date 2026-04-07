import 'package:alex_workspace_lints/src/rules/examples/avoid_await_in_lib_rule.dart';
import 'package:analysis_server_plugin/registry.dart';

void registerExampleRules(PluginRegistry registry) {
  registry.registerLintRule(AvoidAwaitInLibRule());
}
