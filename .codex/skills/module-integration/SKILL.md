---
name: module-integration
description: Use when adding a new product module, defining its public entry point, or wiring a module into the shell through AppModuleDescriptor-style integration without leaking internal src APIs.
---

# Module Integration

## Use This Skill When

- A task adds a new package under `modules/*`.
- The shell must connect a module through a public entry point.
- A module needs a clean public API for integration.

## Read These First

- `docs/architecture/module-entrypoints.md`
- `packages/core/module_contracts/lib/src/app_module_descriptor.dart`
- `modules/quiz/lib/quiz.dart`
- `modules/quiz/lib/src/module/quiz_module.dart`
- `apps/super_app/lib/src/app.dart`

## Workflow

1. Create the module as its own workspace package under `modules/<name>` and add it to the root `pubspec.yaml`.
2. Expose one public entry point at `lib/<module>.dart`.
3. Export only the integration contract from that file, usually an `AppModuleDescriptor` or factory.
4. Build the module root so the module owns its `FeatureScope`, root widget, and internal `Navigator` when needed.
5. Add the package dependency to the shell app and register the module through an explicit import and module list entry.

## Current Pattern

- `modules/quiz/lib/quiz.dart` exports only `quizModule`.
- `modules/quiz/lib/src/module/quiz_module.dart` builds the module root and internal navigation.
- `apps/super_app/lib/src/app.dart` imports modules explicitly and passes descriptors into shell UI.

## Avoid

- Do not import `src/*` from the shell.
- Do not export internal `bloc`, `repository_impl`, `datasource`, or router classes from a module.
- Do not move a module's internal navigation into the shell without a concrete need.
