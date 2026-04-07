# Adding a rule

This package follows the analyzer plugin guidance from `analysis_server_plugin`:

- rule class: `AnalysisRule` with a zero-argument constructor
- visitor class: private `SimpleAstVisitor<void>`
- diagnostic code: `static const LintCode`
- registration: explicit `registry.registerLintRule(...)`
- tests: `AnalysisRuleTest` with reflective tests

## Checklist

1. Create a new file under `lib/src/rules/<category>/<rule_name>_rule.dart`.
2. Declare:
   - `static const LintCode code`
   - zero-argument constructor with `name` and `description`
   - `LintCode get diagnosticCode => code`
   - `registerNodeProcessors(...)`
3. Add a private visitor class in the same file.
4. Register the rule in the appropriate `lib/src/rules/register_*.dart` file.
5. Add a test in `test/rules/...`.
6. If the rule relies on resolved elements or types, add at least one test that exercises resolution.
7. Keep the rule disabled in the root `analysis_options.yaml` until rollout is approved.

## Conventions

- One production rule per file.
- Keep helper logic in `lib/src/shared/` only when reused by multiple rules.
- Prefer `AnalysisRule`; use `MultiAnalysisRule` only when one AST pass intentionally reports multiple diagnostic codes.
- Do not add dynamic registration or code generation for rule discovery.
- Reserve `lib/src/fixes/` and `lib/src/assists/` for future work; do not mix them with rule logic.
