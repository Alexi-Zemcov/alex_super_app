enum CleanArchitectureLayer {
  presentation,
  domain,
  data,
  di;

  bool allowsDependencyOn(CleanArchitectureLayer target) => switch (this) {
    CleanArchitectureLayer.presentation =>
      target == CleanArchitectureLayer.presentation ||
          target == CleanArchitectureLayer.domain,
    CleanArchitectureLayer.domain => target == CleanArchitectureLayer.domain,
    CleanArchitectureLayer.data =>
      target == CleanArchitectureLayer.data ||
          target == CleanArchitectureLayer.domain,
    CleanArchitectureLayer.di => true,
  };
}

final class LayeredLibraryPath {
  const LayeredLibraryPath._({
    required this.packageRoot,
    required this.relativePath,
    required this.layer,
  });

  final String packageRoot;
  final String relativePath;
  final CleanArchitectureLayer layer;

  static LayeredLibraryPath? parse(String? path) {
    if (path == null) {
      return null;
    }

    final normalizedPath = path.replaceAll('\\', '/');
    final libIndex = normalizedPath.indexOf('/lib/');
    if (libIndex == -1) {
      return null;
    }

    final layer = _detectLayer(
      normalizedPath.substring(libIndex + '/lib/'.length),
    );
    if (layer == null) {
      return null;
    }

    return LayeredLibraryPath._(
      packageRoot: normalizedPath.substring(0, libIndex),
      relativePath: normalizedPath.substring(libIndex + 1),
      layer: layer,
    );
  }

  static CleanArchitectureLayer? _detectLayer(String libRelativePath) {
    for (final segment in libRelativePath.split('/')) {
      for (final layer in CleanArchitectureLayer.values) {
        if (segment == layer.name) {
          return layer;
        }
      }
    }

    return null;
  }
}
