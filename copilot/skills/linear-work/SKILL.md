---
name: linear-work
description: 'Reads an existing Linear ticket, surfaces what needs to be done, suggests a branch name, and transitions it to In Progress. Use when asked to "read this ticket", "let''s work on LIN-", "what should I call this branch", "name a branch", "start on this ticket", or "what does this ticket say".'
---

# Linear Work

Read a Linear ticket, surface its content, suggest a branch name, and start the work.

## When to Use This Skill

- User references an existing ticket ID or wants to start on a ticket
- User needs a branch name for a ticket
- User wants to understand what a ticket requires before starting

## Constraints

- Never transition ticket state without confirming
- Offer branch name as a suggestion — do not create the branch automatically

## Steps

1. If given a ticket ID, fetch it with `Linear-get_issue`; otherwise search with `Linear-list_issues`
2. Surface: title, description, acceptance criteria, labels, state, linked documents
3. If a Notion document is linked or referenced, note that the `notion-context` skill can fetch it
4. Suggest a branch name in the format `{ticket-number}-short-description`, where the description
   is at most 3–4 words in kebab-case (e.g. `prd-42-add-retry-logic`). Do not include a username
   or author prefix. Keep it short — do not try to fit the full ticket title into the branch name.
5. Offer to transition ticket state to "In Progress" — confirm before applying
6. Ask the user where the relevant codebase is if not already known, then proceed with the work

## References

- Use `notion-context` skill when a ticket links to or references a Notion document that provides
  spec or context needed for the work
