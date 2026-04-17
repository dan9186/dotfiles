---
name: linear-associate
description: 'Links existing work to an existing Linear ticket, or reconciles a ticket description against what was actually built. Use when asked to "link this work to a ticket", "associate this branch with a ticket", "update the ticket to match what I built", or "connect this PR to a ticket".'
---

# Linear Associate

Reconcile an existing ticket with existing work — align the ticket description to reality and
attach the branch or PR as a link.

## When to Use This Skill

- Work and a ticket both exist, and the user wants to link or reconcile them
- The ticket description doesn't reflect what was actually built

## Constraints

- Never update a ticket without showing a preview and confirming
- Never change ticket state without confirming the transition

## Steps

1. Use `Linear-list_issues` to search for the ticket if not given a specific ID
2. Read the ticket with `Linear-get_issue`
3. Compare the ticket description against actual work (git log, branch, PR)
4. Identify gaps: description may not reflect what was actually built
5. Propose updates to align the ticket with reality; confirm before applying
6. Add branch or PR URL as a link via `Linear-save_issue` with `links`

## References

- Use `notion-context` skill when a ticket links to or references a Notion document that provides
  spec or context needed for the work
