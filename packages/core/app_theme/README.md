# app_theme

Shared UI-пакет с theme primitives, `AppThemeController` и хранением пользовательского выбора темы.

## Основные точки входа

- `lib/app_theme.dart` - публичный export пакета
- `lib/src/app_theme_controller.dart` - управление активной темой
- `lib/src/app_theme_factory.dart` - сборка `ThemeData`
- `lib/src/shared_preferences_theme_store.dart` - persistence для theme preference

## Актуальные docs

- [Архитектурный индекс](../../../docs/architecture.md)
- [Workspace и роли пакетов](../../../docs/architecture/workspace-packages.md)
- [Границы зависимостей между пакетами](../../../docs/architecture/dependency-boundaries.md)
- [Правила DI](../../../docs/architecture/di.md)
