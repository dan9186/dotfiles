---
name: linear-create
description: 'Creates Linear tickets — either before work starts (pre-work draft) or retroactively when work already exists (branch/commits/PR) but no ticket does yet. Use when asked to "create a ticket", "write a ticket", "make a Linear issue", "I need a ticket for this", "let''s write this up in Linear", "draft a ticket", "I''m working on something without a ticket", or "backfill a ticket".'
---

# Linear Create

Create a Linear ticket — either before work begins (pre-work draft) or retroactively from an
existing branch, commits, or PR.

## When to Use This Skill

- User wants to create a ticket for work that hasn't started yet
- User has work in flight or at PR stage and needs a ticket created retroactively

## Constraints

- Never create a ticket without showing a preview and confirming
- Auto-assign all created tickets to `me` unless explicitly told otherwise
- When inferring ticket content from git context, always surface your interpretation for
  confirmation before creating — git context tells you *what*, not always *why*

## Phase 0 — Determine Mode

Classify into one of the two sub-modes before proceeding:

| Mode | Signal |
|------|--------|
| **Pre-work draft** | User is describing work that hasn't started yet |
| **Retroactive draft** | Work exists (branch/commits/PR) but no ticket; user mentions working without a ticket, submitting a PR, or wanting to backfill a ticket |

If ambiguous, ask one question to clarify before proceeding.

## Pre-Work Draft Mode

1. Ask the user to describe what needs to be done if they haven't already
2. Infer: title (concise, imperative), description (what + why + context), labels if obvious
3. Ask only for what cannot be inferred — do not run through a form
4. Show a preview of the ticket draft (title, description, assignee = me, team, labels)
5. Confirm, then create via `Linear-save_issue`
6. Share the ticket ID and URL

## Retroactive Draft Mode

Work already exists — inspect git context to infer the ticket:

1. Run `git --no-pager log --oneline -20` and `git --no-pager diff main...HEAD --stat` (or
   `origin/main` if `main` is remote) to understand what changed
2. Check the current branch name for clues (issue numbers, descriptive slugs)
3. If a PR exists, use its title/body as additional input
4. Infer: what was changed, why it was needed, what problem it solves
5. Draft the ticket: title, description (including what was done and why), acceptance criteria
   if determinable, labels
6. Ask targeted questions only for gaps git context cannot fill (motivation, business context,
   acceptance criteria)
7. Show a preview and confirm before creating
8. After creating, offer to add the branch/PR as a link on the ticket

## Ticket State Guidance

When creating a ticket, choose the initial state based on the following logic. Always confirm
the state as part of the preview — do not silently apply a state.

| Situation | Recommended State |
|-----------|------------------|
| Work hasn't started and isn't planned for the current cycle | **Backlog** |
| Work is planned for the current cycle but hasn't started | **Todo** |
| Work is actively being done right now | **In Progress** |
| Work is complete | **Done** |

## References

- Use `notion-context` skill when a ticket links to or references a Notion document that provides
  spec or context needed for the work
