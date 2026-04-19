import 'package:alex_workspace_lints/src/rules/architecture/enforce_layer_import_direction_rule.dart';
import 'package:analysis_server_plugin/registry.dart';

void registerArchitectureRules(PluginRegistry registry) {
  registry.registerLintRule(EnforceLayerImportDirectionRule());
}
