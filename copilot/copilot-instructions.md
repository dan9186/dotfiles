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
- Tests: use the standard Go test runner; alternate assertion libraries are acceptable
- Tests should be easy to read and have independent setup — avoid relying on production code
  internals in test setup to prevent self-fulfilling test results
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
