---
name: workspace-boundaries
description: Use when deciding where new code belongs in this workspace, whether to create a new package or module, or whether an import or dependency across apps, modules, packages/core, packages/integrations, and tools is allowed.
---

# Workspace Boundaries

## Use This Skill When

- A task asks where to place new code in this repo.
- A task may require a new package, module, or shared contract.
- A new import or dependency might cross package boundaries.

## Read These First

- `pubspec.yaml`
- `docs/architecture/workspace-packages.md`
- `docs/architecture/dependency-boundaries.md`
- `packages/README.md`
- `modules/README.md`
- `tools/README.md`

## Workflow

1. Start from the root workspace list.
   - Treat the root `pubspec.yaml` `workspace:` list as the source of truth.
   - Container directories such as `modules/` and `packages/` are not packages by themselves.
2. Identify the owning boundary first:
   - `apps/*` for runnable hosts and composition roots.
   - `modules/*` for standalone product modules.
   - `packages/core/*` for shared contracts or infrastructure reused by multiple packages.
   - `packages/integrations/*` for shared adapters over external SDKs, services, or platform bridges.
   - `tools/*` for generators and non-runtime tooling.
3. Create a new package only when the boundary is independently owned or reused. Otherwise keep the code inside the current app or module.
4. Validate dependency direction:
   - Allowed: `apps -> modules/core/integrations`, `modules -> core`, `modules -> integrations` when the integration boundary is product-agnostic and reusable, `integrations -> core`.
   - Forbidden: `modules -> apps`, `core/integrations -> apps/modules`, cross-module `src/*`.
5. If the new dependency is not allowed, either extract a small `mediator` to `packages/core/*`, move a shared vendor adapter to `packages/integrations/*`, or keep the orchestration in the host app or shell.

## Current Anchors

- `apps/super_app`, `apps/quiz_app`, and `apps/circle_of_fifths_app` are runnable hosts.
- `modules/quiz` and `modules/circle_of_fifths` are product modules.
- `packages/core/app_theme`, `packages/core/module_contracts`, and `packages/core/scoped_di` are current shared runtime packages.
- `packages/integrations/*` is a valid boundary class but currently reserved; create a real package there only with its own `pubspec.yaml` and a root workspace entry.

## Avoid

- Do not turn `apps/super_app` into shared business logic for multiple modules.
- Do not move product-specific code into `packages/core/*` or `packages/integrations/*`.
