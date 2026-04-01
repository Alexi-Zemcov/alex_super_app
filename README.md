# alex-super-app

Flutter monorepo for a personal super app of pet projects, built on Dart/Flutter workspaces.

## Workspace Layout

```text
apps/
  super_app/

modules/
  quiz/
  circle_of_fifths/

packages/
  core/
    app_theme/
    design_system/
    module_contracts/
  integrations/

tools/
  scripts/
```

## Flutter SDK

This repo uses [FVM](https://fvm.app/) and pins Flutter in [`.fvmrc`](./.fvmrc).

```sh
fvm install
fvm flutter pub get
```

## Common Commands

Resolve the whole workspace from the repository root:

```sh
fvm flutter pub get
fvm dart pub workspace list
```

Run the current app shell:

```sh
cd apps/super_app
fvm flutter run
```

Run tests for a member package:

```sh
cd modules/quiz
fvm flutter test
```

## Notes

- The repository root is a workspace root, not a runnable Flutter app.
- `apps/super_app` is the current executable shell.
- `modules/circle_of_fifths`, `packages/core/design_system`, and `packages/integrations` are reserved for future packages and intentionally do not have `pubspec.yaml` files yet.
