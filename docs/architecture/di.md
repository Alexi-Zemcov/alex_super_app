# Правила DI

## 1. Базовый принцип

В проекте используется native Flutter-style DI через provider-based scope tree:

- `Provider` — для простых зависимостей и use case
- `RepositoryProvider` — для repository-контрактов
- `ChangeNotifierProvider` — для `ChangeNotifier`
- `BlocProvider` — для `Bloc`

DI строится через дерево виджетов, а не через глобальный service locator.

Главное правило:

> объект получает зависимости через конструктор, а публикация зависимостей происходит только в `app` и `di`-слоях.

## 2. Где живёт DI

DI должен быть разложен по трём уровням.

### `apps/*`

Shell-приложение публикует только общие внешние зависимости и shared app state.

Примеры:

- `AssetBundle`
- `SharedPreferences`
- theme controller

Shell не должен собирать feature-specific BLoC, use case или repository конкретного модуля.

### `modules/<module>/lib/src/di`

Это module-level DI.

Здесь живут:

- `ScopeModule`
- `FeatureScope`
- `RouteScope`
- module-wide wiring, которое нужно всему модулю

Module scope поднимается в root widget модуля и публикует зависимости, общие для всех внутренних маршрутов.

### `modules/<module>/lib/src/features/*/di`

Это feature-specific DI.

Здесь живут:

- `<FeatureName>Module`
- `<FeatureName>RouteScope`

Feature DI отвечает за wiring конкретной feature или экрана.

## 3. Scope-модель

### `FeatureScope`

`FeatureScope` используется для module root или другого долгоживущего scope.

Подходит для:

- repository
- datasource
- сервисов feature/module уровня
- use case, которые должны жить дольше одного route

### `RouteScope`

`RouteScope` используется для wiring маршрута или flow.

Подходит для:

- экранных use case
- route-specific `Bloc`
- зависимостей, которые нужны только внутри конкретного route subtree

Дефолтное правило:

- repository держим в module scope
- `Bloc` держим в route scope

Если dependency реально нужна нескольким маршрутам внутри модуля, её можно поднять выше в `FeatureScope`.

## 4. Контракт `ScopeModule`

Каждый DI-модуль должен реализовывать `ScopeModule`.

У `ScopeModule` есть:

- `moduleId`
- `dependencies`
- `providers`

Правила:

- `dependencies` описывают только DI-зависимости, а не бизнес-иерархию
- зависимости резолвятся depth-first: сначала dependencies, потом текущий модуль
- `moduleId` должен быть уникален внутри одного scope
- если модуль параметризованный, `moduleId` нужно переопределять явно

Нельзя:

- молча дублировать один и тот же модуль в одном scope
- строить циклические зависимости между модулями

## 5. Что можно импортировать

### Разрешено импортировать `provider`/`flutter_bloc`

- в `apps/*`
- в `modules/*/lib/src/di`
- в `modules/*/lib/src/features/*/di`
- в route/scope widgets

### Нельзя импортировать `provider`

- в `data`
- в `domain`
- в `entities`
- в `repositories`
- в `datasources`
- в `usecases`

`presentation/pages` и `presentation/widgets` могут читать уже опубликованные зависимости через `context.read/watch/select`, но не должны сами заниматься DI wiring.

## 6. Что публиковать на каком уровне

### В shell

Публикуем только то, что модулю даёт приложение или платформа.

Примеры текущей схемы:

- `AssetBundle`
- `SharedPreferences`
- `AppThemeController`

### В module DI

Публикуем общие зависимости модуля.

Примеры для `quiz`:

- `QuizCatalogBuilder`
- `QuestionLocalDataSource`
- `ProgressLocalDataSource`
- `QuestionRepository`
- `ProgressRepository`

### В feature DI

Публикуем feature-specific use case и `Bloc`.

Пример для `home`:

- `GetHomeProgressUseCase`
- `HomeBloc`

## 7. Чего делать нельзя

- Не использовать `GetIt`, service locator или глобальные singleton registry.
- Не создавать repository/use case/BLoC прямо в router, page или widget tree “по месту”, если для этого есть `di`-слой.
- Не прокидывать `repository_impl` или `datasource` в presentation.
- Не импортировать `src/di` одного модуля из другого модуля напрямую.
- Не смешивать shell DI и internal module DI в одном файле.
- Не публиковать одну и ту же зависимость на нескольких уровнях без явной причины.

## 8. Naming conventions

Используем такие имена:

- `<FeatureName>Module` — набор provider registration для feature
- `<FeatureName>RouteScope` — route/widget wrapper, который поднимает scope
- `FeatureScope` — общий scope для module root
- `RouteScope` — scope для маршрута или flow

Если модуль публикует data-level зависимости всей feature-группы, имя должно это отражать.

Пример:

- `QuizDataModule`

## 9. Практический шаблон для новой feature

Для новой feature нужно сделать следующее:

1. Создать `features/<feature>/di/<feature>_module.dart`.
2. Зарегистрировать в модуле все use case и `Bloc`, которые нужны экрану.
3. Создать `features/<feature>/di/<feature>_route_scope.dart`.
4. В router возвращать `RouteScope`, а не вручную собирать `BlocProvider(create: ...)`.
5. Оставить page/widget только потребление уже готовых зависимостей.

## 10. Критерий корректного DI

DI считается оформленным правильно, если выполняются все условия:

- shell публикует только app/platform зависимости
- module root поднимает `FeatureScope`
- route поднимает `RouteScope`
- `data` и `domain` ничего не знают про provider
- router не знает, как собирать use case и repository
- widget не знает, как создавать dependency graph
- зависимости читаются из scope, но создаются только в `di`-слое
