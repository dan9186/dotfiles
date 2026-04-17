---
name: linear-close
description: 'Fully closes out a Linear ticket: merges the current PR, returns to main, and marks the ticket Done. Use when asked to "close the ticket", "mark this done", "finish this ticket", "wrap up this ticket", "I''m done with this ticket", or "ship it".'
---

# Linear Close

Fully close out a Linear ticket — merge the PR, return to main, and mark the ticket Done.

## When to Use This Skill

- User wants to finish or ship a ticket
- User wants to merge the current branch's PR and close the associated ticket

## Constraints

- Never merge a PR without confirming
- Never transition ticket state without confirming
- If any linked PR is open on a branch other than the current one, flag it before proceeding

## Steps

### Step 1 — Identify the ticket

Run `git rev-parse --abbrev-ref HEAD` to get the current branch name. Parse it for a ticket
identifier using the branch naming convention `{team-key}-{number}-slug`
(e.g. `prd-42-add-retry-logic` → `PRD-42`): split on `-`, take the first two segments, uppercase.

- If a ticket ID is successfully parsed, proceed automatically with that ID
- If the branch name does not match the convention, ask the user for the ticket identifier before
  continuing

### Step 2 — Fetch the ticket

Use `Linear-get_issue` with `includeRelations: true` to retrieve the ticket including any linked
PRs or attachments.

### Step 3 — Check all linked PRs

Inspect the ticket's `links` and `attachments` for GitHub PR URLs. For each one, run:

```
gh pr view <url> --json number,state,mergedAt,headRefName
```

Surface a summary of what is merged and what is still open. If any linked PR is open and belongs
to a branch other than the current one, flag it for the user and ask how to proceed before
continuing.

### Step 4 — Merge the current branch's PR

Run `gh pr view --json number,state,mergedAt` on the current branch to find its PR.

- **Already merged**: note it and skip to Step 5
- **Open**: run `gh pr merge --squash --delete-branch` and confirm success
- **No PR found**: warn the user and ask whether to proceed without merging

### Step 5 — Return to main

After the merge (or once confirmed as already merged), run:

```
git checkout main && git pull
```

### Step 6 — Close the ticket

Transition the ticket state to **Done** via `Linear-save_issue` and post a brief closing comment
via `Linear-save_comment` summarizing what was completed. Show both previews and confirm before
applying.
