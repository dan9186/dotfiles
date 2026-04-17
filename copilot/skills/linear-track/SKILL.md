---
name: linear-track
description: 'Creates a parent or tracking ticket in Linear to represent a larger body of work, grouping existing (or to-be-created) tickets as children. Use when asked to "create a parent ticket", "track this body of work", "create a tracking ticket", "group these tickets under a parent", "make these child tickets", or "create an epic".'
---

# Linear Track

Create a parent ticket in Linear that represents a larger body of work, with existing (or
to-be-created) tickets as children.

## When to Use This Skill

- User wants a single ticket to track a group of related tickets
- User wants to create an epic or initiative-level ticket
- User wants to group existing tickets under a parent

## Constraints

- Never create a ticket without showing a preview and confirming
- Never set `parentId` on child tickets without confirming
- Auto-assign the parent ticket to `me` unless explicitly told otherwise

## Steps

1. Fetch all child tickets with `Linear-get_issue` to read their titles, descriptions, and current
   states
2. Infer a parent ticket title that captures the overarching theme (not just a list of child titles)
3. Draft a description that includes:
   - A brief problem statement or motivation (why this body of work exists)
   - A summary table of child tickets: ticket ID, finding/task, current status
   - Scope: what systems, surfaces, or people are involved
   - Any supporting context the user provides (reports, external docs, decisions)
4. Determine the appropriate initial state (see **Ticket State Guidance** below) — the parent state
   should reflect the aggregate progress of its children
5. Show a preview (title, description, assignee, priority, state) and confirm before creating
6. After creating the parent, set `parentId` on all child tickets via `Linear-save_issue`
7. If the user has supporting attachments (PDFs, reports, etc.), attach them via
   `Linear-create_attachment` to the parent ticket only unless explicitly told otherwise
8. Share the parent ticket ID and URL

## Ticket State Guidance

When creating the parent ticket, derive its initial state from the aggregate child states. Always
confirm the state as part of the preview — do not silently apply a state.

| Situation | Recommended State |
|-----------|------------------|
| All children are Backlog or Todo | **Backlog** |
| Any child is In Progress | **In Progress** |
| All children are Done | **Done** |
| Children span multiple states | Default to the state of the least-complete child |

## References

- Use `notion-context` skill when a ticket links to or references a Notion document that provides
  spec or context needed for the work
