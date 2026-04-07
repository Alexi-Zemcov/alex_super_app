---
name: feature-contracts-data
description: Use when designing feature-to-feature contracts, deciding whether communication should be command/query/observe or Stream-based, or shaping DTO, repository, datasource, and cache boundaries.
---

# Feature Contracts And Data

## Use This Skill When

- A task designs communication between features, modules, or a host app and a module.
- A task asks whether to use `Stream`, callback, command, query, or a small shared contract.
- A task introduces DTOs, generated API models, API clients, repositories, datasources, or cache policy.
- A dependency might need a `mediator` in `packages/core/*` or a shared adapter in `packages/integrations/*`.

## Read These First

- `AGENTS.md`
- `docs/architecture/dependency-boundaries.md`
- `docs/architecture/data-layer.md`
- `packages/README.md`

## Workflow

1. Decide the boundary first.
   - Cross-module or cross-feature collaboration should happen through a small public contract, not through another module's `src/*`.
   - Default to `command`, `query`, or `observe` style APIs.
   - Put cross-module mediators in a dedicated workspace package under `packages/core/mediators/<name>` when a stable shared contract is needed.
   - If you extract a mediator or integration boundary, create a real workspace package with its own `pubspec.yaml`, a public entry point, and a root `pubspec.yaml` `workspace:` entry.
2. Only choose `Stream` when the state is truly live.
   - Good fit: shared live state with multiple consumers or automatic shell or UI reactions.
   - Prefer a plain method, `Future`, or command/query contract for request-response or one-shot actions.
3. Separate transport models from domain.
   - DTOs and generated API models are not domain entities.
   - Keep mapping in `data/mappers` or repository-owned data layer code.
   - Keep product-specific entities, use cases, and orchestration inside the owning module.
4. Put external integration boundaries in the right place.
   - Shared vendor adapters and typed SDK wrappers belong in a dedicated workspace package under `packages/integrations/<name>`.
   - Shell-only wiring stays in `apps/*`.
   - Module-only integration details stay inside the owning module until a stable shared boundary emerges.
5. Keep repository and datasource responsibilities narrow.
   - Datasources do low-level read and write only.
   - Repositories own cache policy, source selection, fallback, and refresh decisions.
   - Reuse a shared cache helper only after the same policy repeats across repositories.
6. If a new dependency would break package boundaries, either move a small mediator to `packages/core/mediators/<name>`, move a product-agnostic integration adapter to `packages/integrations/<name>`, or keep orchestration in the host app or shell.

## Current Pattern

- `packages/core/module_contracts/lib/module_contracts.dart` shows a small public contract package used by hosts and modules.
- `modules/quiz/lib/src/features/quiz/data/models/quiz_question_model.dart` is a data model, not a domain entity.
- `modules/quiz/lib/src/features/quiz/data/repositories/progress_repository_impl.dart` and `modules/quiz/lib/src/features/quiz/data/repositories/question_repository_impl.dart` keep repository responsibilities in the data layer.

## Avoid

- Do not expose `Bloc`, `RepositoryImpl`, datasource, or `src/*` as a public collaboration contract.
- Do not default to `Stream` for one-shot requests or command-style interactions.
- Do not let DTOs leak into `domain` or `presentation`.
- Do not move cache policy into datasources.
