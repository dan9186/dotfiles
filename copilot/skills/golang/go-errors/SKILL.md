---
name: go-errors
description: 'Audits a Go codebase against the error-handling standards defined in go.instructions.md, fixes confirmed violations, and proposes golangci-lint linters to prevent regressions. Use when asked to "clean up my errors", "audit error handling", "fix error wrapping", "review Go errors against my standards", "check error conventions", or "bring this repo up to my error standards". Groups violations by rule, presents them for confirmation before editing, validates with go fmt/vet/build/test, then proposes enabling errorlint/wrapcheck/stylecheck in an existing .golangci.yml.'
---

# Go Errors

Audit a single Go repo against the mandatory `<ErrorHandling>` rules in
`~/dotfiles/copilot/.github/instructions/go.instructions.md`, then fix only the violations the
user confirms.

<TriggerPhrases>
- User asks to "clean up errors", "audit error handling", or "fix error wrapping" in a repo
- User wants to "bring this codebase up to my error standards"
- User asks to review or check Go error conventions
</TriggerPhrases>

<Constraints>
- **Single repo, cwd-scoped** — operates on the current repo only. No org-wide fleet mode, no
  branch/PR creation (unlike `go-fix-fleet`); edits are applied directly like `godoc`.
- **Exclude `vendor/`** — never inspect or edit anything under `vendor/`.
- **Never hardcode the rules** — read the `<ErrorHandling>` section of `go.instructions.md` fresh
  at the start of every run. If that file changes, this skill's behavior changes with it
  automatically; do not copy rule text into this file.
- **No blind auto-fix** — this is an audit-then-fix skill, not a fixer. Findings are always
  presented for confirmation before any file is edited, per the global `<AnalysisWorkflow>`
  convention.
- **No commits** — apply confirmed edits and leave them staged for the user.
- **Identify → resolve → prevent** — after fixing confirmed violations, propose linter config to
  catch regressions going forward. Only touch `.golangci.yml` if the repo already has one; never
  create it (a repo with no lint config yet is out of scope for this proposal).
</Constraints>

<ResearchPhase>
1. Read `~/dotfiles/copilot/.github/instructions/go.instructions.md` and extract the current
   `<ErrorHandling>` section — this is the live rule set for this run, not a fixed list.
2. Enumerate non-vendor Go files:
   ```bash
   find . -name '*.go' -not -path '*/vendor/*'
   ```
3. For each file, scan for violations of each rule extracted in step 1. As of the last review,
   these included (confirm against the live file, do not assume this list is exhaustive or
   unchanged):
   - Naked `return err` with no `fmt.Errorf` wrap
   - `fmt.Errorf` missing `%w`, or using `%w` anywhere but the end of the format string
   - Error strings starting with a capital letter
   - Wrapped context that duplicates what the underlying error already states
   - System-boundary code (RPC/IPC handlers, storage layer) wrapping with `%w` instead of `%v`
     or a canonical error type
   - Repeated ad-hoc error text that should be a shared sentinel error
   - `if err := ...; err != nil` combined into one statement instead of two lines
4. Record every match with file path, line number, and the specific rule violated.
</ResearchPhase>

<Workflow>
<Step1>
**Present Findings**

Follow the global `<AnalysisWorkflow>` convention exactly:
- Group findings into categories, one per `<ErrorHandling>` rule violated.
- Number findings **globally** across all categories (1–N), not per category, so any item can be
  referenced by number alone.
- For each finding, show file:line and a one-line description of the violation.
- Do not edit anything yet. Wait for the user to say which numbers (or categories, or "all") to fix.
</Step1>

<Step2>
**Apply Confirmed Fixes**

- Edit only the findings the user selected, following the exact rule text from
  `go.instructions.md` (correct wrap format, lowercase message, `%w` at the end, no duplicated
  context, `%v` at boundaries, sentinel reuse, split-line assignment).
- If addressing items non-sequentially across multiple rounds, **reprint the full findings list**
  after each round with resolved items marked `✓` (not removed), per the global convention. Do not
  batch unrelated fixes into one round unless the user asked for "all".
</Step2>

<Step3>
**Validate**

After applying any fixes, run in order and report pass/fail for each:
```bash
go fmt ./...
go vet ./...
go build ./...
go test ./...
```
This matches the `<Validation>` rule in `go.instructions.md`. If any step fails, report the
failure output and stop — do not proceed to the next validation step or claim completion.
</Step3>

<Step4>
**Prevent**

Check whether the repo has a `.golangci.yml` (or `.yaml`) at its root:
```bash
find . -maxdepth 1 -name '.golangci.y*ml'
```
- If none exists, skip this step entirely — do not create one.
- If one exists, check whether `errorlint`, `wrapcheck`, and `stylecheck` are enabled. These
  linters mechanically catch regressions of the rules just fixed: `errorlint` (unwrapped
  comparisons and improper `%w` use), `wrapcheck` (unwrapped errors from external packages),
  `stylecheck` ST1005 (capitalized/punctuated error strings). Note that `wsl`-style spacing and
  goroutine-lifecycle judgment calls are out of scope for this skill — they belong to
  `go-hygiene` and manual review, respectively.
- Propose the specific YAML diff to enable any that are missing (and, for `stylecheck`, confirm
  `ST1005` isn't excluded). Show the exact change and wait for confirmation before editing the
  file — this follows the same confirm-before-edit gate as Step2.
- If all three are already enabled, state that and skip silently.
</Step4>
</Workflow>

<UpdateProtocol>
If at any point the user proposes a new error-handling convention or a change to how this skill
categorizes or presents findings:

1. Acknowledge the suggestion.
2. If it is a Go language convention, note that it belongs in `go.instructions.md`
   `<ErrorHandling>`, not here — this skill only audits against that file.
3. If it is a change to this skill's workflow (e.g. presentation format, validation steps), show
   the exact change to this `SKILL.md` and wait for explicit confirmation before editing.
4. After confirmation, update `~/dotfiles/copilot/skills/golang/go-errors/SKILL.md`.
5. Tell the user to commit the change to `~/dotfiles` and run `skills-sync` to persist it.
</UpdateProtocol>

<OutputContract>
- Phase 1 output: the numbered, categorized findings table — no edits yet.
- Phase 2 output (after confirmation): a summary of what was fixed, referencing finding numbers,
  followed by the `go fmt`/`go vet`/`go build`/`go test` results.
- Phase 3 output (if `.golangci.yml` exists): the proposed linter-config diff, or a note that
  nothing changed because the linters are already enabled or no config file exists.
- Changes are left staged, uncommitted, for the user to review and commit.
</OutputContract>
