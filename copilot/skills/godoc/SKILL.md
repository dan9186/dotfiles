---
name: godoc
description: 'Reviews and writes Go doc comments across a codebase. Use when asked to "add godoc", "write doc comments", "audit documentation", "check my godoc", "add docs to this package", or "review Go documentation". Applies terse, non-tautological doc conventions: every exported symbol gets a comment, uniform families share a group doc, stutter is eliminated, and sentinel var blocks get a single group comment rather than per-line inline comments.'
---

# Godoc

Audit and write Go doc comments for a codebase following the established doc conventions.

## When to Use This Skill

- User asks to add, audit, or fix godoc in a package or repo
- User wants to review Go documentation quality
- User wants doc comments written before publishing a library

## Constraints (Always Apply)

- **Exported only**: Every exported symbol (type, func, method, var, const) must have a doc comment. Unexported symbols only if genuinely non-obvious.
- **No tautology**: If the name fully communicates the behavior, the comment must add something the name cannot. Never write `// Printf formats and prints` — `Printf` already says that.
- **No stutter**: Do not embed the package name in the comment body. In package `color`, `// BlackFg applies bold black` is fine; `// BlackFg is a color.BlackFg...` is stutter. Starting the comment with the symbol name (Go convention) is not stutter.
- **Uniform families**: When a group of symbols all follow the same pattern (e.g. 16 color helpers), put the explanation once in the package or group doc comment and omit per-symbol comments.
- **Sentinel var blocks**: A `var (...)` block of sentinel errors gets one group doc comment before the block. Do not add inline comments inside the block — godoc does not surface them.
- **Terse**: One line is almost always better than two. No summary-then-restatement.

## Research Phase

1. Identify the module root and all non-vendor Go packages:
   ```bash
   find . -name '*.go' -not -path '*/vendor/*' | xargs grep -l '^package ' | sort -u
   ```
2. For each package, list exported symbols and note which are missing comments or have poor ones. Use `go doc` or read sources directly.
3. Read existing package doc comments — they set the context that determines whether per-symbol comments are tautological.
4. Note any uniform families (same signature shape, same behavior pattern, only one value differs) — these get group treatment.

## Workflow

### Step 1: Package doc comment

Every `package` declaration must have a doc comment on the `package` line (or the file that is the natural entry point). It should describe: what the package does, who uses it, and any non-obvious constraints. One to three sentences.

### Step 2: Types and interfaces

- The type comment describes what the type represents, not what it is. `// Scriber is the interface for...` not `// Scriber is an interface`.
- For interfaces, document the contract in the type comment. Per-method comments describe behavior specifics (when output is emitted, what side effects occur, non-obvious preconditions).
- For structs with exported fields, document each field that isn't self-evident.

### Step 3: Functions and methods

- First word must be the function name (Go convention).
- Describe what the function does, not how. Mention non-obvious behavior: side effects, preconditions, what is returned on error.
- For `f`-suffix variants (`Printf`, `Errorf`): `// Printf is the formatted variant of Print.` — nothing more needed.
- For constructors: note what is validated and what error conditions exist.

### Step 4: Vars and consts

- Sentinel errors in a `var (...)` block: one group comment before the block describing the shared shape (e.g. `// Sentinel errors returned by Validate for missing fields.`). No inline comments inside.
- Const groups: one comment on the group describing the set. Individual constants only need comments when their value or meaning isn't obvious from the name.

### Step 5: Review pass

After writing, re-read each comment and ask:
- Does this say anything the name doesn't? If not, delete it or rewrite it.
- Does it repeat the package name needlessly (stutter)?
- Is it longer than one line without a good reason?
- Does it start with the symbol name?

## Output

- Apply edits directly to source files.
- Run `go vet ./...` after editing — vet checks basic doc comment formatting.
- Report: how many symbols were documented, how many comments were removed as tautological, and any symbols intentionally left without comments (with the reason).
