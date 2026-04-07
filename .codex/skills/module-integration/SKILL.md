---
name: module-integration
description: Use when adding a new product module, defining its public entry point, or wiring a module into a shell or standalone host through AppModuleDescriptor-style integration without leaking internal src APIs.
---

# Module Integration

## Use This Skill When

- A task adds a new package under `modules/*`.
- A shell or standalone host app must connect a module through a public entry point.
- A module needs a clean public API for integration.

## Read These First

- `docs/architecture/module-entrypoints.md`
- `packages/core/module_contracts/lib/src/app_module_descriptor.dart`
- `modules/quiz/lib/quiz.dart`
- `modules/circle_of_fifths/lib/circle_of_fifths.dart`
- `modules/quiz/lib/src/module/quiz_module.dart`
- `modules/circle_of_fifths/lib/src/module/circle_of_fifths_module.dart`
- `apps/super_app/lib/src/app.dart`
- `apps/quiz_app/lib/src/app.dart`
- `apps/circle_of_fifths_app/lib/src/app.dart`

## Workflow

1. Create the module as its own workspace package under `modules/<name>` and add it to the root `pubspec.yaml`.
2. Expose one public entry point at `lib/<module>.dart`.
3. Export only the integration contract from that file, usually an `AppModuleDescriptor` or factory.
4. Build the module root so the module owns its `FeatureScope`, root widget, and internal `Navigator` when needed.
5. Add the package dependency to each consuming app and register the module through an explicit import plus module list or router wiring.
6. Keep host apps importing only the public entry point and consuming descriptor data such as `title`, `entryLocation`, and `rootRoute`.

## Current Pattern

- `modules/quiz/lib/quiz.dart` exports only `quizModule`.
- `modules/circle_of_fifths/lib/circle_of_fifths.dart` exports only `circleOfFifthsModule`.
- `modules/quiz/lib/src/module/quiz_module.dart` and `modules/circle_of_fifths/lib/src/module/circle_of_fifths_module.dart` build the module root and internal navigation.
- `apps/super_app/lib/src/app.dart` imports modules explicitly and passes descriptors into shell UI.
- `apps/quiz_app/lib/src/navigation/quiz_app_router.dart` and `apps/circle_of_fifths_app/lib/src/navigation/circle_of_fifths_app_router.dart` show standalone host wiring through descriptor routes.

## Avoid

- Do not import `src/*` from the shell or a standalone host app.
- Do not export internal `bloc`, `repository_impl`, `datasource`, or router classes from a module.
- Do not move a module's internal navigation into the shell without a concrete need.
