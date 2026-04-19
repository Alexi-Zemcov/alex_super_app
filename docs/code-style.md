# Code Style

Repo-wide language-level conventions live here. This document is for Dart and Flutter code style rules that are broader than a single package, feature, or architecture topic.

## When to open this doc

- You are deciding whether a Dart `enum` should own behavior directly or through an `extension`.
- You are reviewing or refactoring code that adds helper APIs around a local `enum`.
- You need the full rationale and allowed exceptions behind the short guardrail from `AGENTS.md`.

## Prefer enhanced enum members over local enum extensions

If an `enum` is declared in the same editable library, keep its getters, methods, and `static` helpers inside the `enum`.

Do not add a companion extension such as `SavedInstrumentKindX` only to host behavior that enhanced enums can already express.

Prefer this:

```dart
enum SavedInstrumentKind {
  guitar,
  bass;

  static SavedInstrumentKind fromStorageValue(String value) {
    return switch (value) {
      'guitar' => SavedInstrumentKind.guitar,
      'bass' => SavedInstrumentKind.bass,
      _ => throw FormatException('Unsupported instrument kind: $value'),
    };
  }

  String get storageValue => name;
}
```

Instead of this:

```dart
enum SavedInstrumentKind { guitar, bass }

extension SavedInstrumentKindX on SavedInstrumentKind {
  static SavedInstrumentKind fromStorageValue(String value) { ... }

  String get storageValue => name;
}
```

## Why this is the default

- The enum API stays discoverable in one place.
- The public contract is easier to read during review and refactoring.
- The implementation uses the current Dart language model instead of carrying a legacy pattern forward.
- It avoids creating `EnumNameX` types when no actual extension boundary is needed.

## When `extension on enum` is still the right choice

Using an extension remains valid when one of these is true:

- The enum cannot be changed.
  Examples: external package, generated code, or code owned by another boundary.
- Serialization is intentionally kept outside the enum.
  Use this when conversion rules belong to a dedicated mapper or data-layer concern and should not become part of the enum's public API.
- A layer-local API should stay outside the enum contract.
  Use this when a presentation-only, feature-only, or otherwise non-core helper should not be exposed as part of the enum itself.

If none of these apply, prefer moving the behavior into the enum.

## Scope of this rule

- This is a repo-wide style convention, not a package-local preference.
- This document is the source of truth for the rule.
- `AGENTS.md` should keep only a short summary so the auto-loaded agent context stays compact.
- A future analyzer rule in `tools/alex_workspace_lints` is the preferred way to enforce this automatically. Until then, use this document in reviews and refactors.
