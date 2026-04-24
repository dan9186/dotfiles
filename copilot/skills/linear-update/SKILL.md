---
name: linear-update
description: 'Writes findings, results, or progress back to an existing Linear ticket. Use when asked to "update the ticket", "write results to the ticket", "add a comment to the ticket", "log what I did", "post an update", "update the ticket description", "update the contents of the ticket", "add details to the ticket", or "put info into the ticket".'
---

# Linear Update

Write a structured update back to a Linear ticket — summarizing what was done, why, and any
caveats or follow-ups.

## When to Use This Skill

- Work is done or partially done and the user wants to write back to the ticket
- User wants to post a progress comment or status update on a ticket
- User wants to update the description or body of a ticket with new information

## Update Mode — Comment vs. Description

Before drafting content, determine the right update mechanism:

| Signal | Mechanism |
|--------|-----------|
| "add a comment", "post an update", "log what I did" | `Linear-save_comment` |
| "update the ticket description", "put info into the ticket", "update the contents of the ticket", editing existing context or adding structured info | `Linear-save_issue` with `description` field |

When unclear, default to a **comment** for progress/status updates and a **description edit** for
structured reference information (specs, context, migration guides, service lists, etc.).

## Constraints

- Never post a comment without showing a preview and confirming
- Never change ticket state without confirming the transition

## Steps

1. Gather what was done: ask the user to summarize, or infer from git context
2. Determine update mechanism (comment vs. description edit — see above)
3. Draft the update:
   - **Comment**: **What changed** · **Why** · **Caveats / follow-ups**
   - **Description edit**: structured Markdown that will replace or augment the existing description
4. Show a preview and confirm before posting via `Linear-save_comment` or `Linear-save_issue`
5. For comments: ask whether to transition the ticket state (e.g., "Done") — confirm before applying

## References

- Use `notion-context` skill when a ticket links to or references a Notion document that provides
  spec or context needed for the work
