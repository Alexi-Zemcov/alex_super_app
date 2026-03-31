# Workspace и роли пакетов

## Когда открывать

- Нужно понять, где должен жить новый код.
- Нужно решить, делать ли новый package или положить код в существующий.
- Нужно быстро вспомнить роли `apps/*`, `modules/*`, `packages/core/*` и `tools/*`.

## Базовая единица архитектуры

Базовая единица архитектуры - отдельный Dart/Flutter package внутри workspace.

Контейнерные директории вроде `modules/`, `packages/` и `tools/` сами по себе пакетами не являются. В workspace перечисляются только реальные директории с `pubspec.yaml`.

## Текущий каркас

```text
apps/
  super_app/                  # shell-приложение
  quiz_app/                   # standalone host для quiz

modules/
  quiz/                       # самостоятельный продуктовый модуль

packages/
  core/
    app_theme/                # общая тема и theme controller
    module_contracts/         # публичные контракты shell <-> modules
    scoped_di/                # shared DI primitives

tools/
  mason/                      # генераторы и служебные инструменты
```

## Роли директорий

- `apps/*` - runnable приложения и composition roots.
- `modules/*` - самостоятельные продуктовые модули.
- `packages/core/*` - shared contracts и infrastructure packages.
- `tools/*` - шаблоны, генераторы и утилиты, не runtime-слой.

## Роль shell-приложения

`apps/super_app` - shell и composition root.

Здесь живут:

- сборка `MaterialApp`
- общие зависимости приложения
- каталог модулей
- навигация верхнего уровня между shell и модулями
- явное подключение модулей

Shell не должен становиться местом, куда стекается бизнес-логика всех фич.

## Роль продуктового модуля

Каждый модуль в `modules/<module_name>` - отдельный package со своим `pubspec.yaml`, тестами, asset'ами, DI и внутренней навигацией.

На примере `modules/quiz`:

- наружу публикуется только `quizModule`
- внутри есть `features/`, `di/`, `navigation/`
- модуль сам поднимает свой `Navigator` и свой feature scope

Внутри модуля нужно использовать feature-first:

```text
modules/quiz/lib/src/
  module/
  navigation/
  di/
  features/
    home/
      presentation/
      domain/
      data/
      di/
    quiz/
      presentation/
      domain/
      data/
      di/
```

Модульная архитектура не отменяет `presentation / domain / data`, а поднимает границу выше:

- сначала package/module
- потом feature
- потом слои внутри feature

## Роль core-пакетов

`packages/core/*` - общие пакеты, которые не являются отдельными продуктовыми модулями.

Сейчас:

- `app_theme` - theme primitives, controller, shared visual layer
- `module_contracts` - минимальные контракты между shell и модулями
- `scoped_di` - shared primitives для provider-based scope tree

Сюда имеет смысл класть только то, что действительно переиспользуется несколькими пакетами.
