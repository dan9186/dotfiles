---
name: changelog
description: 'Generates formatted changelogs and release notes for software projects by comparing git tags, branches, or commit ranges. Use when asked to "generate release notes", "create a changelog", "what changed since <tag>", "summarize changes between versions", or "write a changelog for this release". Combines git commit history with session context to produce categorized, human-readable change summaries.'
---

# Changelog

A skill for generating formatted changelogs and release notes from git history and session context.

## When to Use This Skill

- User asks to generate release notes or a changelog
- User wants to summarize changes between two git refs (tags, branches, commits)
- User wants to know what changed since a specific version
- User is preparing a release and needs a human-readable summary of changes

## Output Format

Each line follows this format:

```
- `CATEGORY` &mdash; explanation of the change
```

Use these categories — only include categories that have entries:

| Category | When to use |
|---|---|
| `ADDED` | New features, commands, flags, or behaviors |
| `CHANGED` | Modifications to existing functionality or behavior |
| `DEPRECATED` | Features that still work but are planned for removal |
| `REMOVED` | Features, flags, or behaviors that no longer exist |
| `FIXED` | Bug fixes |
| `SECURITY` | Security-related fixes or improvements |

## Step-by-Step Workflow

### Step 1: Determine the commit range

Ask the user for the range if not provided. Common forms:
- Tag to HEAD: `v1.2.3..HEAD`
- Tag to tag: `v1.2.2..v1.2.3`
- Branch to branch: `main..feature`

### Step 2: Gather git history

```bash
git --no-pager log <range> --oneline
git --no-pager log <range> --format="%s%n%b"
```

### Step 3: Cross-reference with session context

If the current session involved making code changes, use that context to enrich or clarify the changelog beyond what commit messages alone convey. Commit messages are often terse — the session context fills in the "why" and exact behavioral impact.

### Step 4: Classify each change

Map commits and session context to the appropriate category. One line per distinct change. Combine closely related commits into a single entry when they represent one logical change.

### Step 5: Write the entries

- Start each entry with the affected command, flag, function, or component in backticks where applicable
- Be specific about behavioral impact, not just implementation details
- Order entries within each category from most user-visible to least

## Example Output

```
- `ADDED` &mdash; `status` command to show working tree status across repositories; supports `--short`/`-s` and `--ignore-empty` flags
- `ADDED` &mdash; `commit --sign`/`-s` flag to create GPG-signed annotated tags (requires `--message`)
- `CHANGED` &mdash; non-verbose mode no longer halts on first error; all repositories are processed and failures are reported together at the end
- `FIXED` &mdash; progress bar was only shown on the delete path; now also shown during tag creation
- `SECURITY` &mdash; inspects `tag.gpgSign` git config and errors early rather than allowing git to open an interactive subprocess editor
```

## Tips

- If commit messages are sparse, rely more heavily on session context and code diffs
- Omit merge commits from the output unless they convey meaningful information
- When a change affects multiple commands, list them all in one entry rather than repeating the same description
- If the user wants a specific version number in a header, add it above the entries: `## v1.2.3`
