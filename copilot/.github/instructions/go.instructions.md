---
applyTo: "**/*.go"
instructionType: "language"
language: "go"
lastReviewed: "2026-08-26"
---

# Go Coding Standards

<Purpose>
Define mandatory Go conventions for implementation, testing, and docs to keep behavior predictable across repositories.
</Purpose>

<Scope>
- Applies to all `*.go` files matched by `applyTo`.
- These are hard rules unless a repository-specific instruction explicitly overrides them.
</Scope>

<HardRules>
<ErrorHandling>

- Never return naked errors; always wrap with `fmt.Errorf` and a short, lowercase context prefix in
  the form `"methodName: operation: %w"` — the method name (lowercase, no receiver type) followed
  by a brief description of what was being attempted
  (e.g. `"load: reading config file: %w"`, `"save: marshaling payload: %w"`). For top-level
  package functions with no receiver, omit the method segment and use the operation alone
  (e.g. `"parsing config: %w"`). Wrapping this way preserves call-site context so failures can be
  traced back through the call chain during debugging.
- Error strings must not start with a capital letter — errors are commonly wrapped and a capital
  mid-sentence reads incorrectly (e.g. `"parsing config: %w"` not `"Parsing config: %w"`)
- Place `%w` at the end of the error format string (`"context: %w"`) so the error chain reads
  newest-to-oldest. Never place `%w` in the middle or at the start of a message.
- Do not duplicate information the underlying error already provides. If `os.Open` includes the
  filename in its error, do not also say "could not open settings.txt: %w" — just
  "loading config: %w".
- At system boundaries (RPC, IPC, storage layer) use `%v` rather than `%w`, or translate to a
  canonical error type. Wrapping with `%w` at these boundaries leaks internal implementation
  details to callers; breaking the chain is intentional here.
- Use sentinel errors when reuse across call sites is beneficial; wrap with `%w` to preserve
  comparability and add context
- Assign errors on a separate line from the `err != nil` check; do not combine into a single
  `if err := ...; err != nil` statement — a combined statement hides the declaration inside a
  conditional, making it easy to miss during review or when scanning a diff
</ErrorHandling>

<CodeStyle>
- Pass `context.Context` as the first argument to any function that does I/O, blocking work, or
  may need cancellation — this matches stdlib convention and lets callers propagate
  cancellation, deadlines, and tracing through the entire call chain
- Prefer functional options (`WithXxx(...)`) for constructors that take multiple optional settings.
  When a function's argument list grows large (beyond 3–4 non-context args), introduce an option
  struct rather than expanding the parameter list further — adding a new option later doesn't
  require reordering or breaking every existing call site
- Avoid goroutines unless there is a clear, demonstrated need; keep things sequential by default —
  unmanaged concurrency introduces data races and nondeterministic bugs that sequential code
  doesn't have
- Avoid `init()` functions unless strictly unavoidable — they run implicitly at import time in an
  order that's hard to trace, and can't be invoked or tested directly
- Prefer explicit return values over named return values — a named return can be mutated after a
  deferred recover or simply forgotten, silently changing what the function returns
- Avoid the blank identifier `_` in all cases where it can be avoided:
  - Use `for i := range` instead of `for i, _ := range` — the extra `_` is a token with no purpose
  - Never silently discard an error or return value with `_`; if a value is genuinely unused,
    explain why in a comment or restructure so the value is not produced — discarding hides
    failures that should be handled or explained
  - Avoid `import _ "pkg"` side-effect imports; if an import is needed, use it explicitly —
    a side-effect import hides what the package actually provides from the reader
- Use `const` for package-level identifiers whose values never change; reserve `var` for values
  that are mutable or must be addressable at runtime
- Prefer `:=` for variable declarations that initialize to a non-zero value. Use `var` (zero-value
  form) when you want to declare an empty value that will be filled in later — it signals intent.
- Always specify channel direction (`<-chan T`, `chan<- T`) in function signatures where possible.
  Unidirectional channel types prevent misuse and document ownership at a glance.
- Avoid local variable names that shadow imported package names — rename the local variable to
  something that doesn't collide (e.g. `lkp` when a package named `lookup` is in scope). A
  shadowed package name is inaccessible in that scope and easy to misread as the package itself.
- Prefer format-variant log calls (e.g. `log.Infof`, `log.Errorf`) over wrapping `fmt.Sprintf`
  inside a non-format log call (e.g. `log.Info(ctx, fmt.Sprintf(...))`) — wrapping formats the
  string unconditionally even when the log level would suppress the line, wasting the allocation
</CodeStyle>

