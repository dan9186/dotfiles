# Copilot Global Instructions

## Preferred Languages & Frameworks
- Go is the primary language — used for microservices, CLIs, and libraries
- Rust, TypeScript/Node (pnpm), Python, Ruby, and Java are present but secondary
- Infrastructure targets AWS and GCP; containerized workloads via Docker

## Coding Style

### General
- Prefer targeted, surgical changes over full file rewrites
- Ask before introducing new external dependencies; stdlib and already-present deps are fine
- Strongly prefer **simple over easy**: favor explicit, readable code over convenience abstractions
  that hide what's happening — even when that means more lines of code
- Avoid nesting control structures (nested `if`, nested loops) unless the logic requires it; prefer
  early returns and guard clauses to keep the happy path at the outermost level
- Avoid inversion of control (callbacks, higher-order functions passed as arguments) unless the
  explicit goal of the functionality being built demands it
- Do not reduce to clever one-liners or chain functions as the return value of another function;
  prefer intermediate variables with clear names so the logic can be followed line by line
- All of the above share the same goal: minimize the mental load required to read and understand a
  block of code

### Go
- Error handling: never return naked errors; always prefix with short, lowercase context
  mirroring native Go package style (e.g. `"parsing config: %w"`)
- Use sentinel errors when reuse across call sites is beneficial; wrap with `%w` to preserve
  comparability and add context
- Assign errors on a separate line from the `err != nil` check; do not combine into a single
  `if err := ...; err != nil` statement
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
- Organize imports into three groups in this order: (1) Go stdlib, (2) local repo packages
  (i.e. those with the same module prefix as the current repo), (3) external third-party packages.
  Separate each group with a blank line. `go fmt` will sort within groups alphabetically but does
  not manage groupings — apply this structure manually when writing or editing import blocks.
- Never directly edit or inspect the `vendor/` directory; the only permissible way to modify its
  contents is via `go mod vendor`
- When launching agents (explore, general-purpose, code-review, etc.) to inspect Go code, always
  explicitly exclude the `vendor/` directory from the scope of the review
- After making changes to Go code, always run `go fmt`, `go vet`, `go build`, and `go test` in that order
- Tests: use the standard Go test runner; `testify/assert` is the preferred assertion library
- Tests should be easy to read and have independent setup — avoid relying on production code
  internals in test setup to prevent self-fulfilling test results
- Call `t.Parallel()` at the top of each unit test
- Prefer a failing test first to demonstrate the problem before writing the fix
- Minimum coverage of the happy path is the baseline; table-driven tests where they add clarity

## Documentation
- Do not duplicate information that already exists authoritatively elsewhere — link or reference it instead
- In particular: never reproduce CLI usage, flags, or command descriptions in a README or doc file;
  that content lives in the tool's `--help` output and the two will inevitably drift
- Apply this broadly: if a config file, schema, or API is the source of truth, docs should point to
  it rather than re-describe it

## Workflow Preferences
- Show diffs and targeted changes rather than rewriting whole files
- Concise by default — skip preamble and get to the point
- Explain reasoning and trade-offs when explicitly asked, or when a decision is non-obvious
- Flag potential issues without being overly cautious
- Work/personal context is split — don't assume work config applies to personal projects

## Git Practices
- Linear history is preferred: fast-forward only merges, autosquash rebases
- Use `--force-with-lease` over `--force`
- Commits are GPG signed
