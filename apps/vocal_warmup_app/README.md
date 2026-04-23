# vocal_warmup_app

Отдельное приложение-хост для прямого запуска модуля `vocal_warmup` без super app shell.

## Основные точки входа

- `lib/main.dart` - запуск приложения
- `lib/src/app.dart` - сборка `MaterialApp` и подключение `vocalWarmupModule`
- `lib/src/di/vocal_warmup_app_scope_module.dart` - app-level DI для standalone host

## Актуальные docs

- [Архитектурный индекс](../../docs/architecture.md)
- [Workspace и роли пакетов](../../docs/architecture/workspace-packages.md)
- [Подключение модуля и публичный entry point](../../docs/architecture/module-entrypoints.md)
- [Границы зависимостей между пакетами](../../docs/architecture/dependency-boundaries.md)
- [Правила DI](../../docs/architecture/di.md)