<NamingStructure>
- Organize imports into three groups in this order: (1) Go stdlib, (2) local repo packages
  (i.e. those with the same module prefix as the current repo), (3) external third-party packages.
  Separate each group with a blank line. `go fmt` will sort within groups alphabetically but does
  not manage groupings — apply this structure manually when writing or editing import blocks.
  Grouping keeps diffs minimal (adding a stdlib import doesn't reorder third-party ones) and makes
  a package's dependency mix visible at a glance.
- Receiver names must be consistent across all methods of a type; use the first letter (or first
  few letters) of the type name, lowercase (e.g. `w` for `Worker`, `tw` for `TickWorker`). Never
  mix receiver names for the same type across methods in the same file or package — mixed names
  read as if two different types are involved.
- Do not repeat the package name, receiver type, or parameter/return type names in a function or
  method name — this is redundant and verbose. E.g. in package `yamlconfig`, name the function
  `Parse`, not `ParseYAMLConfig`. Getters should not have a `Get` prefix.
- Avoid package names like `util`, `helper`, `common`, or `misc` — they are uninformative, cause
  import conflicts, and grow without bound. Name packages for what they actually provide.
- Use the Go project's preferred spelling for words with multiple valid forms: `marshaling`,
  `unmarshaling`, `canceling`, `canceled`, `cancellation` — never the double-`l` British variants
  (`marshalling`, `cancelled`, etc.).
- When lowercasing an exported identifier that starts with a multi-capital-letter acronym or brand
  name to make it unexported, lowercase the entire acronym/brand, not just its first letter:
  `oauthEnabled`, `githubToken` — not `oAuthEnabled`, `gitHubToken`. This matches Go project
  convention; a leading-cap form like `oAuth` reads as a typo rather than an intentional acronym.
- Prefer `s == ""` over `len(s) == 0` for string-emptiness checks — it reads as a string comparison
  at a glance, whereas `len(s) == 0` could be mistaken for a slice length check.
- Omit a method receiver's name entirely if the method body never uses it (e.g. `func (Worker) String() string`
  rather than `func (w Worker) String() string`) — an unused name signals a mistake to the reader.
- When a mutex guards specific struct fields, place it directly above the fields it protects and
  add a comment naming what it guards (the "hat" pattern), e.g.:
  ```go
  type Limiter struct {
      // rateMu protects rateLimits and mostRecent.
      rateMu     sync.Mutex
      rateLimits [categories]Rate
      mostRecent rateLimitCategory
  }
  ```
  Keep unrelated fields separated from this group so the protected set stays visually distinct.
</NamingStructure>

<SpacingWithinFunctionBodies>
- Add a blank line after every log statement before the next action — it visually separates the
  "record what happened" step from what happens next.
- Add a blank line after every `if err != nil` guard block before the next logical step — it marks
  the end of the error-handling branch so the continuing happy path is visually distinct.
- Add a blank line between each `case` block in a `switch` statement — it prevents adjacent cases
  from visually running together.
</SpacingWithinFunctionBodies>

<VendorDirectory>
- Never directly edit or inspect the `vendor/` directory; the only permissible way to modify its
  contents is via `go mod vendor` — hand edits are silently overwritten by the next `go mod
  vendor` run and drift from the real dependency source (`go.mod`/`go.sum`)
- When launching agents (explore, general-purpose, code-review, etc.) to inspect Go code, always
  explicitly exclude the `vendor/` directory from the scope of the review
</VendorDirectory>

<Validation>
- After making changes to Go code, always run `go fmt`, `go vet`, `go build`, and `go test` in that
  order — each step assumes the previous one passed (`vet` assumes valid syntax, `build` assumes
  vet-clean code, `test` assumes it builds), so running out of order wastes time on later steps
  that will fail for reasons the earlier step would have caught
</Validation>

<Testing>
- Use the standard Go test runner; `testify/assert` is the preferred assertion library — it gives
  consistent assertion output and failure messages across the codebase instead of ad-hoc
  `if got != want { t.Errorf(...) }` boilerplate that varies test to test
- Tests should be easy to read and have independent setup — avoid relying on production code
  internals in test setup to prevent self-fulfilling test results
- Call `t.Parallel()` at the top of each unit test — it surfaces shared-state bugs between tests
  and speeds up the overall suite
- Prefer a failing test first to demonstrate the problem before writing the fix — this proves the
  test actually exercises the bug before it's trusted as a regression guard
- Minimum coverage of the happy path is the baseline; table-driven tests where they add clarity —
  a happy-path test guarantees every symbol has at least one check that it works before edge cases
  are considered
- In table-driven tests, always name struct fields when initializing test cases. This improves
  readability and allows zero-value fields to be omitted clearly.
- Test setup helper functions must call `t.Helper()` as their first statement so that failure
  output points to the call site in the test, not the line inside the helper.
- Never call `t.Fatal` (or `t.FailNow`) from a goroutine other than the test's own goroutine —
  it is a runtime panic. Use `t.Error` + `return` inside spawned goroutines instead.
</Testing>

<DocComments>
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
- Use a single space after `//` in comments meant for humans (`// like this`, not `//like this`).
  The no-space form is reserved for compiler directives (e.g. `//go:generate`) and temporarily
  commented-out code that isn't meant to be committed.
- Use a single space between sentences within a comment (`Sentence one. Sentence two.`, not two
  spaces after the period).
</DocComments>

<ConcurrencyLifecycle>
- Never start a goroutine without a clear mechanism for it to stop. Fire-and-forget goroutines
  (`go doSomething()` with no way to signal completion or cancellation) are not acceptable —
  every goroutine needs a stop channel, `context.Context`, or equivalent the caller controls.
- Only call `log.Fatal` (or `os.Exit`) from `main.main` or an `init` function. Calling it from
  library code, request handlers, or any goroutine skips deferred cleanup, prevents other
  goroutines from shutting down cleanly, and makes the calling code untestable.
- A goroutine must report any error it encounters back to whatever started it (e.g. via a
  buffered error channel sized to the number of goroutines), rather than swallowing the error or
  letting it vanish when the goroutine returns.
</ConcurrencyLifecycle>
</HardRules>

<UpdateProtocol>
If the user states a new Go-specific convention, correction, or rule while working, propose adding
it here rather than applying it silently. Show the exact addition, note whether it's a hard rule or
a guideline, and wait for explicit confirmation before editing. After confirmation, edit this file
at `~/dotfiles/copilot/.github/instructions/go.instructions.md` and remind the user to commit and
push from `~/dotfiles`.
</UpdateProtocol>
