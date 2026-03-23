# Copilot Global Instructions

## Preferred Languages & Frameworks
- Go is the primary language — used for microservices, CLIs, and libraries
- Rust, TypeScript/Node (pnpm), Python, Ruby, and Java are present but secondary
- Infrastructure targets AWS and GCP; containerized workloads via Docker

## Coding Style

### General
- Prefer targeted, surgical changes over full file rewrites
- Ask before introducing new external dependencies; stdlib and already-present deps are fine
- Avoid over-engineering — favor simple, readable solutions

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
- Never directly edit or inspect the `vendor/` directory; the only permissible way to modify its
  contents is via `go mod vendor`
- When launching agents (explore, general-purpose, code-review, etc.) to inspect Go code, always
  explicitly exclude the `vendor/` directory from the scope of the review
- Format with `gofmt`/`goimports`; vet with `go vet`
- Tests: use the standard Go test runner; `testify/assert` is the preferred assertion library
- Tests should be easy to read and have independent setup — avoid relying on production code
  internals in test setup to prevent self-fulfilling test results
- Call `t.Parallel()` at the top of each unit test
- Prefer a failing test first to demonstrate the problem before writing the fix
- Minimum coverage of the happy path is the baseline; table-driven tests where they add clarity

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
