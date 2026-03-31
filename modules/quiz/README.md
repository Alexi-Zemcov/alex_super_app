# quiz

Самостоятельный продуктовый модуль с собственным `FeatureScope`, внутренней навигацией и feature-first структурой.

## Основные точки входа

- `lib/quiz.dart` - публичный entry point пакета
- `lib/src/module/quiz_module.dart` - `quizModule` и module root
- `lib/src/navigation/` - внутренний router и route names
- `lib/src/features/` - feature-first структура (`presentation / domain / data / di`)

## Актуальные docs

- [Архитектурный индекс](../../docs/architecture.md)
- [Workspace и роли пакетов](../../docs/architecture/workspace-packages.md)
- [Подключение модуля и публичный entry point](../../docs/architecture/module-entrypoints.md)
- [Границы зависимостей между пакетами](../../docs/architecture/dependency-boundaries.md)
- [Use case, события и стримы](../../docs/architecture/feature-communication.md)
- [Data layer: DTO, API clients и cache strategy](../../docs/architecture/data-layer.md)
- [Правила DI](../../docs/architecture/di.md)
