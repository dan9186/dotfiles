---
name: go-fix-fleet
description: 'Runs `go fix ./...` across every Go repo in the current org directory, creates a branch and PR for each repo where fixes were applied, and produces a summary table with repo names and PR links. Use when asked to "run go fix across the org", "run go fix for my org", "run go fix for the org", "fix all repos", "go fix everything", "apply go fix to all services", "run go fix in bulk", "I want to run go fix", "I''d like to run go fix", "let''s run go fix", or any phrasing combining "go fix" with org-level scope. Skips repos where nothing changed — no branch, no commit, no PR.'
---

# Go Fix Fleet

Run `go fix ./...` across every Go repo in a multi-repo org directory, open a PR for each repo
where changes were applied, and produce a final table of results.

<TriggerPhrases>
- User asks to "run go fix across the org" or "run go fix for my org"
- User says "fix all repos", "go fix everything", or "apply go fix to all services"
- User says "I'd like to run go fix", "I want to run go fix", or "let's run go fix"
- Any request to apply `go fix ./...` across a multi-repo root
</TriggerPhrases>

<Constraints>
- **Always goes to PR** — there is no stage-only mode for this skill.
- **Skip cleanly** — if `go fix` produces no diff in a repo, do not create a branch, commit, or PR. Record it as "no changes" in the report.
- **Fixed PR title** — `chore: go fix ./...`, identical across every repo in the batch.
- **Same branch everywhere** — one branch name is used in every repo. If the branch already exists on the remote, report an error for that repo rather than force-pushing.
- **No build/test/lint** — this is a fix pass only. Do not run `go build`, `go test`, or any linter.
- **Does not format** — `go fix` rewrites deprecated API usages but does not run `go fmt`. If formatting is also desired, run the `go-fmt-fleet` skill separately.
- **Cheap and autonomous** — sub-agents use model `gpt-5.4-mini` at effort `low`, run in background mode (no per-step approval), and are capped at 10 concurrent. This is a scripted mechanical task; do not use a heavier model or effort level.
</Constraints>

<Workflow>
<Step0>
**Resolve Repo List**

1. Confirm the cwd is a multi-repo root: it should contain multiple subdirectories each with a `.git` directory. If it does not, stop and tell the user.
2. Enumerate all git-repo subdirectories and filter to only those containing Go files:
   ```sh
   for d in */; do
     [ -d "$d/.git" ] || continue
     find "$d" -name '*.go' -not -path '*/vendor/*' -quit 2>/dev/null | grep -q . && echo "$d"
   done
   ```
   Repos with no `.go` files outside `vendor/` are silently omitted — they are not Go projects and this skill does not apply to them.
3. Present the resolved list (names + count) to the user before proceeding. If it looks wrong, stop and clarify.
</Step0>

<Step1>
**Determine Branch Name**

- If the user explicitly specified a branch name at invocation, use it.
- Otherwise use `go-fix` as the default. Announce the branch being used (e.g. "Using branch `go-fix` — specify a different name if needed.").
- The same branch name is used in every repo in this batch.
</Step1>

<Step2>
**Fan Out via Parallel Sub-Agents**

Launch one `task` sub-agent per repo, capped at **10 concurrent**. Sub-agents run in
**background mode** (autonomous, no per-step approval required) with **model `gpt-5.4-mini`**
and **reasoning effort `low`** — this is a mechanical shell task requiring no reasoning depth.

Each sub-agent receives:

- Absolute repo path
- Branch name to use
- PR title: `chore: go fix ./...`
- PR body: `Automated fix pass via \`go fix ./...\`.`

**Per-repo sub-agent steps:**

1. `cd` into the repo directory.
2. Check whether the working tree is dirty:
   ```sh
   git status --porcelain
   ```
   - If output is non-empty: report **"dirty"** and stop. Do not stash, checkout, run the tool, or open a PR.
   - If output is empty: continue.
3. Determine the default branch:
   ```sh
   git remote show origin | grep 'HEAD branch' | awk '{print $NF}'
   ```
4. Checkout and pull the latest default branch:
   ```sh
   git checkout <default-branch>
   git pull origin <default-branch>
   ```
5. Run the fixer:
   ```sh
   go fix ./...
   ```
6. Check whether anything changed:
   ```sh
   git diff --exit-code --quiet
   ```
   - Exit code 0 (no diff): report **"no changes"** and stop. Do not continue.
   - Non-zero (diff exists): continue to the next step.
7. Create a branch from the current default branch HEAD:
   ```sh
   git switch -c <branch>
   ```
8. Stage and commit:
   ```sh
   git add -A
   git commit -m "chore: go fix ./..."
   ```
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
11. Report back: repo name, outcome (`pr-opened`, `no-changes`, or `dirty`), and PR URL if applicable.
</Step2>

<Step3>
**Aggregate and Report**

After all sub-agents complete, print a markdown table containing **only repos that need attention** — those with a PR opened or a dirty skip. Repos with no changes are omitted entirely.

```
| Repo | Status | PR |
|------|--------|----|
| payments | ✅ pr-opened | https://github.com/org/payments/pull/42 |
| registration | ✅ pr-opened | https://github.com/org/registration/pull/17 |
| billing | ⚠️ dirty | — |
```

- `pr-opened` — fixes were applied; PR created.
- `dirty` — repo had uncommitted changes; skipped. Needs manual resolution before re-running.
- Errors (e.g. branch already existed on remote) show the error reason in the Status column.

If the table is empty (no PRs opened, no dirty repos), print: "All repos already fixed — nothing to do."

Include a summary line: "Opened N PR(s) across M repo(s) — K were skipped (dirty), R had no changes."
The summary always includes the no-changes count for visibility even though those repos are excluded from the table.

If any repos were dirty, list their names explicitly after the table so they can be passed as targeted input to a subsequent skill invocation.
</Step3>
</Workflow>

<UpdateProtocol>
If at any point the user proposes a new convention or behavioral change for this skill:

1. Acknowledge the suggestion.
2. Show exactly what the change would look like in this `SKILL.md`.
3. Wait for explicit confirmation before modifying the file.
4. After confirmation, update `~/dotfiles/copilot/skills/go-fix-fleet/SKILL.md`.
5. Tell the user to commit the change to `~/dotfiles` and run `skills-sync` to persist it.
</UpdateProtocol>

<OutputContract>
- Final output is the three-column table (`Repo | Status | PR`) containing only `pr-opened` and `dirty` rows, followed by the summary line and dirty-repo list (if any).
- Repos with no changes are excluded from the table entirely; they are counted only in the summary line.
- Do not emit per-repo progress logs in the final response — aggregate only.
- Errors (e.g. push failed, branch exists) appear in the Status column of the table, not inline during execution.
</OutputContract>

