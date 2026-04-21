# Agent Instructions

## Overview

Centralized personal dotfiles repo at `~/dotfiles`. Manages shell, terminal, git, tmux, SSH, and
system preferences — primarily for macOS, with Linux and Windows support in `bootstrap.sh`.

## Tech Stack

- **Shell**: zsh + Oh My Zsh (primary), bash (scripts)
- **macOS packages**: Homebrew (`Brewfile`)
- **Linux packages**: native package managers (apt/dnf/yum/pacman/zypper)
- **Terminal**: Alacritty
- **Editor config**: git, tmux, ack, ripgrep, wget, gpg

## Build & Validate

Full machine setup from scratch:
```bash
./bootstrap.sh && ./install.sh
```

Apply symlink changes only:
```bash
./install.sh
```

Apply macOS system preferences only:
```bash
./preferences/macos.sh
```

Regenerate Brewfile after any install/uninstall:
```bash
brew bundle dump -f
```

## Repository Layout

| Path | Purpose |
|------|---------|
| `bootstrap.sh` | Stage 1: prerequisites, packages, Oh My Zsh, SSH keys, hostname |
| `install.sh` | Stage 2: symlinks all dotfiles into `$HOME` |
| `Brewfile` | Homebrew packages and casks — do not hand-edit |
| `packages/` | Package lists for Linux (`linux.txt`), Windows (`windows.txt`), Go (`go.txt`) |
| `preferences/macos.sh` | macOS `defaults write` settings, organized by category |
| `omz/` | Oh My Zsh themes, plugins, aliases, and options |
| `copilot/` | Copilot config and skills — all symlinked by `install.sh` |
| `alacritty_themes/` | TOML color themes for Alacritty |
| `tmux/battery.sh` | Multi-OS battery display for tmux status bar |

## Architecture Notes

- `install.sh` uses two primitives: `link_file <src> [dest]` (unconditional symlink) and
  `deps <cmd> && link_file ...` (only links if `<cmd>` is in PATH). Both are idempotent —
  conflicts are backed up to `<dest>.old`.
- `copilot/skills/<name>/` directories are each symlinked individually to `~/.copilot/skills/<name>/`
  via `link_skill` in `install.sh` — not the parent directory.
- `bootstrap.sh` detects the OS via `uname -s` and branches accordingly throughout.
- Machine-local git overrides go in `~/.gitconfig.local` (via `[include]`), never in `gitconfig`.
- SSH hosts are split: add to `~/.ssh/work/config` or `~/.ssh/home/config`, not directly to `sshconfig`.

## Key Conventions

- Never hand-edit `Brewfile` — always regenerate with `brew bundle dump -f`.
- Always edit source files in `~/dotfiles/`, never the symlink targets in `$HOME`.
- Add shell aliases to `omz/aliases.zsh`, not directly to `zshrc.omz`.
- Add git aliases under `[alias]` in `gitconfig` in alphabetical order.
- New `preferences/macos.sh` settings follow the `set_<category>_<setting>()` function pattern;
  use `defaults -currentHost write` for hardware/per-machine settings, `defaults write` for user-level.
- Secrets go in `~/.private_env_secrets` (chmod 600, never committed). Work env in `~/.work_zprofile`.
- The `description` frontmatter in each `copilot/skills/<name>/SKILL.md` drives automatic skill
  matching — keep it precise and accurate.
