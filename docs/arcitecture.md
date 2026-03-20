## 1. Как раскладывать по папкам при feature-first

Обычно так:

```
lib/
  app/
    di/
    router/

  core/
    network/
    api/
    utils/
    base/

  features/
    auth/
      presentation/
      domain/
      data/

    orders/
      presentation/
      domain/
      data/
```

То есть сначала feature, потом внутри неё:

- presentation — UI, BLoC/Cubit/ViewModel
- domain — entities, use cases, repository interfaces
- data — repository impl, data sources, mappers, models

Фича — это не “экран” и не “папка widgets”, а пользовательский сценарий / бизнес-возможность: auth, catalog, cart,
checkout, profile.

## 2. Зависимости между слоями

Нормальная направленность зависимостей такая:

- presentation -> domain
- data -> domain
- domain не знает ни про presentation, ни про data
- app связывает всё вместе
- core содержит общие инфраструктурные вещи

То есть:

- UI не должен знать про DataSource
- BLoC не должен знать про ApiClient
- UseCase не должен знать про Dio, MethodChannel, SharedPreferences
- Domain не должен зависеть от Flutter/UI

## 3. Зависимости между фичами

Главное правило:
одна фича не должна знать внутренности другой фичи.

Плохо:

- импортировать presentation/, data/, bloc/, repository_impl другой фичи

Нормально:

- зависеть только от маленького публичного контракта

### Есть 3 способа связи между фичами:

#### Вариант 1. Через app-уровень

app/coordinator связывает фичи, навигацию и flow.

Подходит для:

- route guards
- redirect на login
- orchestration flow

#### Вариант 2. Через публичный контракт фичи

Фича экспортирует наружу только небольшой API:

- AuthRepository
- CurrentUserProvider
- Logout
- IsAuthorized

Другие фичи знают только этот контракт, а не внутренности.

#### Вариант 3. Через общую abstraction в core

Если контракт реально общий для всей системы, его можно вынести в core/contracts, например:

- SessionReader
- FeatureFlagProvider
- Clock
- Logger

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
если они могут использоваться несколькими фичами.

Например:

```
lib/
  core/
    api/
      generated/
        auth_api/
        orders_api/

  features/
    auth/
      data/
      domain/
      presentation/
    orders/
      data/
      domain/
      presentation/
```

Тогда:

- generated DTO / API clients живут в core/api/generated

в фиче лежат:

- repository_impl
- remote/local datasource
- mappers
- domain entities
- use cases
- presentation

То есть:

- Swagger DTO ≠ domain entity
- mapping DTO -> Entity обычно делается в feature/data/mappers
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

## 7. Что в итоге можно брать как базовую практику

Если собрать всё в один простой набор правил, получается так:

- Делить проект по фичам, а не по техническим слоям на весь проект.
- Внутри фичи держать presentation / domain / data.
- Не импортировать внутренности чужой фичи.
- Между фичами общаться только через маленькие публичные контракты.
- Навигацию и flow держать на app/coordinator уровне.
- Generated Swagger code держать в общем infrastructure/shared модуле.
- DTO -> Entity маппинг и repository impl держать в фиче.
- Cache strategy считать ответственностью Repository.
