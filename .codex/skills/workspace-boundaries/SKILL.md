---
name: workspace-boundaries
description: Use when deciding where new code belongs in this workspace, whether to create a new package or module, or whether an import or dependency across apps, modules, core packages, and tools is allowed.
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

## Workflow

1. Identify the owning boundary first:
   - `apps/*` for runnable hosts and composition roots.
   - `modules/*` for standalone product modules.
   - `packages/core/*` for shared contracts or infrastructure reused by multiple packages.
   - `tools/*` for generators and non-runtime tooling.
2. Create a new package only when the boundary is independently owned or reused. Otherwise keep the code inside the current app or module.
3. Validate dependency direction:
   - Allowed: `apps -> modules/core`, `modules -> core`.
   - Forbidden: `modules -> apps`, `core -> apps/modules`, cross-module `src/*`.
4. If the new dependency is not allowed, either extract a small contract to `packages/core/*` or keep the orchestration in the shell.

## Current Anchors

- `apps/super_app`
- `modules/quiz`
- `packages/core/module_contracts`
- `packages/core/scoped_di`

## Avoid

- Do not turn `apps/super_app` into shared business logic for multiple modules.
- Do not move product-specific code into `packages/core/*`.
