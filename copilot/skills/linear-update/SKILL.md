---
name: linear-update
description: 'Writes findings, results, or progress back to an existing Linear ticket. Use when asked to "update the ticket", "write results to the ticket", "add a comment to the ticket", "log what I did", or "post an update".'
---

# Linear Update

Write a structured update back to a Linear ticket — summarizing what was done, why, and any
caveats or follow-ups.

## When to Use This Skill

- Work is done or partially done and the user wants to write back to the ticket
- User wants to post a progress comment or status update on a ticket

## Constraints

- Never post a comment without showing a preview and confirming
- Never change ticket state without confirming the transition

## Steps

1. Gather what was done: ask the user to summarize, or infer from git context
2. Draft a structured comment:
   - **What changed**: brief description of the implementation
   - **Why**: motivation or approach decision if relevant
   - **Caveats / follow-ups**: anything left open or worth noting
3. Show the comment preview and confirm before posting via `Linear-save_comment`
4. Ask whether to transition the ticket state (e.g., "Done") — confirm before applying

## References

- Use `notion-context` skill when a ticket links to or references a Notion document that provides
  spec or context needed for the work
