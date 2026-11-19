---
name: go-fix-fleet
description: 'Runs `go fix ./...` across every Go repo in the current org directory. Leaves changes unstaged unless the user explicitly authorizes commit + push + PR and approves the complete batch plan. Produces a summary table of results. Use when asked to "run go fix across the org", "run go fix for my org", "run go fix for the org", "fix all repos", "go fix everything", "apply go fix to all services", "run go fix in bulk", "I want to run go fix", "I''d like to run go fix", "let''s run go fix", or any phrasing combining "go fix" with org-level scope. Skips repos where nothing changed — no branch, no commit, no PR.'
---

# Go Fix Fleet

Run `go fix ./...` across every Go repo in a multi-repo org directory and produce a final table of
results. Leave changes unstaged unless publishing is explicitly authorized for the approved batch.

<TriggerPhrases>
- User asks to "run go fix across the org" or "run go fix for my org"
- User says "fix all repos", "go fix everything", or "apply go fix to all services"
- User says "I'd like to run go fix", "I want to run go fix", or "let's run go fix"
- Any request to apply `go fix ./...` across a multi-repo root
</TriggerPhrases>

<Constraints>
- **Publishing is opt-in per batch** — follow the global `<GitPractices>` rule. The user must
  explicitly request commit + push + PR in this invocation or select it during the interview,
  then approve the complete batch plan. Skill invocation, action-only approval, and earlier runs
  are not publishing authorization. Otherwise use apply-only and leave changes unstaged.
- **Mechanical scope only** — authorization covers only the approved repos, `go fix ./...`,
  preparation and publishing steps, and scoped sub-agents in this batch. It does not cover feature
  development, unrelated fixes, later batches, merging, or force-pushing.
- **Stop the affected repo on failure** — including checkout/update, fixer, signing, push, or
  PR creation failure. Report the actual state without continuing or improvising fixes.
- **Preserve signing and runtime permissions** — never bypass signing or permission checks.
- **Skip cleanly** — if `go fix` produces no diff in a repo, do not create a branch, commit, or PR. Record it as "no changes" in the report.
- **Fixed PR title** — `chore: go fix ./...`, identical across every repo in the batch.
- **Same publishing branch everywhere** — use one branch name in every publishing repo. If it
  already exists locally or remotely, report an error rather than reusing it or force-pushing.
- **No build/test/lint** — this is a fix pass only. Do not run `go build`, `go test`, or any linter.
- **Does not format** — `go fix` rewrites deprecated API usages but does not run `go fmt`. If formatting is also desired, run the `go-fmt-fleet` skill separately.
- **Cheap and autonomous** — sub-agents use the smallest fast model (Copilot: `gpt-5.4-mini` at effort `low`; Claude: `haiku`), run in background mode, and are capped at 10 concurrent. No redundant policy approval is needed; runtime permissions still apply. This is a scripted mechanical task; do not use a heavier model or effort level.
</Constraints>

<Workflow>
<Step0>
**Resolve Repo List**

1. Confirm the cwd is a multi-repo root: it should contain multiple subdirectories each with a `.git` directory. If it does not, stop and tell the user.
2. Enumerate all git-repo subdirectories and filter to only those containing Go files:
   ```sh
   for d in */; do
     [ -d "$d/.git" ] || continue
     find "$d" -name '*.go' -not -path '*/vendor/*' -print -quit 2>/dev/null | grep -q . && echo "$d"
   done
   ```
   Repos with no `.go` files outside `vendor/` are not Go projects and this skill does not apply to them.
3. Present the resolved list (names + count) to the user before proceeding. If it looks wrong, stop and clarify.
4. Also present every excluded git repo with its dominant file extensions and a concise reason for
   exclusion:
   ```
   | Repo | Why excluded (dominant files) |
   |------|--------------------------------|
   | ui | json/ts/md — TypeScript frontend |
   ```
   Derive the dominant extensions from files outside `.git`, and describe the repository type from
   those extensions and its recognizable project files. This gives the user visibility into the
   repositories omitted from the batch before approval.
5. Present one complete approval report before making changes:
   - Go repos included in the batch
   - Git repos excluded from the batch, with reasons
   - Execution mode, exact per-repo operations including default-branch preparation, and the
     explicit no-build/test/lint/formatting policy
   - Shared branch name and exact commit/PR messages if publishing
   - Confirmation that dirty repos and repos with an existing branch will be skipped

   Do not start any repository mutations until the user approves this complete batch plan.
   Resolve the mode in Step1 before presenting it. Material scope changes require renewed approval.
</Step0>

<Step1>
**Determine Execution Mode and Branch Name**

- Use an explicit commit + push + PR request from this invocation; otherwise ask via the ask-user
  tool whether to publish or apply-only, defaulting to apply-only. Without an explicit publishing
  choice, use apply-only: no staging, commit, push, or PR. Never inherit a prior choice.
- Only publishing requires a shared branch and commit/PR messages; apply-only skips those steps.
- When publishing, use the user's branch name or default to `go-fix`. Announce it in the batch
  plan. The same branch name is used in every publishing repo.
</Step1>

<Step2>
**Fan Out Autonomously**

After the user approves the complete batch plan, execute the fleet autonomously (Copilot: autopilot;
Claude: background sub-agents).
Approval authorizes only the listed per-repo operations in the selected mode. Publishing additionally
requires the explicit choice in Step1. Do not request redundant policy approval for those operations,
but preserve runtime permission checks; approval does not disable permission prompts.

