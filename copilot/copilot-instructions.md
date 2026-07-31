---
instructionType: "global"
lastReviewed: "2026-07-23"
---

<Purpose>
Define global behavior, workflow, and quality expectations for Copilot sessions across personal and work repositories.
</Purpose>

<Scope>
- Applies to all Copilot interactions unless a more specific repository or language instruction overrides it.
- Treat these as default hard rules for execution behavior and decision-making.
</Scope>

<StructureContract>
- Section headers are stable and intentionally ordered.
- Rules should be explicit and imperative.
- When adding new rules, place them in the most specific section and avoid duplicates.
</StructureContract>

<PreferredLanguages>
- Go is the primary language — used for microservices, CLIs, and libraries
- Rust, TypeScript/Node (pnpm), Python, Ruby, and Java are present but secondary
- Infrastructure targets AWS and GCP; containerized workloads via Docker
</PreferredLanguages>

<CodingStyle>
<General>
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
- **Scripts and executable tasks must be idempotent**: running them multiple times must produce the
  same result as running them once. For SQL, use `INSERT ... ON CONFLICT DO NOTHING`, `ON CONFLICT
  DO UPDATE`, or `IF NOT EXISTS` guards. For shell scripts, check before acting (e.g., `if ! grep
  -q ... ; then ...`). For infrastructure changes, prefer declarative tooling over imperative
  commands. When true idempotency is not achievable, document clearly why and what the operator
  must do before re-running.
</General>

<Go>
Go-specific standards are in `~/dotfiles/copilot/.github/instructions/go.instructions.md` and are
automatically injected when working on `.go` files via `COPILOT_CUSTOM_INSTRUCTIONS_DIRS`.
</Go>

<SQL>
SQL-specific standards are in `~/dotfiles/copilot/.github/instructions/sql.instructions.md` and
are automatically injected when working on `.sql` files via `COPILOT_CUSTOM_INSTRUCTIONS_DIRS`.
</SQL>
</CodingStyle>

<Documentation>
- Do not duplicate information that already exists authoritatively elsewhere — link or reference it instead
- In particular: never reproduce CLI usage, flags, or command descriptions in a README or doc file;
  that content lives in the tool's `--help` output and the two will inevitably drift
- Apply this broadly: if a config file, schema, or API is the source of truth, docs should point to
  it rather than re-describe it

<GoDocComments>
Go doc comment standards are in `~/dotfiles/copilot/.github/instructions/go.instructions.md`.
</GoDocComments>
</Documentation>

<LinearWorkflow>
- Always use the **`linear-create`** skill when creating a new Linear ticket — it is a blocking
  requirement; invoke it before any other action
- Always use the **`linear-work`** skill when starting work on an existing ticket
- Always use the **`linear-close`** skill when closing or shipping a ticket
- Always use the **`linear-update`** skill when writing results or progress back to a ticket
</LinearWorkflow>

<ModelStrategy>
Copilot runs in **auto model mode**. Default preference: **Claude Haiku 4.5** — fast, lightweight
reasoning ideal for planning, exploration, architecture decisions, and discovery work.

For explicit model selection during a session:
- Use `/model` command to switch models interactively
- Specify model preference directly in your prompt (e.g., "use Claude Sonnet" or "use GPT-5.4")

Available models: `gpt-5.4`, `gpt-5.4-mini`, `gpt-5-mini`, `claude-sonnet-4.6`, `claude-sonnet-4.5`,
`claude-haiku-4.5`, `gemini-3.1-pro-preview`, `gemini-3.5-flash`.
</ModelStrategy>

<WorkflowPreferences>
- Show diffs and targeted changes rather than rewriting whole files
- Concise by default — skip preamble and get to the point
- Explain reasoning and trade-offs when explicitly asked, or when a decision is non-obvious
- Flag potential issues without being overly cautious
- Work/personal context is split — don't assume work config applies to personal projects
- **Model & Effort Choices**: When a plan has been reviewed, use the specified model and effort level to guide implementation. Low effort means streamlined work with reasonable defaults; medium is balanced investigation and validation; high means thorough exploration, multiple approaches considered, and exhaustive verification. Model choice affects reasoning depth (Haiku for quick tactical work, Sonnet for architectural decisions, GPT-5.4 for complex code analysis).
</WorkflowPreferences>

<QuestionAskingProtocol>
Always ask clarifying questions to reduce ambiguity and avoid rework. The goal is to surface assumptions early and align on approach *before* implementing.

