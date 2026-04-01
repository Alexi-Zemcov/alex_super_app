# Alex Super App Codex Rules

## Workspace architecture

- Treat the root `pubspec.yaml` workspace list as the source of truth for package boundaries.
- The base architectural unit is a Dart/Flutter package, not a container directory.
- `apps/*` are runnable apps and composition roots.
- `modules/*` are standalone product modules with their own assets, tests, DI, and internal navigation.
- `packages/core/*` are shared contracts and infrastructure packages reused by multiple packages.
- `tools/*` are generators and utilities, not runtime product code.

## Dependency boundaries

- `apps/*` may depend on `modules/*` and `packages/core/*`.
- `modules/*` may depend on `packages/core/*`.
- `modules/*` must not depend on `apps/*`.
- `packages/core/*` must stay product-agnostic and must not depend on `apps/*` or concrete `modules/*`.
- Do not import another module's `src/*` or internal implementation types.
- If a new dependency breaks these rules, either move a small shared contract to `packages/core/*` or keep orchestration in the shell.

## Module integration

- The shell imports a module only through a single public entry point such as `package:quiz/quiz.dart`.
- A module exports only its integration contract, typically an `AppModuleDescriptor` or factory.
- Do not export `src/*`, BLoCs, repositories, datasources, or other internal layer types from a module.
- Each module owns its root widget, internal DI, and internal navigation.
- Register modules in the shell explicitly; do not move a module's internal routing into the shell without a clear reason.

## DI model

- Use provider-based DI only: `ScopeModule`, `FeatureScope`, `RouteScope`, `Provider`, `RepositoryProvider`, `ChangeNotifierProvider`, and `BlocProvider`.
- Create dependencies only in `apps/*/lib/src/di`, `modules/*/lib/src/di`, `modules/*/lib/src/features/*/di`, or scope widgets.
- The shell publishes only app and platform dependencies such as `AssetBundle`, `SharedPreferences`, and theme state.
- Module scope owns repositories, datasources, and long-lived module services.
- Route or feature scope owns screen-specific use cases and `Bloc` or `Cubit` instances by default.
- Do not import `provider` or `flutter_bloc` into `data`, `domain`, `entities`, `repositories`, `datasources`, or `usecases`.
- Do not assemble repositories, use cases, or BLoCs directly in routers, pages, or widgets when a DI module exists.

## Feature contracts and data

- Prefer small public contracts between features and modules: command, query, or observe.
- Do not default to `Stream`; use it only for live shared state with multiple consumers or automatic shell or UI reactions.
- DTOs and generated API models are not domain entities; mapping belongs in the data layer.
- Repository implementations own cache policy and source selection.
- Datasources provide low-level read and write access only.

## Repo-local skills

- Use `$workspace-boundaries` when deciding where new code belongs, whether a new package is needed, or whether an import is allowed.
- Use `$module-integration` when adding a new module, public entry point, or shell registration.
- Use `$feature-scoped-di` when adding or changing `ScopeModule`, `FeatureScope`, `RouteScope`, or feature wiring.
- Use `$feature-contracts-data` when designing feature-to-feature contracts, deciding on `Stream`, or shaping DTO/repository/cache boundaries.

## Docs lookup

- For library, framework, SDK, API, CLI tool, or cloud questions, use `ctx7`: resolve the library first and then fetch docs with the full user question.
- Do not rely on memory for library-specific syntax, configuration, or migrations.
- Do not use `ctx7` for repo architecture, refactoring, code review, or general programming concepts.
