---
name: copilot-instructions
description: 'Creates or updates a .github/copilot-instructions.md file for the current repository. Use when asked to "add copilot instructions", "create repo instructions", "set up copilot context", "update copilot instructions", "generate agent instructions", or "initialize copilot for this repo". Analyzes the codebase thoroughly and writes concise, permanent instructions that help a cloud agent understand the repo at a glance: what it does, languages/frameworks, how to build and validate, and key layout/architecture facts.'
---

# Copilot Instructions

A skill for generating and maintaining `.github/copilot-instructions.md` — the permanent context file that helps any Copilot cloud agent orient quickly and work efficiently in this repository.

## When to Use This Skill

- User asks to create or update `.github/copilot-instructions.md`
- User wants to initialize Copilot context for a repository
- User asks to "add copilot instructions" or "set up agent instructions"
- User wants to improve agent quality by providing standing codebase context

## Constraints (Always Apply)

- **Length**: The finished file must fit within **two printed pages** — roughly 80–120 lines. Be ruthless about brevity. Every sentence must earn its place.
- **Not task-specific**: Do not include instructions about a current bug, feature, or PR. The file describes the codebase permanently, not a transient task.
- **No duplication of tool output**: Never reproduce what `--help`, `make help`, or a schema already provides authoritatively. Reference the command instead.
- **Plain markdown only**: No frontmatter, no HTML. The file is read verbatim by agents, so keep formatting clean and skimmable.

## Research Phase — Do This Before Writing

Before writing a single line, gather the following. **Take your time here** — thorough research produces dramatically better instructions.

### 1. Understand what the repo does
- Read `README.md` (purpose, audience, key features)
- Read any top-level docs (`docs/`, `CONTRIBUTING.md`, `ARCHITECTURE.md`) if present
- Scan entry points (`main.*`, `cmd/`, `app/`, `src/index.*`, `lib/`) to confirm the README matches reality

### 2. Identify languages, frameworks, and tooling
- Check for: `go.mod`, `package.json`, `Cargo.toml`, `pyproject.toml`/`setup.py`, `Gemfile`, `pom.xml`, `build.gradle`
- Note key frameworks, major libraries, and runtime versions where specified
- Identify infrastructure tooling: Docker, Terraform, Helm, etc.

### 3. Map the build and validation workflow
- Look for `Makefile`, `Taskfile`, `justfile`, `.github/workflows/`, `scripts/`
- Identify the commands used in CI for: building, testing, linting, formatting
- Note any required env vars or one-time setup steps documented in the README or CONTRIBUTING

### 4. Map the layout and architecture
- Note top-level directory purposes (a single sentence each is enough)
- Identify where the main entry points live
- Note any non-obvious conventions: generated code directories, vendored code, monorepo structure
- Identify where configuration lives (env files, config packages, infrastructure definitions)
- Note where tests live and how they are organized (unit vs integration, co-located vs separate)

### 5. Check for existing instructions
- If `.github/copilot-instructions.md` already exists, read it fully before deciding what to change
- Preserve accurate information; update stale or missing sections

## Writing the File

### Required Sections (in order)

```markdown
# Copilot Instructions

## Overview
One to three sentences: what this project does and who uses it.

## Tech Stack
Bullet list: language(s) + version, primary framework(s), key libraries, infra tooling.

## Build & Validate
Shell commands only — no prose duplication of what `--help` says.
Format each step as a fenced code block with the shell command.

## Repository Layout
Short table or bullet list mapping top-level directories to their purpose.
Only list directories that are non-obvious. Skip `README.md`, `LICENSE`, etc.

## Architecture Notes
A few sentences or bullets on non-obvious design decisions, patterns, or constraints
an agent should know before making changes. Examples:
- "All database queries go through the repository layer in internal/store/"
- "Proto definitions live in api/; generated code in gen/ — never edit gen/ directly"
- "Config is loaded once at startup from environment variables; no config files at runtime"

## Key Conventions
Bullet list of 3–8 hard rules or patterns the agent must follow.
Focus on things that are easy to get wrong and costly to fix.
```

### Optional Sections (include only if genuinely useful)

```markdown
## External Dependencies
Services, APIs, or credentials an agent needs to know about (not secrets — just names/roles).

## Known Landmines
Specific files, directories, or patterns to avoid touching or to treat with extra care.
```

### Tone and Style Rules

- Write for a capable software engineer reading for the first time, not a beginner
- Use imperative voice for conventions: "Always wrap errors", not "Errors should be wrapped"
- Prefer concrete examples over abstract descriptions when space allows
- Use backticks for all file paths, commands, directory names, and symbol names
- Keep each bullet to one line where possible; two lines maximum

## Output

1. Write the file to `.github/copilot-instructions.md` (create `.github/` if it does not exist)
2. If updating an existing file, show a brief diff summary of what changed and why
3. Tell the user: length (line count), what was included, and any gaps you could not fill due to missing documentation
