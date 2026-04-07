---
name: feature-scoped-di
description: Use when adding or refactoring provider-based DI with app scope modules, ScopeModule, FeatureScope, RouteScope, feature modules, or route scopes, especially when moving dependency creation out of routers, pages, and widgets.
---

# Feature Scoped DI

## Use This Skill When

- A task adds or changes an app scope module, `ScopeModule`, `FeatureScope`, or `RouteScope`.
- A route or feature needs new DI wiring.
- Repositories, use cases, or BLoCs are being assembled in the wrong layer and must move into `di`.

## Read These First

- `docs/architecture/di.md`
- `packages/core/scoped_di/lib/src/scope_module.dart`
- `packages/core/scoped_di/lib/src/feature_scope.dart`
- `packages/core/scoped_di/lib/src/route_scope.dart`
- `apps/super_app/lib/src/di/super_app_scope_module.dart`
- `apps/quiz_app/lib/src/di/quiz_app_scope_module.dart`
- `apps/circle_of_fifths_app/lib/src/di/circle_of_fifths_app_scope_module.dart`
- `modules/circle_of_fifths/lib/src/di/circle_of_fifths_scope_module.dart`
- `modules/quiz/lib/src/features/home/di/home_module.dart`
- `modules/quiz/lib/src/features/home/di/home_route_scope.dart`

## Workflow

1. Choose the scope level first:
   - Host app scope in `apps/*/lib/src/di` for app and platform dependencies only.
   - Module scope for repositories, datasources, and long-lived module services.
   - Route scope for screen-specific use cases and `Bloc` or `Cubit` instances by default.
2. Implement DI through `ScopeModule`:
   - `providers` defines published dependencies.
   - `dependencies` defines DI ordering only.
   - Override `moduleId` when the module is parameterized.
3. Keep routers returning `RouteScope` and module roots returning `FeatureScope`.
4. Keep pages and widgets as consumers only through `context.read`, `watch`, or `select`.

## Import Rules

- `provider` and `flutter_bloc` are allowed in app DI, module DI, feature DI, and scope widgets.
- They are not allowed in `data`, `domain`, `entities`, `repositories`, `datasources`, or `usecases`.

## Current Pattern

- `apps/super_app/lib/src/di/super_app_scope_module.dart` publishes shell-level dependencies.
- `apps/quiz_app/lib/src/di/quiz_app_scope_module.dart` and `apps/circle_of_fifths_app/lib/src/di/circle_of_fifths_app_scope_module.dart` show standalone host app scopes.
- `modules/quiz/lib/src/features/home/di/home_module.dart` publishes a feature use case and `HomeBloc`.
- `modules/quiz/lib/src/features/home/di/home_route_scope.dart` wraps the page in `RouteScope`.
- `modules/circle_of_fifths/lib/src/di/circle_of_fifths_scope_module.dart` shows the exception case where module-wide state is shared across routes.

## Avoid

- Do not use `GetIt` or a global service locator.
- Do not create repositories, use cases, or BLoCs inline in routers, pages, or widgets.
- Do not publish the same dependency at multiple levels without a clear lifetime reason.
