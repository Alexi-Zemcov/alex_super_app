# Карта архитектурных docs

Этот файл больше не хранит все правила в одном месте. Он нужен как навигатор, чтобы новый агент мог открыть только тот документ, который нужен под текущую задачу.

## Что открывать по задаче

- Нужно понять, куда положить новый пакет, модуль или shared код:
  [workspace-packages.md](architecture/workspace-packages.md)
- Нужно подключить модуль к shell или оформить публичный entry point:
  [module-entrypoints.md](architecture/module-entrypoints.md)
- Нужно проверить, допустима ли зависимость между пакетами:
  [dependency-boundaries.md](architecture/dependency-boundaries.md)
- Нужно выбрать способ общения между фичами, use case или stream:
  [feature-communication.md](architecture/feature-communication.md)
- Нужно принять решение по DTO, API clients, repository и cache strategy:
  [data-layer.md](architecture/data-layer.md)
- Нужно разобраться с provider-based DI и scope tree:
  [di.md](architecture/di.md)

## Быстрый контекст

- Базовая единица архитектуры в этом репозитории - отдельный Dart/Flutter package внутри workspace.
- `apps/*` - runnable приложения и composition roots.
- `modules/*` - самостоятельные продуктовые модули.
- `packages/core/*` - общие контракты и инфраструктурные пакеты.
- `tools/*` - генераторы и служебные инструменты, не runtime-слой.

## Когда достаточно только этого файла

Открывай только этот индекс, если нужно быстро понять, где искать правило, но не нужна сама детализация.
