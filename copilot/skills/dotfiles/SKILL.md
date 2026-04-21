---
name: dotfiles
description: 'Toolkit for adding, modifying, and managing dotfiles in the centralized dotfiles repository at ~/dotfiles. Use when asked to update my dotfiles, add a new config file, update shell aliases or configuration, update SSH config, wire up any new tool config into the install script, update my custom Copilot instructions, or add/modify a Copilot skill. Understands the symlink-based install pattern, Brewfile management, and the two-stage bootstrap/install workflow.'
---

# Dotfiles Skill

Manage the centralized dotfiles repo at `~/dotfiles` (https://github.com/dan9186/dotfiles).

## Key Paths (start here — do not search)

| What | Path |
|---|---|
| Repo root | `~/dotfiles/` |
| Custom Copilot instructions | `~/dotfiles/copilot/copilot-instructions.md` |
| LSP server config | `~/dotfiles/copilot/lsp-config.json` |
| MCP server config | `~/dotfiles/copilot/mcp-config.json` |
| Skills directory | `~/dotfiles/copilot/skills/` |
| Individual skill | `~/dotfiles/copilot/skills/<skill-name>/SKILL.md` |
| Install script | `~/dotfiles/install.sh` |
| Shell env / PATH | `~/dotfiles/zprofile` |
| Shell plugins / prompt | `~/dotfiles/zshrc.omz` |
| Aliases | `~/dotfiles/omz/aliases.zsh` |

## When to Use This Skill

- User asks to "update my dotfiles", "add a new config file", "modify my shell aliases", "change my zsh/tmux/git/alacritty configuration", "update SSH config", or "wire up a new tool config into the install script".
- User asks to "update my custom instructions", "update my Copilot instructions", or "add a new Copilot skill".

## Repo Layout

```
~/dotfiles/
├── bootstrap.sh          # Stage 1: new machine setup (Homebrew, Oh My Zsh, SSH keys)
├── install.sh            # Stage 2: symlinks dotfiles into $HOME
├── Brewfile              # Homebrew packages and casks
├── zshrc.omz             # Zsh + Oh My Zsh config (symlinked → ~/.zshrc)
├── zprofile              # Environment variables and PATH (symlinked → ~/.zprofile)
├── gitconfig             # Git config, aliases, URL rewrites
├── tmux.conf             # Tmux options and keybindings
├── tmux/battery.sh       # Multi-OS battery display for tmux status
├── alacritty.toml        # Alacritty terminal config
├── alacritty_themes/     # Color theme TOML files
├── sshconfig             # SSH hosts and key strategy
├── preferences/
│   └── macos.sh          # macOS system preferences (applied by bootstrap.sh)
├── omz/
│   ├── themes/           # Custom zsh themes (dan9186.zsh-theme)
│   ├── plugins/          # Custom Oh My Zsh plugins
│   ├── aliases.zsh
│   └── options.zsh
└── copilot/
    ├── copilot-instructions.md
    ├── lsp-config.json
    ├── mcp-config.json
    └── skills/
```

## How install.sh Works

`install.sh` uses two conventions you must follow when adding a new dotfile:

### 1. Unconditional link

For always-present tools (e.g., alacritty):
```bash
link_file <source-file>                        # symlinks to ~/.<source-file>
link_file <source-file> <dest-path>            # symlinks to ~/.<dest-path>
```

### 2. Conditional link (guarded by `deps`)

For tools that may or may not be installed:
```bash
deps <command> && link_file <source-file>
deps <command> && link_file <source-file> <dest-relative-path>
```

`deps` checks each argument with `hash` — it returns true only if all named commands exist in `$PATH`. If the dep is missing, the link is silently skipped (no error).

**Examples from install.sh:**
```bash
deps git && link_file gitconfig
deps gpg-agent && link_file gpg-agent.conf gnupg/gpg-agent.conf
deps ssh && link_file sshconfig ssh/config
deps zsh && link_file zprofile && link_file zshrc.omz zshrc
```

The symlink is always created as: `ln -s "$PWD/<source>" "$HOME/.<dest>"`

`link_file` is **idempotent** — re-running `install.sh` skips already-linked files and backs up any conflicting file to `<dest>.old`.

## Adding a New Dotfile — Checklist

1. **Create the config file** at the repo root (or a subdirectory for grouped configs).
2. **Add a `link_file` call** in `install.sh`:
   - Wrap with `deps <tool>` if the tool may not always be installed.
   - Use a destination path (`link_file src dest`) when the target isn't `~/.<filename>`.
3. **Add the tool to `Brewfile`** if it should be installed via Homebrew.
4. **Test** by running `./install.sh` — verify the symlink appears at `$HOME/.<dest>`.

## Brewfile Conventions

The Brewfile is generated from what is currently installed on the system — do **not** manually edit individual entries. To update it:

```bash
brew bundle dump -f
```

This overwrites `~/dotfiles/Brewfile` with the current system state. Run this after installing or uninstalling any Homebrew packages, casks, or taps so the repo stays in sync.

## Shell Configuration (zsh)

### zprofile — environment and PATH

- Add new environment variables, `export` statements, and PATH modifications here.
- Tool-specific blocks use comments like `# tool-name` for grouping.
- Secrets or machine-specific values go in `~/.private_env_secrets` (chmod 600, never committed) or `~/.work_zprofile` — source them conditionally:
  ```bash
  [ -f "$HOME/.private_env_secrets" ] && source "$HOME/.private_env_secrets"
  ```
- Homebrew prefix is detected dynamically:
  ```bash
  [ -d "/opt/homebrew" ] && eval "$(/opt/homebrew/bin/brew shellenv)"  # Apple Silicon
  [ -d "/usr/local" ] && eval "$(/usr/local/bin/brew shellenv)"        # Intel
  ```

### zshrc.omz — plugins and prompt

- `ZSH_CUSTOM` points to `$HOME/dotfiles/omz` — all custom themes and plugins live there.
- To enable a new Oh My Zsh plugin, add it to the `plugins=(...)` array in `zshrc.omz`.
- To add a **custom plugin**: create `omz/plugins/<plugin-name>/<plugin-name>.plugin.zsh`.
- To add a **custom theme**: create `omz/themes/<theme-name>.zsh-theme`.
- The active theme is `ZSH_THEME="dan9186"` — edit `omz/themes/dan9186.zsh-theme` to change the prompt.

### omz/aliases.zsh

Add shell aliases here (not in zshrc.omz directly).

## Git Configuration (gitconfig)

- `gitconfig` uses `[include]` for machine-local overrides: `~/.gitconfig.local` (not committed).
- Add new aliases under `[alias]` in alphabetical order.

## Tmux Configuration

- `tmux.conf` — options, keybindings, and status bar.
- `tmux/battery.sh` handles macOS (`ioreg`), Linux (`acpi`), FreeBSD, Android (Termux), OpenBSD.
- To change the color scheme, edit the `colour*` values in the `set -g status-*` lines.

## SSH Configuration

`sshconfig` uses `Include` to split work and personal keys:
```
Include work/config
Include home/config
```
Add new host entries to the appropriate sub-config (`~/.ssh/work/config` or `~/.ssh/home/config`), not directly to `sshconfig` unless it's a shared entry like GitHub.

## Listen for Standard Updates

If at any point the user says something like:
- "we should always do X when adding dotfiles"
- "add a new convention to the install workflow"
- "every new dotfile should have Y"

**Do not update `SKILL.md` immediately.** Instead:

1. Acknowledge the suggestion
2. Propose the addition: show exactly what it would look like in `SKILL.md`
3. Note whether it should be a hard rule or a guideline
4. Wait for explicit confirmation before modifying
5. After confirmation, update `SKILL.md` at `~/dotfiles/copilot/skills/dotfiles/SKILL.md`
6. Tell the user to commit the change to `~/dotfiles` and run `skills-sync` to persist it

## Testing Changes

```bash
# Re-run the install script to apply symlink changes
cd ~/dotfiles && ./install.sh

# Verify a symlink
ls -la ~/.<dest>
```

## Copilot Instructions and Skills

### Custom Instructions (`copilot/copilot-instructions.md`)

- Lives at `~/dotfiles/copilot/copilot-instructions.md` and is symlinked to `~/.copilot/copilot-instructions.md` by `install.sh`.
- This is the authoritative source for all custom Copilot behavior: tone, coding style, preferred languages, workflow preferences, etc.
- When the user asks to update their custom instructions, edit **this file in the dotfiles repo** (not the symlink target directly).
- After editing, commit and push from `~/dotfiles`.

### Config Files (`copilot/lsp-config.json` and `copilot/mcp-config.json`)

- `lsp-config.json` configures Language Server Protocol (LSP) servers for the Copilot CLI (currently: `gopls` for Go).
- `mcp-config.json` configures Model Context Protocol (MCP) servers for the Copilot CLI (currently: Linear and Notion).
- Both files live in `~/dotfiles/copilot/` and are symlinked by `install.sh` to `~/.copilot/`.
  - `~/.copilot/lsp-config.json` → `~/dotfiles/copilot/lsp-config.json`
  - `~/.copilot/mcp-config.json` → `~/dotfiles/copilot/mcp-config.json`
- **These two paths point to the exact same file via symlink.** Never be confused by seeing the file appear in both locations — there is only one copy.
- Always edit the source in `~/dotfiles/copilot/` (not the symlink), then commit and push from `~/dotfiles`.

### Skills (`copilot/skills/`)

- Each skill lives in `~/dotfiles/copilot/skills/<skill-name>/SKILL.md`.
- `install.sh` symlinks each skill directory into `~/.copilot/skills/<skill-name>`.
- The `description` frontmatter in `SKILL.md` is what drives automatic skill matching — keep it precise and include the natural-language phrases a user would say to trigger the skill.
- When adding or modifying a skill, edit the file in the dotfiles repo, then commit and push.

## OS Preferences (`preferences/`)

`bootstrap.sh` calls `apply_preferences()` which detects the OS and runs the matching script:

| OS | Script |
|---|---|
| macOS | `preferences/macos.sh` |
| Linux | `preferences/linux.sh` *(not yet created)* |
| Windows | `preferences/windows.sh` *(not yet created)* |

### Pattern for `macos.sh`

Settings are organized into sections by category. Each setting is a standalone function, then called in the **Apply** block at the bottom of the file:

```bash
# =============================================================================
# Category Name
# =============================================================================

set_<category>_<setting> () {
    echo "  → Human-readable description"
    defaults write <domain> <key> <value>
    # or: defaults -currentHost write <domain> <key> <value>
}

# ...in the Apply block at the bottom:
echo "Category Name"
set_<category>_<setting>
echo
```

**When to use `-currentHost`:** Use `defaults -currentHost write` for per-machine settings (e.g., hardware-related like Bluetooth, display). Use `defaults write` for user-level settings (e.g., Finder, apps).

**After adding a new setting:** Run `~/dotfiles/preferences/macos.sh` directly to apply it, or re-run `~/dotfiles/bootstrap.sh` to apply everything from scratch. The script ends with `killall Finder` to pick up Finder-related changes.

**To add a new OS:** Create `preferences/<os>.sh` following the same category/function pattern, then add a branch to the `apply_preferences()` function in `bootstrap.sh`.

## Go-Specific Environment (zprofile)

To add a new private GitHub org to GOPRIVATE, append it comma-separated.