<WhenPlanning>
**Always ask about:**
- **Scope & Boundaries**: What's explicitly in scope? What's out of scope? Are there edge cases to consider?
- **Feasibility & Constraints**: Are there known blockers, dependencies, or external limitations?
- **Success Criteria**: How will we know when this is done? What does success look like?
- **Model & Effort**: Before proposing a plan, ask what model you should use (Haiku for speed, Sonnet for deeper reasoning, GPT-5.4 for code complexity) and what effort level is expected (low = quick answer, medium = balanced depth, high = exhaustive exploration).
- **Codebases Involved**: For architectural changes, confirm which codebases are involved. Start with context (inferred from cwd, recent work, or dependencies) and ask which codebases need **research** (understand patterns, check impact) and which will receive **edits** (implementation targets). After user confirms scope, proactively discover and propose additional codebases that may be affected, with reasoning for each.

**Avoid asking about:**
- Implementation details that are obviously clear from context
- Decisions already well-established in similar work
- Micro-decisions that don't significantly impact the approach
</WhenPlanning>

<WhenImplementing>
**Ask questions when:**
- **Multiple valid approaches exist** (e.g., sync vs. async, centralized vs. distributed state) and the trade-offs aren't obvious from existing patterns
- **Behavioral edge cases are unclear** (e.g., error handling strategy, retry limits, default values, timeouts)
- **Architectural decisions could block future work** (e.g., database schema, API design, service boundaries)
- **Trade-offs have non-obvious consequences** (e.g., performance vs. maintainability, simplicity vs. flexibility)
- **The request seems incomplete or contradicts existing patterns** without clear reason

**Do NOT ask about:**
- Obvious implementation details (variable names, internal structure, refactoring scope)
- Decisions already made in similar code or documented patterns in the codebase
- Style/formatting questions (follow existing patterns)
- Optimization questions when there's no evidence of a performance problem
</WhenImplementing>

<PreferredFormat>
Use `ask_user` tool (never plain text) with:
- Clear, specific question (not bundles of 3+ questions together)
- Concrete choices when available (avoid open-ended questions when options are predictable)
- One question per tool call
- Include rationale if the question's context isn't obvious
</PreferredFormat>

<JudgmentCallExamples>
| Situation | Action |
|---|---|
| "Build an API endpoint" (ambiguous schema/behavior) | Ask scope, structure, and error handling |
| "Add caching" (multiple strategies) | Ask which layer (response/application/data) and strategy (TTL/LRU/invalidation) |
| "Fix bug in authentication" (clear problem, clear fix) | Don't ask; implement, then verify |
| "Refactor this module" (undefined scope) | Ask boundaries, affected systems, and backwards compatibility requirements |
| "Add database index" (clear performance issue identified) | Don't ask; implement with reasoning in commit message |
</JudgmentCallExamples>
</QuestionAskingProtocol>

<AnalysisWorkflow>
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
</AnalysisWorkflow>

<GitPractices>
- **Never run `git commit` or `git add`** — always stop after making file changes, letting the
  user stage and commit. This keeps the user in control of what gets staged and reviewed.
- Linear history is preferred: fast-forward only merges, autosquash rebases
- Use `--force-with-lease` over `--force`
- Commits are GPG signed
</GitPractices>

<TaskCompletion>
- **For code changes:** The task is complete when changes are made, staged, and tested. Do not commit.
  The user reviews the staged changes and commits as part of their workflow, acting as a confirming
  pair on the work.
- **For other work** (config, dependencies, infrastructure): The task is complete when changes are
  applied and tested to verify they work.
- In both cases, verification (tests passing, linting clean, etc.) is required before reporting completion.
</TaskCompletion>

<Environment>
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
- **Filesystem searches (find, grep, glob) must be scoped to `$GOPATH/src` (or a more specific
  subdirectory within it) — never the filesystem root or home directory.** Use `$GOPATH` to locate
  the workspace root rather than hardcoding `~/go`.
</Environment>

<ShellEnvironment>
The following shell tools are pre-approved via `~/.zprofile` — no runtime permission prompt
is needed for these:

| Category | Approved commands |
|---|---|
| Read / search | `go:*`, `rg:*`, `grep:*`, `cat:*`, `ls:*`, `find:*`, `head:*`, `tail:*`, `wc:*`, `sort:*`, `uniq:*`, `cut:*`, `jq:*` |
| Git | `git:log:*`, `git:diff:*`, `git:status:*`, `git:show:*`, `git:blame:*` |
| GitHub CLI | `gh:pr:view:*`, `gh:pr:list:*`, `gh:pr:checks:*`, `gh:issue:view:*`, `gh:issue:list:*`, `gh:repo:view:*`, `gh:run:view:*`, `gh:run:list:*` |

Any shell command outside this list will require explicit approval at runtime.
</ShellEnvironment>

<UpdateProtocol>
If a new global convention is proposed during work, do not silently absorb it. Show the exact text
to add, classify it as a hard rule or guideline, wait for explicit confirmation, then update this
file and remind the user to commit from `~/dotfiles`.
</UpdateProtocol>
