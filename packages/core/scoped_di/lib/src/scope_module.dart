import 'package:flutter/foundation.dart';
import 'package:provider/single_child_widget.dart';

abstract class ScopeModule {
  const ScopeModule();

  String get moduleId => '$runtimeType';

  List<ScopeModule> get dependencies => const [];

  List<SingleChildWidget> get providers;
}

List<SingleChildWidget> resolveScopeModules(List<ScopeModule> modules) {
  assert(() {
    _debugValidateScopeModules(modules);
    return true;
  }());

  final orderedModules = <ScopeModule>[];
  final addedModuleIds = <String>{};

  void visit(ScopeModule module) {
    if (!addedModuleIds.add(module.moduleId)) {
      return;
    }

    for (final dependency in module.dependencies) {
      visit(dependency);
    }

    orderedModules.add(module);
  }

  for (final module in modules) {
    visit(module);
  }

  return [for (final module in orderedModules) ...module.providers];
}

void _debugValidateScopeModules(List<ScopeModule> modules) {
  final resolvedModuleIds = <String>{};
  final visitingStack = <String>[];

  void visit(ScopeModule module) {
    final moduleId = module.moduleId;
    final cycleStartIndex = visitingStack.indexOf(moduleId);
    if (cycleStartIndex != -1) {
      final cycle = [
        ...visitingStack.skip(cycleStartIndex),
        moduleId,
      ].join(' -> ');

      throw FlutterError('Circular ScopeModule dependency detected: $cycle');
    }

    if (resolvedModuleIds.contains(moduleId)) {
      throw FlutterError(
        'Duplicate ScopeModule moduleId "$moduleId" detected in the same '
        'scope. Remove the duplicate module or override moduleId for '
        'parameterized modules.',
      );
    }

    visitingStack.add(moduleId);

    for (final dependency in module.dependencies) {
      visit(dependency);
    }

    visitingStack.removeLast();
    resolvedModuleIds.add(moduleId);
  }

  for (final module in modules) {
    visit(module);
  }
}
