# Dotfiles Repo

Centralized personal config repo at `~/dotfiles` (https://github.com/dan9186/dotfiles).
Manages shell, terminal, git, tmux, SSH, and system preferences for macOS (primary OS).

- Re-run `./install.sh` to apply any symlink changes.
- Run `./bootstrap.sh` followed by `./install.sh` for full machine setup from scratch.

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
│   ├── themes/           # Custom zsh themes (active: dan9186.zsh-theme)
│   ├── plugins/          # Custom Oh My Zsh plugins
│   ├── aliases.zsh
│   └── options.zsh
└── copilot/
    ├── copilot-instructions.md  # symlinked → ~/.copilot/copilot-instructions.md
    ├── lsp-config.json          # symlinked → ~/.copilot/lsp-config.json
    ├── mcp-config.json          # symlinked → ~/.copilot/mcp-config.json
    └── skills/                  # each subdir symlinked → ~/.copilot/skills/<name>/
```

## install.sh

`link_file` and `deps` are the two building blocks:

```bash
# Unconditional symlink (~/.<source> or ~/.<dest>)
link_file <source>
link_file <source> <dest>

# Conditional — only links if the command exists in PATH
deps <command> && link_file <source>
deps <command> && link_file <source> <dest>
```

`link_file` is idempotent — backs up conflicts to `<dest>.old`. `deps` uses `hash` to check PATH.

## Brewfile

Do **not** hand-edit. Regenerate from the current system state after any install/uninstall:

```bash
brew bundle dump -f
```

## Shell Config (zsh)

- **`zprofile`** — environment variables, PATH, and tool exports. Group settings by tool with
  `# tool-name` comments. Secrets go in `~/.private_env_secrets` (chmod 600, never committed).
  Work-specific env goes in `~/.work_zprofile` (never committed). The `copilot()` function here
  wraps the CLI with pre-approved `--allow-tool` flags for read-only and git/gh commands.
- **`zshrc.omz`** — Oh My Zsh plugins and theme. Add new plugins to the `plugins=(...)` array.
- **`omz/aliases.zsh`** — shell aliases (do not add directly to zshrc.omz).
- **`omz/plugins/<name>/<name>.plugin.zsh`** — custom OMZ plugins.
- **`omz/themes/<name>.zsh-theme`** — custom themes.

## OS Preferences (`preferences/`)

`bootstrap.sh` detects the OS and runs the matching script. Currently only `macos.sh` exists;
`linux.sh` and `windows.sh` are expected names if/when those platforms are added.

Settings follow a function-per-setting pattern organized by category:

```bash
# =============================================================================
# Category Name
# =============================================================================

set_<category>_<setting> () {
    echo "  → Human-readable description"
    defaults write <domain> <key> <value>
}

# Apply block at bottom — call each function in category groups
echo "Category Name"
set_<category>_<setting>
echo
```

- Use `defaults -currentHost write` for hardware/per-machine settings (e.g., Bluetooth, display).
- Use `defaults write` for user-level settings (e.g., Finder, app behavior).
- Run `./preferences/macos.sh` directly to apply changes without a full bootstrap.
- The script ends with `killall Finder` to pick up any Finder-related changes.

## Git Config (`gitconfig`)

- Uses `[include]` for machine-local overrides via `~/.gitconfig.local` (not committed).
- Add new aliases under `[alias]` in alphabetical order.

## SSH Config (`sshconfig`)

Uses `Include` to split work and personal keys:

```
Include work/config
Include home/config
```

Add new hosts to `~/.ssh/work/config` or `~/.ssh/home/config`, not directly to `sshconfig`
unless it's a shared entry (e.g., GitHub).

## Copilot Config (`copilot/`)

All files here are symlinked by `install.sh` — always edit the source, never the symlink target.

- `copilot-instructions.md` → `~/.copilot/copilot-instructions.md` (global Copilot behavior)
- `lsp-config.json` → `~/.copilot/lsp-config.json` (currently: `gopls` for Go)
- `mcp-config.json` → `~/.copilot/mcp-config.json` (currently: Linear, Notion)
- `skills/<name>/` → `~/.copilot/skills/<name>/` (each skill directory symlinked individually)

The `description` frontmatter in each `SKILL.md` drives automatic skill matching — keep it precise.
