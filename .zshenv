# ~/.config/zsh/.zshenv

# ---------- XDG base directories ----------
# Centralizes config/cache/data locations
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

# ---------- ZDOTDIR fallback ----------
# Debian/Ubuntu's /etc/zsh/zshenv sets this when ~/.config/zsh exists.
# Set it explicitly so the config also works on distros that don't.
export ZDOTDIR="${ZDOTDIR:-$XDG_CONFIG_HOME/zsh}"

# ---------- Machine-local settings ----------
# Personal paths, hostnames and key locations live in .env (gitignored).
# See .env.example for the template. Everything below has a fallback, so
# a missing .env is not fatal.
[[ -f "$ZDOTDIR/.env" ]] && source "$ZDOTDIR/.env"

# ---------- Editor ----------
# Default editor used by git, crontab, etc.
export EDITOR="nvim"
export VISUAL="nvim"

# ---------- Pager ----------
if command -v bat >/dev/null 2>&1; then
  export MANPAGER="bat -l man -p"
elif command -v batcat >/dev/null 2>&1; then
  export MANPAGER="batcat -l man -p"
fi

# ---------- GPG ----------
export GPG_TTY=$(tty)

# ---------- Starship ----------
export STARSHIP_CONFIG="$ZDOTDIR/starship.toml"

# ---------- PATH ----------
# Personal binaries/scripts
export PATH="$HOME/.local/bin:$PATH"

# Rust toolchain (only if rustup/cargo is installed)
[[ -f "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"
