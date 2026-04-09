---
name: create-skill
description: 'Create new Agent Skills for GitHub Copilot from prompts or by duplicating this template. Use when asked to "create a skill", "make a new skill", "scaffold a skill", or when building specialized AI capabilities with bundled resources. Generates SKILL.md files with proper frontmatter, directory structure, and optional scripts/references/assets folders.'
---

# Create Skill

A meta-skill for creating new Agent Skills. Use this skill when you need to scaffold a new skill folder, generate a SKILL.md file, or help users understand the Agent Skills specification.

## When to Use This Skill

- User asks to "create a skill", "make a new skill", or "scaffold a skill"
- User wants to add a specialized capability to their GitHub Copilot setup
- User needs help structuring a skill with bundled resources
- User wants to duplicate this template as a starting point

## Prerequisites

- Understanding of what the skill should accomplish
- A clear, keyword-rich description of capabilities and triggers
- Knowledge of any bundled resources needed (scripts, references, assets, templates)

## Creating a New Skill

### Step 1: Create the Skill Directory

Create a new folder with a lowercase, hyphenated name:

```
skills/<skill-name>/
└── SKILL.md          # Required
```

### Step 2: Generate SKILL.md with Frontmatter

Every skill requires YAML frontmatter with `name` and `description`:

```yaml
---
name: <skill-name>
description: '<What it does>. Use when <specific triggers, scenarios, keywords users might say>.'
---
```

#### Frontmatter Field Requirements

| Field | Required | Constraints |
|-------|----------|-------------|
| `name` | **Yes** | 1-64 chars, lowercase letters/numbers/hyphens only, must match folder name |
| `description` | **Yes** | 1-1024 chars, must describe WHAT it does AND WHEN to use it |
| `license` | No | License name or reference to bundled LICENSE.txt |
| `compatibility` | No | 1-500 chars, environment requirements if needed |
| `metadata` | No | Key-value pairs for additional properties |
| `allowed-tools` | No | Space-delimited list of pre-approved tools (experimental) |

#### Description Best Practices

**CRITICAL**: The `description` is the PRIMARY mechanism for automatic skill discovery. Include:

1. **WHAT** the skill does (capabilities)
2. **WHEN** to use it (triggers, scenarios, file types)
3. **Keywords** users might mention in prompts

**Good example:**

```yaml
description: 'Toolkit for testing local web applications using Playwright. Use when asked to verify frontend functionality, debug UI behavior, capture browser screenshots, or view browser console logs. Supports Chrome, Firefox, and WebKit.'
```

**Poor example:**

```yaml
description: 'Web testing helpers'
```

### Step 3: Write the Skill Body

After the frontmatter, add markdown instructions. Recommended sections:

| Section | Purpose |
|---------|---------|
| `# Title` | Brief overview |
| `## When to Use This Skill` | Reinforces description triggers |
| `## Prerequisites` | Required tools, dependencies |
| `## Step-by-Step Workflows` | Numbered steps for tasks |
| `## Troubleshooting` | Common issues and solutions |
| `## References` | Links to bundled docs |

#### How to Write the Body

The body is **instructions to an agent, not documentation for a human**. Write it accordingly:

- Use **imperative voice**: "Read the README first", not "The README should be consulted"
- Be **prescriptive**: tell the agent exactly what to do, in what order, and why constraints exist
- Prefer **concrete examples and commands** over abstract descriptions
- Front-load the most important constraints — the agent must not miss them
- Keep total body length under 150 lines; every line should change agent behavior

A well-written skill body reads like a checklist written by an expert who has done the task many times and knows exactly where agents go wrong.

#### Annotated Example: Complete Skill Body

The following is a realistic skill body with inline comments explaining the intent of each part. Use it as a style reference when writing new skills.

````markdown
# My Skill Title
<!-- One sentence saying what this skill produces or accomplishes. -->

## When to Use This Skill
<!-- Mirror the description triggers. Helps the agent confirm it picked the right skill. -->
- User asks to "do X", "create Y", or "set up Z"
- User mentions keywords: foo, bar, baz

## Constraints (Always Apply)
<!-- List hard rules FIRST, before any workflow. The agent must internalize these before acting. -->
- **Length**: Output must be under 100 lines — trim ruthlessly
- **No duplication**: Never reproduce what `--help` or a schema already says; reference it instead
- **Format**: Plain markdown only, no frontmatter, no HTML

## Research Phase — Do This Before Writing
<!-- If the skill involves analyzing something (a codebase, a diff, a config), describe
     what to read and why. Good research produces dramatically better output. -->
1. Read `README.md` to understand purpose and audience
2. Check `package.json` / `go.mod` / `Cargo.toml` for language and framework
3. Scan `Makefile` or `.github/workflows/` for build and test commands

## Workflow
<!-- The main steps, in order. Number them. Be specific about inputs, outputs, and decisions. -->
1. Do the first thing
2. If condition X, do Y; otherwise do Z
3. Write the output to `path/to/file` (create parent dirs if needed)

## Output
<!-- Describe what a correct result looks like: file written, command run, summary printed. -->
- Write the file to `<target path>`
- Tell the user: what was included, what was skipped, and why
````

### Step 4: Add Optional Directories (If Needed)

| Folder | Purpose | When to Use |
|--------|---------|-------------|
| `scripts/` | Executable code (Python, Bash, JS) | Automation that performs operations |
| `references/` | Documentation agent reads | API references, schemas, guides |
| `assets/` | Static files used AS-IS | Images, fonts, templates |
| `templates/` | Starter code agent modifies | Scaffolds to extend |

## Example: Complete Skill Structure

```
my-awesome-skill/
├── SKILL.md                    # Required instructions
├── LICENSE.txt                 # Optional license file
├── scripts/
│   └── helper.py               # Executable automation
├── references/
│   ├── api-reference.md        # Detailed docs
│   └── examples.md             # Usage examples
├── assets/
│   └── diagram.png             # Static resources
└── templates/
    └── starter.ts              # Code scaffold
```

## Quick Start

1. Create `~/.copilot/skills/<skill-name>/SKILL.md`
2. Add frontmatter with `name` and `description`
3. Write the body following the annotated example above
4. Validate against the checklist below

## Validation Checklist

- [ ] Folder name is lowercase with hyphens
- [ ] `name` field matches folder name exactly
- [ ] `description` is 10-1024 characters
- [ ] `description` explains WHAT and WHEN
- [ ] `description` is wrapped in single quotes
- [ ] Body content is under 500 lines
- [ ] Bundled assets are under 5MB each

## Reference Implementations

These skills in `~/.copilot/skills/` are good examples to read before writing a new one:

| Skill | Good reference for |
|-------|--------------------|
| `changelog` | Workflow-heavy skill: clear research phase, explicit output format, good use of constraints |
| `copilot-instructions` | Analysis-then-write pattern: thorough research phase, constrained output length, required/optional sections |
| `dotfiles` | Environment-aware skill: references specific file paths and install patterns |
| `new-go-cli` | Scaffolding skill: opinionated output, links to existing patterns without duplicating them |

Read at least one reference skill before writing a new one to calibrate tone, depth, and structure.

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Skill not discovered | Improve description with more keywords and triggers |
| Validation fails on name | Ensure lowercase, no consecutive hyphens, matches folder |
| Description too short | Add capabilities, triggers, and keywords |
| Assets not found | Use relative paths from skill root |

## References

- Agent Skills official spec: <https://agentskills.io/specification>
