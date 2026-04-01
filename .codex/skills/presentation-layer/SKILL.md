---
name: presentation-layer
description: Organize and refactor feature presentation code in this workspace. Use when creating or moving screens, deciding between `presentation/screens` and `presentation/widgets`, colocating screen-owned `Bloc` state with a single screen, splitting reusable feature UI out of a screen folder, or cleaning up legacy `pages`, `bloc`, and `models` layouts to match the current repo convention.
---

# Presentation Layer

Keep `presentation` feature-first and screen-oriented. Prefer a shallow top-level layout and colocate screen-only state with the owning screen.

## Read These First

- `docs/architecture/di.md`
- `modules/circle_of_fifths/lib/src/features/circle/presentation`
- `modules/quiz/lib/src/features/home/presentation`
- `modules/quiz/lib/src/features/home/di/home_module.dart`
- `modules/quiz/lib/src/features/home/di/home_route_scope.dart`

## Target Layout

```text
presentation/
  screens/
    home/
      home_screen.dart
      bloc/
        home_bloc.dart
        home_event.dart
        home_state.dart
      models/              # optional, only for screen-owned presentation types
        home_destination.dart
  widgets/
    feature_banner.dart    # reusable only inside this feature
```

## Workflow

1. Choose ownership first.
   - Put a screen widget in `presentation/screens/<screen>/<screen>_screen.dart`.
   - Put a `Bloc` for that screen in `presentation/screens/<screen>/bloc/`.
   - Put screen-owned presentation enums, view models, and constants in `presentation/screens/<screen>/models/` only when they are not shared by another screen.
   - Put reusable feature-only UI in `presentation/widgets/`.
2. Keep the top level shallow.
   - Default top-level directories under `presentation` are `screens` and `widgets`.
   - Add another top-level directory only when it clearly remains presentation-only and ownership would be worse inside a specific screen.
3. Keep screen state private to one screen.
   - One screen may have its own `Bloc`, events, and state.
   - Do not share that `Bloc` across multiple screens. If state must be shared, lift the contract to `domain` or move orchestration to DI and create separate screen states.
4. Keep DI out of presentation structure.
   - Create and publish `Bloc` instances in `features/*/di`, not inside `screen.dart` or widgets.
   - Let screens consume dependencies through `context.read`, `watch`, or `select`.
5. Rename by role while moving code.
   - Prefer `*Screen` over `*Page` for route-level widgets in this layout.
   - Rename folders to screen names such as `home`, `circle`, or `destination_placeholder`.
6. Clean up after the move.
   - Update imports, route scopes, and routers.
   - Remove empty legacy folders such as `presentation/pages`, `presentation/bloc`, or `presentation/models`.
   - Run formatting and analyze the changed feature package.

## Current Pattern

- `modules/circle_of_fifths/lib/src/features/circle/presentation/screens/circle/circle_screen.dart` owns the `circle` screen.
- `modules/circle_of_fifths/lib/src/features/circle/presentation/screens/circle/bloc/*` contains state used only by that screen.
- `modules/circle_of_fifths/lib/src/features/circle/presentation/widgets/*` contains reusable feature widgets.
- `modules/quiz/lib/src/features/home/presentation/screens/home/*` follows the same pattern, including screen-owned models under `models/`.

## Avoid

- Do not keep `pages`, `bloc`, and `models` as sibling top-level directories under `presentation` for new work.
- Do not place a reusable feature widget inside a single screen folder.
- Do not place a `Bloc` in `presentation/widgets` or share a screen `Bloc` between routes.
- Do not build repositories, use cases, or DI graphs in `screen.dart`, `widget.dart`, or `bloc.dart`.
- Do not move presentation-only types into `domain` just to share them between two widgets on the same screen.
