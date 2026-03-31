## 1. Как раскладывать по пакетам при модульной архитектуре

Базовая единица архитектуры - отдельный Dart/Flutter package внутри workspace.

Текущий каркас проекта такой:

```text
apps/
  super_app/                  # shell-приложение

modules/
  quiz/                       # самостоятельный продуктовый модуль

packages/
  core/
    app_theme/               # общая тема и theme controller
    module_contracts/        # публичные контракты shell <-> modules

tools/
  mason/                     # генераторы и служебные инструменты
```

То есть:

- `apps/*` — runnable приложения
- `modules/*` — самостоятельные продуктовые модули
- `packages/core/*` — общие контракты и инфраструктурные пакеты
- `tools/*` — генераторы, шаблоны, утилиты, не runtime-слой

Важно:

- в `workspace` перечисляются реальные пакеты с `pubspec.yaml`
- контейнерные директории вроде `modules/`, `packages/`, `tools/` сами по себе пакетами не являются

## 2. Роли пакетов

### `apps/super_app`

Это shell и composition root.

Здесь живут:

- сборка `MaterialApp`
- общие зависимости приложения
- каталог модулей
- навигация верхнего уровня между shell и модулями
- явное подключение модулей

Shell не должен становиться местом, куда стекается бизнес-логика всех фич.

### `modules/<module_name>`

Каждый модуль — отдельный package со своим `pubspec.yaml`, тестами, asset'ами, DI и внутренней навигацией.

Например, `modules/quiz`:

- публикует наружу только `quizModule`
- внутри держит свои `features/`, `di/`, `navigation/`
- сам поднимает свой `Navigator` и свой feature scope

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

То есть модульная архитектура не отменяет `presentation / domain / data`, а поднимает границу выше:

- сначала package/module
- потом feature
- потом слои внутри feature

### `packages/core/*`

Это общие пакеты, которые не являются отдельными продуктовыми модулями.

Сейчас:

- `app_theme` — theme primitives, controller, shared visual layer
- `module_contracts` — минимальные контракты между shell и модулями, например `AppModuleDescriptor`

Сюда имеет смысл класть только то, что действительно переиспользуется несколькими пакетами.

## 3. Зависимости между пакетами

Нормальная направленность зависимостей такая:

- `apps/*` могут зависеть от `modules/*` и `packages/core/*`
- `modules/*` могут зависеть от `packages/core/*`
- `modules/*` не должны зависеть от `apps/*`
- один модуль не должен зависеть от внутренних директорий другого модуля
- `packages/core/*` не должны зависеть от `apps/*` и конкретных `modules/*`

Практическое правило для публичного API модуля:

- shell должен импортировать модуль через один entry point, например `package:quiz/quiz.dart`
- модуль должен экспортировать наружу только маленький контракт подключения

В текущей схеме это выглядит так:

- `module_contracts` объявляет `AppModuleDescriptor`
- модуль публикует `const quizModule = AppModuleDescriptor(...)`
- shell собирает список модулей через явные импорты и передаёт его в `DashboardPage`

Это хороший дефолт для super app:

- shell знает, какие модули подключены
- модуль сам владеет своим root widget, DI и internal routing
- связь между shell и модулем остаётся минимальной и явно типизированной

Если модулю нужен доступ к общей возможности, есть два допустимых варианта:

- вынести контракт в `packages/core/*`
- связать модули через shell/coordinator, а не напрямую

Плохо:

- импортировать `src/` другого модуля
- тащить `repository_impl`, `bloc`, `datasource` из соседнего модуля
- делать `apps/super_app` местом общей бизнес-логики модулей

## 4. UseCase, события, стримы

Обычно хватает:

- BLoC
- coordinator
- query/command интерфейсов
- иногда observe-контрактов

Use case можно использовать как:

- command — “сделай что-то”
- query — “верни что-то”
- observe — “дай поток изменений”

Но лучше не маскировать под use case всё подряд без разбора. Полезнее общее правило:

> между фичами общаемся через маленькие публичные контракты, а внутри это может быть:

- command
- query
- observe

Стримы не нужны по умолчанию

Например:

- если auth меняется, coordinator/guard может просто перестроить flow
- если корзина нужна только на экране корзины, её можно грузить on-enter через use case

То есть Stream<User?> или Stream нужны только если нужен live shared state:

- несколько потребителей
- открытый UI должен обновляться сам
- app shell должен автоматически реагировать

## 5. Swagger / generated DTO / API clients

Если DTO и API-клиенты генерируются из Swagger, обычно их кладут в общий инфраструктурный модуль, а не в фичу, особенно
если они могут использоваться несколькими фичами или модулями.

Например:

```text
packages/
  core/
    api_clients/
      lib/
        src/generated/
          auth_api/
          orders_api/

modules/
  quiz/
  circle_of_fifth/
```

Тогда:

- generated DTO / API clients живут в общем infrastructure package

в фиче или модуле лежат:

- repository_impl
- remote/local datasource
- mappers
- domain entities
- use cases
- presentation

То есть:

- Swagger DTO != domain entity
- mapping DTO -> Entity обычно делается в `data/mappers`
- orchestration и выбор источника данных делает репозиторий

## 6. Где должна жить cache strategy

Стратегии вроде:

- cache-first
- network-first
- stale-while-revalidate

— это обычно ответственность Repository, а не DataSource.

Потому что:

- DataSource должен просто уметь читать/писать
- Repository решает, когда брать cache, когда сеть, как делать fallback, refresh и обновление UI

Практическое правило

- если логика простая — держать прямо в RepositoryImpl
- если одна и та же логика повторяется во многих репозиториях — вынести в отдельную сущность в data layer

Например:

- CachePolicy
- CachedRequestExecutor
- OfflineFirstStrategy

То есть:

- DataSource — только низкоуровневый доступ
- CachePolicy — reusable orchestration
- Repository — место, где policy применяется

## 7. Что брать как базовую практику

Если собрать всё в один набор правил, получается так:

- Workspace состоит из отдельных пакетов, а не из одного большого `lib/`.
- `apps/super_app` — shell и composition root, а не место для feature-логики.
- Каждый продуктовый модуль живёт в `modules/<name>` как самостоятельный package.
- Внутри модуля можно и нужно держать `presentation / domain / data`, если это удобно для конкретной feature.
- Модуль должен публиковать наружу минимальный entry point, а не россыпь внутренних классов.
- Общие контракты и shared infrastructure нужно выносить в `packages/core/*`.
- Один модуль не должен импортировать `src/` другого модуля.
- Связь между модулями должна идти либо через shell, либо через маленький общий контракт.
- Swagger-generated код должен жить в общем infrastructure package.
- Cache strategy остаётся ответственностью Repository.

Практический чеклист для нового модуля:

1. Создать новый package в `modules/<name>`.
2. Добавить его в root `workspace`.
3. Описать наружный entry point в `lib/<name>.dart`.
4. Экспортировать из него descriptor/factory для подключения в shell.
5. Подключить пакет в `apps/super_app/pubspec.yaml`.
6. Зарегистрировать модуль в shell явным импортом и добавить в список модулей.
