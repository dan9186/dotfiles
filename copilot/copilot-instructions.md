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
Go-specific standards are in `~/dotfiles/copilot/.github/instructions/go.instructions.md` and are
automatically injected when working on `.go` files via `COPILOT_CUSTOM_INSTRUCTIONS_DIRS`.

### SQL
SQL-specific standards are in `~/dotfiles/copilot/.github/instructions/sql.instructions.md` and
are automatically injected when working on `.sql` files via `COPILOT_CUSTOM_INSTRUCTIONS_DIRS`.

## Documentation
- Do not duplicate information that already exists authoritatively elsewhere — link or reference it instead
- In particular: never reproduce CLI usage, flags, or command descriptions in a README or doc file;
  that content lives in the tool's `--help` output and the two will inevitably drift
- Apply this broadly: if a config file, schema, or API is the source of truth, docs should point to
  it rather than re-describe it

### Go doc comments
Go doc comment standards are in `~/dotfiles/copilot/.github/instructions/go.instructions.md`.

## Linear / Ticket Workflow
- Always use the **`linear-create`** skill when creating a new Linear ticket — it is a blocking
  requirement; invoke it before any other action
- Always use the **`linear-work`** skill when starting work on an existing ticket
- Always use the **`linear-close`** skill when closing or shipping a ticket
- Always use the **`linear-update`** skill when writing results or progress back to a ticket

## Model Strategy

Copilot runs in **auto model mode**. Default preference: **Claude Haiku 4.5** — fast, lightweight
reasoning ideal for planning, exploration, architecture decisions, and discovery work.

For explicit model selection during a session:
- Use `/model` command to switch models interactively
- Specify model preference directly in your prompt (e.g., "use Claude Sonnet" or "use GPT-5.4")

Available models: `gpt-5.4`, `gpt-5.4-mini`, `gpt-5-mini`, `claude-sonnet-4.6`, `claude-sonnet-4.5`,
`claude-haiku-4.5`, `gemini-3.1-pro-preview`, `gemini-3.5-flash`.

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
- **Never run `git commit`** — always stage changes and stop, letting the user commit. This keeps
  the user in incremental review rather than waiting until a PR for oversight.
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
- Work/private dotfiles live at `$PRIVATE_DOTFILES` — use this env var to locate the directory;
  work skills (e.g. `svc-refactor`) are at `$PRIVATE_DOTFILES/copilot/work_skills/`
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
