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
- Error handling: never return naked errors; always wrap with `fmt.Errorf` and a short, lowercase
  context prefix in the form `"methodName: operation: %w"` — the method name (lowercase, no
  receiver type) followed by a brief description of what was being attempted
  (e.g. `"load: reading config file: %w"`, `"save: marshaling payload: %w"`). For top-level
  package functions with no receiver, omit the method segment and use the operation alone
  (e.g. `"parsing config: %w"`)
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

### Go doc comments
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

## Linear / Ticket Workflow
- Always use the **`linear-create`** skill when creating a new Linear ticket — it is a blocking
  requirement; invoke it before any other action
- Always use the **`linear-work`** skill when starting work on an existing ticket
- Always use the **`linear-close`** skill when closing or shipping a ticket
- Always use the **`linear-update`** skill when writing results or progress back to a ticket

## Workflow Preferences
- Show diffs and targeted changes rather than rewriting whole files
- Concise by default — skip preamble and get to the point
- Explain reasoning and trade-offs when explicitly asked, or when a decision is non-obvious
- Flag potential issues without being overly cautious
- Work/personal context is split — don't assume work config applies to personal projects

## Analysis Workflow

When presenting findings from a code review, audit, or any multi-item analysis:

- Group findings into categories for clarity, but **number items globally** across all categories
  (e.g., 1–12 across three categories, not 1–4 per category) so any item can be referenced by
  number alone
- Use styled/formatted list presentation (bold titles, indented detail) — it makes findings
  easier to scan
- The user will address items non-sequentially, jumping to whatever is most actionable first;
  the global numbers are the shorthand reference for discussion

After each round of addressing items:
- **Reprint the full list** with resolved items visually marked (e.g., ~~strikethrough~~ or `✓`)
  and remaining items unchanged — do not remove resolved items from the list
- This keeps the current state of the analysis visible without requiring the user to scroll back
  through history or mentally track what has been done
- Wait for the user to manually commit changes between rounds; do not batch unrelated fixes
  together or suggest squashing separate logical changes into one commit

## Git Practices
- Linear history is preferred: fast-forward only merges, autosquash rebases
- Use `--force-with-lease` over `--force`
- Commits are GPG signed

## Environment & Workspace

- Go workspace root: `~/go/src/github.com/` — repos are organized by org under this path
- Work repos live under `~/go/src/github.com/interxfi/` — this is the primary work org (fintech
  platform: payments, orders, portfolio, trade reporting, regulatory filings, exchange/market
  simulation, document generation, and supporting infrastructure)
- Personal Go orgs: `dan9186`, `gomicro`, `hemlocklabs`
- Work-specific environment is loaded from `~/.work_zprofile` (not committed to dotfiles)
- Dotfiles repo lives at `~/dotfiles` — use the **`dotfiles`** skill for any changes there
- Primary OS is macOS

## Shell Environment

The following shell tools are pre-approved via `~/.zprofile` — no runtime permission prompt
is needed for these:

| Category | Approved commands |
|---|---|
| Read / search | `go:*`, `rg:*`, `grep:*`, `cat:*`, `ls:*`, `find:*`, `head:*`, `tail:*`, `wc:*`, `sort:*`, `uniq:*`, `cut:*`, `jq:*` |
| Git | `git:log:*`, `git:diff:*`, `git:status:*`, `git:show:*`, `git:blame:*` |
| GitHub CLI | `gh:pr:view:*`, `gh:pr:list:*`, `gh:pr:checks:*`, `gh:issue:view:*`, `gh:issue:list:*`, `gh:repo:view:*`, `gh:run:view:*`, `gh:run:list:*` |

Any shell command outside this list will require explicit approval at runtime.
