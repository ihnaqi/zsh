# zsh

A modular, XDG-compliant zsh configuration: starship prompt, vi mode, fuzzy
finding everywhere, and an always-on tmux session.

Everything lives in `$ZDOTDIR` (`~/.config/zsh`) — nothing is dropped in `$HOME`
except the one-line bootstrap described below.

Based on [radleylewis/zsh](https://github.com/radleylewis/zsh).

---

## Table of contents

- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Machine-local settings (`.env`)](#machine-local-settings-env)
- [Layout](#layout)
- [What you get](#what-you-get)
- [Keybindings](#keybindings)
- [tmux + Ghostty model](#tmux--ghostty-model)
- [Maintenance](#maintenance)
- [Troubleshooting](#troubleshooting)

---

## Prerequisites

**zsh 5.8+** is required (5.9 recommended — `${HISTFILE:h}` modifiers and
`zsh-vi-mode` both rely on a modern zsh).

### Required

Without these you get errors or a badly degraded shell:

| Tool | Purpose |
| --- | --- |
| `zsh` | the shell itself |
| `git` | plugin installation (`plugins.zsh` clones on first run) |
| [`starship`](https://starship.rs) | prompt |
| [`zoxide`](https://github.com/ajeetdsouza/zoxide) | smart `cd` |
| [`fzf`](https://github.com/junegunn/fzf) | fuzzy finder |
| [`fd`](https://github.com/sharkdp/fd) | file search backing fzf |
| [`bat`](https://github.com/sharkdp/bat) | fzf previews, `cat`, man pager |
| [`eza`](https://github.com/eza-community/eza) | `ls` / `ll` / `la` / `tree` |
| [`ripgrep`](https://github.com/BurntSushi/ripgrep) | `grep` |
| `tmux` | auto-launched session (see below) |

> **Debian/Ubuntu naming:** `fd` is installed as `fdfind` and `bat` as `batcat`.
> The config detects both, so you do **not** need to create symlinks.

### Optional

Only needed for specific features; everything is guarded, so missing tools are
silently skipped:

| Tool | Enables |
| --- | --- |
| [`neovim`](https://neovim.io) | `$EDITOR` / `$VISUAL`, the `vim` alias |
| [`nvm`](https://github.com/nvm-sh/nvm) | Node version management |
| [`rustup`](https://rustup.rs) | sources `~/.cargo/env` |
| [`lf`](https://github.com/gokcehan/lf) | the `lf` directory-following wrapper |
| `mpv` + `v4l-utils` | the `stream` webcam alias |
| [Ghostty](https://ghostty.org) | the single-instance terminal model |
| `node` / `npx` + `wrangler` | the `dbl` / `dbTables` / `dbSchema` helpers |

### A Nerd Font

The prompt, `eza --icons` and the fzf prompt glyphs all use
[Nerd Font](https://www.nerdfonts.com) symbols. Install one (JetBrainsMono
Nerd Font, FiraCode Nerd Font, …) and set it as your terminal font, or you will
see tofu boxes.

### Install commands

<details>
<summary><b>Ubuntu / Debian</b></summary>

```sh
sudo apt update
sudo apt install -y zsh git tmux fzf fd-find bat ripgrep eza

# starship + zoxide are not in older repos — install upstream
curl -sS https://starship.rs/install.sh | sh
curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh

# optional
sudo apt install -y neovim mpv v4l-utils
```

`eza` is only packaged from Ubuntu 24.04 / Debian 13 onwards. On older
releases grab a binary from the
[eza releases page](https://github.com/eza-community/eza/releases).

</details>

<details>
<summary><b>Arch</b></summary>

```sh
sudo pacman -S zsh git tmux fzf fd bat ripgrep eza starship zoxide
sudo pacman -S neovim mpv lf   # optional
```

</details>

<details>
<summary><b>Fedora</b></summary>

```sh
sudo dnf install -y zsh git tmux fzf fd-find bat ripgrep eza zoxide
curl -sS https://starship.rs/install.sh | sh
```

</details>

<details>
<summary><b>macOS (Homebrew)</b></summary>

```sh
brew install zsh git tmux fzf fd bat ripgrep eza starship zoxide
brew install neovim lf mpv   # optional
$(brew --prefix)/opt/fzf/install --key-bindings --completion --no-update-rc
```

</details>

Plugins are **not** a prerequisite — `plugins.zsh` clones them into
`plugins/` automatically the first time you open a shell.

---

## Installation

**1. Clone into `~/.config/zsh`**

```sh
git clone <this-repo> "${XDG_CONFIG_HOME:-$HOME/.config}/zsh"
```

**2. Point zsh at it**

Debian and Ubuntu's `/etc/zsh/zshenv` already exports
`ZDOTDIR="$XDG_CONFIG_HOME/zsh"` when that directory exists — nothing to do.

On any other system, create `~/.zshenv` with a single line:

```sh
echo 'export ZDOTDIR="${XDG_CONFIG_HOME:-$HOME/.config}/zsh"' > ~/.zshenv
```

This is the *only* file this config puts in `$HOME`.

**3. Create your `.env`**

```sh
cp ~/.config/zsh/.env.example ~/.config/zsh/.env
$EDITOR ~/.config/zsh/.env
```

See [Machine-local settings](#machine-local-settings-env). Skipping this step
is fine — every consumer has a fallback.

**4. Make zsh your login shell**

```sh
chsh -s "$(command -v zsh)"
```

Log out and back in for it to take effect.

**5. Open a new terminal**

The first launch clones the four plugins (a few seconds), builds the
completion cache, and drops you into a tmux session. Subsequent launches are
instant.

---

## Machine-local settings (`.env`)

Personal paths, hostnames and key locations are kept out of the tracked files
and live in `.env`, which is **gitignored**. `.env.example` is the committed
template — copy it and edit.

It is sourced by `.zshenv` as a zsh script, so it takes `export KEY="value"`
lines and `$HOME` expands normally.

| Variable | Used by | Default if unset |
| --- | --- | --- |
| `OPENCODE_BIN` | `.zshrc` — prepends to `$PATH` | not added to `$PATH` |
| `DOTFILES_GIT_DIR` | `dotfiles` alias | `$HOME/.dotfiles` |
| `DOTFILES_WORK_TREE` | `dotfiles` alias | `$HOME` |
| `WRANGLER_D1_DATABASE` | `dbl`, `dbTables`, `dbSchema` | error prompting you to set it |
| `EDCORE_SSH_KEY` | `edcore` | error prompting you to set it |
| `EDCORE_SSH_HOST` | `edcore` | error prompting you to set it |
| `STREAM_DEVICE` | `stream` alias | `/dev/video0` |

> **Note:** `.env` holds *file paths and hostnames*, not secrets. Keep actual
> private keys in `~/.ssh` with `600` permissions and API tokens in your
> system keyring or a secret manager — never in this file, gitignored or not.

Adding a new machine-local value:

1. Add it with a placeholder to `.env.example` (this file is committed).
2. Add the real value to `.env`.
3. Reference it with a fallback — `${MY_VAR:-default}` — or with
   `${MY_VAR:?message}` if there is no sensible default.

---

## Layout

```
~/.config/zsh/
├── .zshenv                 # env vars; sourced by EVERY zsh (incl. scripts)
├── .zshrc                  # interactive shell setup; sources the modules below
├── .env                    # your machine-local values (gitignored)
├── .env.example            # template for .env (committed)
├── aliases.zsh             # aliases + small shell functions
├── bindings.zsh            # keybindings (registered via zvm_after_init)
├── fzf.zsh                 # fzf commands, UI and the Ctrl+F picker
├── plugins.zsh             # minimal git-clone plugin manager
├── prompt.zsh              # starship init
├── starship.toml           # prompt theme
├── tmux.zsh                # tmux auto-launch + tmux-new-window
├── ghostty-new-window.sh   # GNOME Ctrl+Alt+T handler
└── plugins/                # cloned on first run (gitignored)
```

### Load order

`.zshenv` → `.zprofile` (unused) → `.zshrc` → the modules, in this order:
`fzf.zsh`, `aliases.zsh`, `bindings.zsh`, `plugins.zsh`, `prompt.zsh`,
`tmux.zsh`.

`bindings.zsh` is sourced *before* `plugins.zsh` on purpose: it only defines
the `zvm_after_init` hook, which `zsh-vi-mode` calls once it has finished
resetting the keymap.

### Files written outside this directory

| Path | Contents |
| --- | --- |
| `$XDG_STATE_HOME/zsh/history` | command history (100k entries, shared across sessions) |
| `$XDG_CACHE_HOME/zsh/zcompdump` | completion cache |

Both directories are created automatically on first run.

---

## What you get

**Plugins** (auto-installed by `plugins.zsh`)

- [`zsh-autosuggestions`](https://github.com/zsh-users/zsh-autosuggestions) — inline history suggestions
- [`zsh-history-substring-search`](https://github.com/zsh-users/zsh-history-substring-search) — Up/Down searches by substring
- [`zsh-vi-mode`](https://github.com/jeffreytse/zsh-vi-mode) — vi editing with per-mode cursor shapes
- [`fast-syntax-highlighting`](https://github.com/zdharma-continuum/fast-syntax-highlighting) — as-you-type highlighting

**Shell options** — `AUTOCD` (type a directory name to enter it), `NOBEEP`,
`NUMERIC_GLOB_SORT`, shared history with dedup, and
`HIST_IGNORE_SPACE` (a leading space keeps a command out of history).

**Completion** — case-insensitive, with an interactive menu.

**Aliases**

| Alias | Runs |
| --- | --- |
| `ls` / `ll` / `la` / `tree` | `eza` variants with icons and git status |
| `cat` | `bat` |
| `grep` | `rg --color=auto` |
| `fd` | `fdfind` (Debian/Ubuntu only) |
| `vim` | `nvim` |
| `-` | `cd -` |
| `glog` / `gadog` | `git log`, plain and as a decorated graph |
| `dotfiles` | `git` against a bare dotfiles repo |
| `stream` | `mpv` on `$STREAM_DEVICE` |

**Functions**

| Function | Does |
| --- | --- |
| `lf` | runs `lf`, then `cd`s to wherever you left off |
| `tmux-new-window` | new tmux window in the running session |
| `zplugin-update` | `git pull` every plugin |
| `dbl` / `dbTables` / `dbSchema` | Cloudflare D1 queries via `wrangler` |
| `edcore` | ssh to `$EDCORE_SSH_HOST` with `$EDCORE_SSH_KEY` |

---

## Keybindings

Custom bindings live in `zvm_after_init` because `zsh-vi-mode` clears the
keymap when it initialises — anything bound outside that hook is lost.

| Key | Action |
| --- | --- |
| `Ctrl+Right` / `Ctrl+Left` | move forward / backward one word |
| `Up` / `Down` | history search by substring |
| `Ctrl+F` | fzf file picker (hidden files excluded), inserts at cursor |
| `Ctrl+T` | fzf file picker (hidden files included) — from fzf itself |
| `Ctrl+R` | fuzzy history search — from fzf itself |
| `Alt+C` | fuzzy `cd` — from fzf itself |
| `Ctrl+\` | toggle autosuggestions |
| `Esc` | enter vi normal mode |

---

## tmux + Ghostty model

`tmux.zsh` enforces a deliberate "one terminal, many tmux windows" setup:

1. Only one Ghostty process ever runs.
2. Ghostty always boots straight into tmux — reattaching to a detached session
   if one exists, otherwise creating a new one.
3. `Ctrl+Alt+T` adds a tmux **window** to that session instead of opening a
   second terminal.

Auto-launch is skipped when already inside tmux, in a non-interactive shell,
or in an editor's integrated terminal (VS Code, Emacs).

Rules 1 and 3 need config **outside** zsh, since the window manager intercepts
`Ctrl+Alt+T` before any shell runs:

```sh
# ~/.config/ghostty/config.ghostty
gtk-single-instance = true
```

```sh
# GNOME: disable the built-in terminal key, bind ours instead
gsettings set org.gnome.settings-daemon.plugins.media-keys terminal "[]"
# then add a custom shortcut for <Primary><Alt>t running:
#   ~/.config/zsh/ghostty-new-window.sh
```

To revert:

```sh
gsettings reset org.gnome.settings-daemon.plugins.media-keys terminal
gsettings set   org.gnome.settings-daemon.plugins.media-keys custom-keybindings "@as []"
```

**Don't want tmux at all?** Comment out the `source "$ZDOTDIR/tmux.zsh"` line
in `.zshrc`.

---

## Maintenance

```sh
zplugin-update          # git pull every plugin

# rebuild the completion cache after installing new tools
rm -f "$XDG_CACHE_HOME/zsh/zcompdump" && exec zsh

exec zsh                # reload the shell after editing config
```

---

## Troubleshooting

**Boxes/question marks instead of icons** — your terminal font is not a Nerd
Font. See [prerequisites](#a-nerd-font).

**`command not found: fd` / `bat`** — on Debian/Ubuntu these are `fdfind` and
`batcat`; the config handles both. If you installed them from a tarball,
make sure the binary is on `$PATH`.

**Config isn't loading at all** — `ZDOTDIR` is not set. Check with
`echo $ZDOTDIR`; if empty, do step 2 of [Installation](#installation).

**Plugins didn't install** — check `git` is installed and you have network
access, then `rm -rf ~/.config/zsh/plugins && exec zsh`.

**`Ctrl+F` / arrow keys do nothing** — `zsh-vi-mode` failed to load, so
`zvm_after_init` never fired. Look for clone errors from `plugins.zsh`.

**Terminal opens without tmux** — either tmux isn't installed, or you're in an
editor's integrated terminal, where auto-launch is skipped by design.

**History isn't saved** — `$XDG_STATE_HOME/zsh` must be writable. `.zshrc`
creates it, but check permissions if it exists and is owned by root.
