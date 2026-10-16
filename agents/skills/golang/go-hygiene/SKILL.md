---
name: go-hygiene
description: 'Audits a Go codebase for missing context.Context-first-argument conventions, log.Fatal/os.Exit calls outside main/init, and unused method receiver names, fixes confirmed violations, and proposes golangci-lint linters (contextcheck, revive) to prevent regressions. Use when asked to "audit context propagation", "check for log.Fatal misuse", "clean up unused receivers", "check Go signature hygiene", or "review Go lifecycle conventions". Groups violations by rule, presents them for confirmation before editing, validates with go fmt/vet/build/test, then proposes linter config.'
---

# Go Hygiene

Audit a single Go repo against three specific `go.instructions.md` rules that span multiple
sections but share a trait: each is mechanically enforceable by a `golangci-lint` linter once
fixed. Fix confirmed violations, then propose the matching linter as a regression guard.

<TriggerPhrases>
- User asks to audit context propagation or check for missing `context.Context` args
- User asks to find `log.Fatal`/`os.Exit` calls outside `main`/`init`
- User asks to clean up unused method receiver names
- User asks to "review Go signature hygiene" or "review Go lifecycle conventions"
</TriggerPhrases>

<Constraints>
- **Single repo, cwd-scoped** — operates on the current repo only. No org-wide fleet mode, no
  branch/PR creation; edits are applied directly like `godoc`/`go-errors`.
- **Exclude `vendor/`** — never inspect or edit anything under `vendor/`.
- **Never hardcode the rules** — read the live rule text from `go.instructions.md` at the start of
  every run rather than copying it here:
  - `<CodeStyle>` — `context.Context` as first argument for I/O/blocking/cancellable functions
  - `<ConcurrencyLifecycle>` — `log.Fatal`/`os.Exit` only from `main.main` or `init`
  - `<NamingStructure>` — omit a method receiver's name if the method body never uses it
- **No blind auto-fix** — audit-then-fix, not a fixer. Findings are always presented for
  confirmation before any file is edited, per the global `<AnalysisWorkflow>` convention.
- **No commits** — apply confirmed edits and leave them staged for the user.
- **Identify → resolve → prevent** — after fixing confirmed violations, propose linter config to
  catch regressions going forward. Only touch `.golangci.yml` if the repo already has one; never
  create it.
</Constraints>

<ResearchPhase>
1. Read `~/dotfiles/copilot/.github/instructions/go.instructions.md` and extract the three rules
   listed in `<Constraints>` fresh — this is the live rule set for this run.
2. Enumerate non-vendor Go files:
   ```bash
   find . -name '*.go' -not -path '*/vendor/*'
   ```
3. For each file, scan for violations of each rule:
   - **Missing context-first-arg**: functions/methods that do I/O, call something blocking, or
     accept a `context.Context` anywhere in their signature but not as the first parameter.
   - **Misplaced log.Fatal/os.Exit**: any call to `log.Fatal`, `log.Fatalf`, `log.Fatalln`, or
     `os.Exit` in a file/function that is not `main.main` or an `init()` function.
   - **Unused receiver names**: methods where the receiver identifier is declared but never
     referenced in the method body.
4. Record every match with file path, line number, and the specific rule violated.
</ResearchPhase>

<Workflow>
<Step1>
**Present Findings**

Follow the global `<AnalysisWorkflow>` convention exactly:
- Group findings into three categories, one per rule above.
- Number findings **globally** across all categories (1–N), so any item can be referenced by
  number alone.
- For each finding, show file:line and a one-line description of the violation.
- Do not edit anything yet. Wait for the user to say which numbers (or categories, or "all") to fix.
</Step1>

<Step2>
**Apply Confirmed Fixes**

- Edit only the findings the user selected:
  - Reorder `context.Context` to be the first parameter, updating all call sites.
  - Replace misplaced `log.Fatal`/`os.Exit` with a returned error (or `t.Fatal`/panic if within
    a test, following `<Testing>`), letting the caller decide how to terminate.
  - Remove the receiver name where unused (e.g. `func (Worker) String() string`).
- If addressing items non-sequentially across multiple rounds, **reprint the full findings list**
  after each round with resolved items marked `✓` (not removed), per the global convention.
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
- If one exists, check whether `contextcheck` and `revive` are enabled, and whether `revive`'s
  config includes the `context-as-argument`, `deep-exit`, and `unused-receiver` rules. These
  linters mechanically catch regressions of the rules just fixed.
- Propose the specific YAML diff to enable any that are missing. Show the exact change and wait
  for confirmation before editing the file — same confirm-before-edit gate as Step2.
- If everything is already enabled, state that and skip silently.
</Step4>
</Workflow>

<UpdateProtocol>
If at any point the user proposes a new convention or a change to how this skill categorizes or
presents findings:

1. Acknowledge the suggestion.
2. If it is a Go language convention, note that it belongs in `go.instructions.md`, not here —
   this skill only audits against that file.
3. If it is a change to this skill's workflow (e.g. presentation format, validation steps, which
   linters to propose), show the exact change to this `SKILL.md` and wait for explicit
   confirmation before editing.
4. After confirmation, update `~/dotfiles/copilot/skills/golang/go-hygiene/SKILL.md`.
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