Do not require broader shell permissions or a permission-mode change to run this skill.
Launch one autonomous sub-agent per repo, capped at
**10 concurrent**. Continue
launching successive batches until every approved repository has completed or been skipped.
Sub-agents run in **background mode** with the smallest fast model (Copilot: `gpt-5.4-mini` at
reasoning effort `low`; Claude: `haiku`) — this is a mechanical shell task requiring no reasoning
depth.

Agents must still obey all safety boundaries:
- Stop immediately on a dirty working tree.
- Never stash or alter pre-existing work.
- Never reuse, delete, or force-push an existing branch.
- Report command failures without improvising around them.
- Stop if unrelated work appears during execution; never stage or publish it.
- In apply-only mode, leave all generated changes unstaged; no commit, push, or PR.
- Publishing approval never authorizes merges, force-pushes, later batches, or signing bypasses.
- Do not run builds, tests, linters, or formatting.

Each sub-agent receives:

- Absolute repo path
- Approved operation, preparation steps, execution mode, and stop conditions
- Explicit publishing choice and approved batch-plan scope, or an explicit prohibition on staging,
  committing, pushing, and PR creation. Authority is limited to this repo's generated changes
- If publishing: branch name, commit message and PR title `chore: go fix ./...`,
  PR body `Automated fix pass via \`go fix ./...\`.`

**Per-repo sub-agent steps:**

1. `cd` into the repo directory.
2. Check whether the working tree is dirty:
   ```sh
   git status --porcelain
   ```
   - If output is non-empty: report **"dirty"** and stop. Do not stash, checkout, run the tool, or open a PR.
   - If output is empty: continue.
   - If publishing, check for the shared branch locally and on the remote before mutations.
     If either exists, report **"branch exists"** and stop. Never reuse or overwrite it.
3. Determine the default branch:
   ```sh
   git remote show origin | grep 'HEAD branch' | awk '{print $NF}'
   ```
4. Checkout and pull the latest default branch:
   ```sh
   git checkout <default-branch>
   git pull --ff-only origin <default-branch>
   ```
   Before publishing, verify the local default-branch HEAD matches `origin/<default-branch>`.
   If it contains unpublished local commits, stop and report rather than including them or resetting.
5. Run the fixer:
   ```sh
   go fix ./...
   ```
6. Check whether anything changed:
   ```sh
   git status --porcelain
   ```
   - Empty output: report **"no changes"** and stop. No branch, commit, push, or PR.
   - Otherwise inspect tracked and untracked changes to confirm they belong to the approved action.
   - In apply-only mode: report **"applied-unstaged"** and stop. Do not stage or publish.
7. Create a branch from the current default branch HEAD:
   ```sh
   git switch -c <branch>
   ```
8. Stage and commit:
   ```sh
   git add -- <approved-generated-paths>
   git diff --cached
   git commit -S -m "chore: go fix ./..."
   ```
   Inspect the staged diff before committing; stop if it includes unrelated changes.
9. Push:
   ```sh
   git push -u origin <branch>
   ```
10. Open the PR:
    ```sh
    gh pr create \
      --title "chore: go fix ./..." \
      --body "Automated fix pass via \`go fix ./...\`." \
      --base <default-branch> \
      --head <branch>
    ```
11. Report back: repo name, outcome (`pr-opened`, `applied-unstaged`, `no-changes`, `dirty`, or
    error), actual git state, and PR URL if applicable. Run steps sequentially and stop on the first
    failed operation. If publishing fails midway, report whether changes were staged, committed,
    or pushed; do not continue to subsequent steps.
</Step2>

<Step3>
**Aggregate and Report**

After all sub-agents complete, print a markdown table of PRs opened, apply-only changes left
unstaged, dirty skips, and errors (including partial publishing states). Omit no-change repos.

```
| Repo | Status | PR |
|------|--------|----|
| payments | ✅ pr-opened | https://github.com/org/payments/pull/42 |
| registration | ✅ pr-opened | https://github.com/org/registration/pull/17 |
| billing | ⚠️ dirty | — |
```

- `pr-opened` — fixes were applied; PR created.
- `applied-unstaged` — fixes were applied and left unstaged; publishing was not authorized.
- `dirty` — repo had uncommitted changes; skipped. Needs manual resolution before re-running.
- Errors (e.g. branch already existed on remote) show the error reason in the Status column.

If every repo reports no changes, print: "All repos already fixed — nothing to do."

Include summary counts for PRs opened, apply-only changes, dirty skips, errors, and no-change repos.
The summary always includes the no-changes count for visibility even though those repos are excluded from the table.

If any repos were dirty, list their names explicitly after the table so they can be passed as targeted input to a subsequent skill invocation.
</Step3>
</Workflow>

<UpdateProtocol>
If at any point the user proposes a new convention or behavioral change for this skill:

1. Acknowledge the suggestion.
2. Show exactly what the change would look like in this `SKILL.md`.
3. Wait for explicit confirmation before modifying the file.
4. After confirmation, update `~/dotfiles/agents/skills/golang/go-fix-fleet/SKILL.md`.
5. Tell the user to commit the change to `~/dotfiles` and run `skills-sync` to persist it.
</UpdateProtocol>

<OutputContract>
- Final output is the three-column table (`Repo | Status | PR`) containing `pr-opened`,
  `applied-unstaged`, `dirty`, and error rows, followed by summary counts and dirty-repo names (if any).
- Repos with no changes are excluded from the table entirely; they are counted only in the summary line.
- Do not emit per-repo progress logs in the final response — aggregate only.
- Errors (e.g. push failed, branch exists) appear in the Status column of the table, not inline during execution.
</OutputContract>
