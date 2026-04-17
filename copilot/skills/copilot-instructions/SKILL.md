---
name: copilot-instructions
description: 'Creates or updates an AGENTS.md file for the current repository, or converts existing agent/copilot instruction files into AGENTS.md. Use when asked to "add agent instructions", "create an AGENTS.md", "set up copilot context", "convert copilot instructions to AGENTS.md", "generate agent instructions", "initialize agent context for this repo", or "convert my instruction file". Analyzes the codebase thoroughly and writes concise, permanent instructions that help a cloud agent understand the repo at a glance: what it does, languages/frameworks, how to build and validate, and key layout/architecture facts.'
---

# Agent Instructions Skill

A skill for generating, maintaining, and converting agent instruction files into `AGENTS.md` — the permanent context file that helps any AI coding agent orient quickly and work efficiently in this repository.

## When to Use This Skill

- User asks to create or update `AGENTS.md`
- User wants to convert an existing instruction file (`.github/copilot-instructions.md`, `CLAUDE.md`, `.cursorrules`, etc.) into `AGENTS.md`
- User wants to initialize agent context for a repository
- User asks to "add agent instructions" or "set up agent context"
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

### 5. Check for existing AI context files

Other AI tools often have their own context files that may already contain accurate, well-considered descriptions of the codebase. **Read all of these before writing** — they are high-signal sources and should be mined heavily. When the user asks to convert one of these files, it becomes the primary source. If `AGENTS.md` already exists in the repo, treat it as the primary source and update it rather than recreating it from scratch.

| File | Tool | What it typically contains |
|------|------|---------------------------|
| `CLAUDE.md` | Anthropic Claude | Architecture, conventions, build commands, gotchas |
| `AGENTS.md` | OpenAI Codex / custom agents | Agent-specific workflow instructions |
| `GEMINI.md` | Google Gemini | Repo context and task guidance |
| `.cursor/rules` or `.cursorrules` | Cursor | Coding style, conventions, file structure |
| `.github/copilot-instructions.md` | GitHub Copilot | Repo instructions to consolidate into AGENTS.md |

For each file found: extract facts about purpose, tech stack, conventions, build steps, and architecture. Prefer information from these files over your own inference — they were written by someone who knows the repo.

Where sources conflict: **stop and surface each conflict to the user before writing**. Present the differing values, which files they came from, and ask the user which one is correct. Do not resolve conflicts by assumption.

## Writing the File

### Required Sections (in order)

```markdown
# Agent Instructions

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

1. Write the file to `AGENTS.md` at the repository root (create it if it does not exist)
2. If an existing instruction file was the source of a conversion, note which file was converted and offer to delete or archive the original
3. If updating an existing `AGENTS.md`, show a brief diff summary of what changed and why
4. Tell the user: length (line count), what was included, and any gaps you could not fill due to missing documentation
