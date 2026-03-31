# super_app

Shell-приложение workspace. Отвечает за composition root, публикацию app-level зависимостей и подключение продуктовых модулей.

## Основные точки входа

- `lib/main.dart` - запуск приложения
- `lib/src/app.dart` - сборка `MaterialApp` и список подключённых модулей
- `lib/src/di/super_app_scope_module.dart` - shell-level DI
- `lib/src/shell/dashboard_page.dart` - UI верхнего уровня для каталога модулей

## Актуальные docs

- [Архитектурный индекс](../../docs/architecture.md)
- [Workspace и роли пакетов](../../docs/architecture/workspace-packages.md)
- [Подключение модуля и публичный entry point](../../docs/architecture/module-entrypoints.md)
- [Границы зависимостей между пакетами](../../docs/architecture/dependency-boundaries.md)
- [Правила DI](../../docs/architecture/di.md)
