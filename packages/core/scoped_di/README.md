# scoped_di

Shared DI primitives для provider-based scope tree: `ScopeModule`, `FeatureScope` и `RouteScope`.

## Основные точки входа

- `lib/scoped_di.dart` - публичный export пакета
- `lib/src/scope_module.dart` - контракт DI-модуля
- `lib/src/feature_scope.dart` - долгоживущий scope уровня модуля или flow
- `lib/src/route_scope.dart` - scope уровня маршрута

## Актуальные docs

- [Архитектурный индекс](../../../docs/architecture.md)
- [Workspace и роли пакетов](../../../docs/architecture/workspace-packages.md)
- [Границы зависимостей между пакетами](../../../docs/architecture/dependency-boundaries.md)
- [Правила DI](../../../docs/architecture/di.md)
