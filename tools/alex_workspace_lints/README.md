# alex_workspace_lints

Internal analyzer plugin for repo-specific diagnostics in the Alex workspace.

## Goals

- Keep custom static analysis in a dedicated tooling package under `tools/`.
- Register rules explicitly, without code generation or runtime discovery.
- Roll out rules as lint diagnostics that stay disabled until enabled from the root `analysis_options.yaml`.

## Structure

```text
lib/
  main.dart
  src/
    plugin.dart
    rules/
      register_example_rules.dart
      examples/
        avoid_await_in_lib_rule.dart
    shared/
    fixes/
    assists/
doc/
  adding_rule.md
test/
  rules/
  src/support/
```

## Integration

The workspace root `analysis_options.yaml` is the only place that enables this plugin:

```yaml
plugins:
  alex_workspace_lints:
    path: tools/alex_workspace_lints
    diagnostics:
      avoid_await_in_lib: false
```

Do not add package-level plugin configuration. Open the repo from the workspace root so every package shares the same plugin setup.

## Rule rollout

1. Add the rule implementation under `lib/src/rules/`.
2. Add tests under `test/`.
3. Register the rule explicitly in a `register_*.dart` file.
4. Keep the rule disabled by default in the root `analysis_options.yaml`.
5. Enable it in a dedicated follow-up change once the rule is validated on the workspace.
