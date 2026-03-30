import 'dart:io';

import 'package:mason/mason.dart';

/// Mason hook that ensures `flutter_bloc` exists in the project's `pubspec.yaml`.
///
/// We intentionally do a minimal, string-based edit to avoid adding extra deps
/// to the hook runtime.
void run(HookContext context) {
  final pubspecFile = _findPubspecYaml(Directory.current);
  if (pubspecFile == null) {
    context.logger.warn(
      'feature_init: pubspec.yaml not found. Skipping flutter_bloc auto-add.',
    );
    return;
  }

  final pubspecPath = pubspecFile.path;
  final pubspec = pubspecFile.readAsStringSync();

  // If it's already present (anywhere), don't touch the file.
  if (pubspec.contains('flutter_bloc:')) {
    context.logger.info(
      'feature_init: flutter_bloc already present in pubspec.yaml ($pubspecPath).',
    );
    return;
  }

  const dependencyLine = '  flutter_bloc: ^9.1.1\n';
  final updated = _insertIntoDependencies(pubspec, dependencyLine);

  if (updated == pubspec) {
    context.logger.warn(
      'feature_init: Could not update dependencies section in pubspec.yaml ($pubspecPath).',
    );
    return;
  }

  pubspecFile.writeAsStringSync(updated);
  context.logger.info(
    'feature_init: Added flutter_bloc to pubspec.yaml ($pubspecPath). Run `flutter pub get` if needed.',
  );
}

File? _findPubspecYaml(Directory dir) {
  Directory current = dir;

  while (true) {
    final candidate = File('${current.path}${Platform.pathSeparator}pubspec.yaml');
    if (candidate.existsSync()) return candidate;

    final parent = current.parent;
    if (parent.path == current.path) return null;
    current = parent;
  }
}

String _insertIntoDependencies(String pubspec, String dependencyLine) {
  // Prefer inserting right after the `flutter:` SDK block.
  final sdkFlutterRegExp = RegExp(r'^(\s*)sdk:\s*flutter\s*$', multiLine: true);
  final sdkMatch = sdkFlutterRegExp.firstMatch(pubspec);
  if (sdkMatch != null) {
    final lineEnd = pubspec.indexOf('\n', sdkMatch.end);
    if (lineEnd != -1) {
      return pubspec.replaceRange(
        lineEnd + 1,
        lineEnd + 1,
        dependencyLine,
      );
    }
  }

  // Fallback: insert right after `dependencies:` line.
  const depsHeader = 'dependencies:';
  final headerIndex = pubspec.indexOf(depsHeader);
  if (headerIndex == -1) return pubspec;

  final afterHeaderLine = pubspec.indexOf('\n', headerIndex);
  if (afterHeaderLine == -1) return pubspec;

  final insertAt = afterHeaderLine + 1;
  return pubspec.replaceRange(insertAt, insertAt, dependencyLine);
}
