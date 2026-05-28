---
applyTo: "**/*.go"
---

# Go Coding Standards

## Error Handling

- Never return naked errors; always wrap with `fmt.Errorf` and a short, lowercase context prefix in
  the form `"methodName: operation: %w"` — the method name (lowercase, no receiver type) followed
  by a brief description of what was being attempted
  (e.g. `"load: reading config file: %w"`, `"save: marshaling payload: %w"`). For top-level
  package functions with no receiver, omit the method segment and use the operation alone
  (e.g. `"parsing config: %w"`)
- Error strings must not start with a capital letter — errors are commonly wrapped and a capital
  mid-sentence reads incorrectly (e.g. `"parsing config: %w"` not `"Parsing config: %w"`)
- Use sentinel errors when reuse across call sites is beneficial; wrap with `%w` to preserve
  comparability and add context
- Assign errors on a separate line from the `err != nil` check; do not combine into a single
  `if err := ...; err != nil` statement

## Code Style

- Pass `context.Context` as the first argument to any function that does I/O, blocking work, or
  may need cancellation
- Prefer functional options (`WithXxx(...)`) for constructors that take multiple optional settings
- Avoid goroutines unless there is a clear, demonstrated need; keep things sequential by default
- Avoid `init()` functions unless strictly unavoidable
- Prefer explicit return values over named return values
- Avoid the blank identifier `_` in all cases where it can be avoided:
  - Use `for i := range` instead of `for i, _ := range`
  - Never silently discard an error or return value with `_`; if a value is genuinely unused,
    explain why in a comment or restructure so the value is not produced
  - Avoid `import _ "pkg"` side-effect imports; if an import is needed, use it explicitly
- Use `const` for package-level identifiers whose values never change; reserve `var` for values
  that are mutable or must be addressable at runtime
- Avoid local variable names that shadow imported package names — rename the local variable to
  something that doesn't collide (e.g. `lkp` when a package named `lookup` is in scope)
- Prefer format-variant log calls (e.g. `log.Infof`, `log.Errorf`) over wrapping `fmt.Sprintf`
  inside a non-format log call (e.g. `log.Info(ctx, fmt.Sprintf(...))`)

## Naming & Structure

- Organize imports into three groups in this order: (1) Go stdlib, (2) local repo packages
  (i.e. those with the same module prefix as the current repo), (3) external third-party packages.
  Separate each group with a blank line. `go fmt` will sort within groups alphabetically but does
  not manage groupings — apply this structure manually when writing or editing import blocks.
- Receiver names must be consistent across all methods of a type; use the first letter (or first
  few letters) of the type name, lowercase (e.g. `w` for `Worker`, `tw` for `TickWorker`). Never
  mix receiver names for the same type across methods in the same file or package.

## Spacing Within Function Bodies

- Add a blank line after every log statement before the next action.
- Add a blank line after every `if err != nil` guard block before the next logical step.
- Add a blank line between each `case` block in a `switch` statement.

## Vendor Directory

- Never directly edit or inspect the `vendor/` directory; the only permissible way to modify its
  contents is via `go mod vendor`
- When launching agents (explore, general-purpose, code-review, etc.) to inspect Go code, always
  explicitly exclude the `vendor/` directory from the scope of the review

## Validation

- After making changes to Go code, always run `go fmt`, `go vet`, `go build`, and `go test` in that order

## Testing

- Use the standard Go test runner; `testify/assert` is the preferred assertion library
- Tests should be easy to read and have independent setup — avoid relying on production code
  internals in test setup to prevent self-fulfilling test results
- Call `t.Parallel()` at the top of each unit test
- Prefer a failing test first to demonstrate the problem before writing the fix
- Minimum coverage of the happy path is the baseline; table-driven tests where they add clarity

## Doc Comments

- Every exported symbol must have a doc comment; unexported symbols only if genuinely non-obvious
- Start each comment with the symbol name, as Go convention requires — this is not stutter
- Stutter means redundantly embedding the package or type name in the comment body
  (e.g. in package `color`, `// BlackFg applies black foreground color` is fine;
  `// BlackFg is a color.BlackFg function that...` is stutter)
- Do not be tautological: if the name fully communicates the behavior, omit the comment or say
  something the name cannot — never write `// Printf formats and prints` when `Printf` already says that
- For uniform families of symbols (e.g. 16 color helper functions that all follow the same pattern),
  put the explanation in the package or group doc comment and omit per-symbol comments
- For grouped `var (...)` sentinel errors that share the same shape, use a single group doc comment
  rather than per-line inline comments; individual inline comments inside a `var` block are not
  surfaced by godoc
- Prefer terse, imperative phrasing; a one-line comment is almost always better than two
- Doc comments describe what a type or function *is* or *does* — not where its data comes from
  or how it is wired at a specific call site. Avoid embedding implementation details like env var
  names, config keys, or caller-specific context in comments on types; those details belong at
  the call site, not on the type itself
