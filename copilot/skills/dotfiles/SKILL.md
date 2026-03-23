---
name: dotfiles
description: 'Toolkit for adding, modifying, and managing dotfiles in the centralized dotfiles repository at ~/dotfiles. Use when asked to update my dotfiles, add a new config file, update shell aliases or configuration, update SSH config, or wire up any new tool config into the install script. Understands the symlink-based install pattern, Brewfile management, and the two-stage bootstrap/install workflow.'
---

# Dotfiles Skill

Manage the centralized dotfiles repo at `~/dotfiles` (https://github.com/dan9186/dotfiles).

## When to Use This Skill

- User asks to "update my dotfiles", "add a new config file", "modify my shell aliases", "change my zsh/tmux/git/alacritty configuration", "update SSH config", or "wire up a new tool config into the install script".
- User asks to "update my Copilot instructions" or "add a new Copilot skill" that requires changes to the dotfiles repo

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
├── omz/
│   ├── themes/           # Custom zsh themes (dan9186.zsh-theme)
│   ├── plugins/          # Custom Oh My Zsh plugins
│   ├── aliases.zsh
│   └── options.zsh
└── copilot/
    ├── copilot-instructions.md
    ├── lsp-config.json
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

## Testing Changes

```bash
# Re-run the install script to apply symlink changes
cd ~/dotfiles && ./install.sh

# Verify a symlink
ls -la ~/.<dest>
```

## Go-Specific Environment (zprofile)

To add a new private GitHub org to GOPRIVATE, append it comma-separated.
