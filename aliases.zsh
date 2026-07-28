# Better ls
alias ls='eza --icons'

# Detailed listing
alias ll='eza -lh --icons --git'

# Detailed listing including hidden files
alias la='eza -lah --icons --git'

# Tree view
alias tree='eza --tree --icons'

# Reuse ls completions for eza (avoids defining a separate completion function)
compdef eza=ls

# Better cat — Debian/Ubuntu ship bat as `batcat`
if command -v batcat >/dev/null 2>&1; then
  alias cat='batcat'
elif command -v bat >/dev/null 2>&1; then
  alias cat='bat'
fi

# =========================================================
# Core utilities
# =========================================================

alias grep='rg --color=auto'
alias diff='diff --color=auto'
alias df='df -h'

# Debian/Ubuntu ship fd as `fdfind` — alias it back to the upstream name
command -v fdfind >/dev/null 2>&1 && alias fd='fdfind'

# =========================================================
# Navigation
# =========================================================

alias -- -='cd -'  # -- prevents - being parsed as a flag; cd - jumps to previous directory

lf() { # zsh follow lf navigation
    tmp=$(mktemp)
    command lf -last-dir-path="$tmp" "$@"
    if [ -f "$tmp" ]; then
        dir=$(cat "$tmp")
        rm -f "$tmp"
        [ -d "$dir" ] && [ "$dir" != "$(pwd)" ] && cd "$dir"
    fi
}

# =========================================================
# Editor
# =========================================================

alias vim='nvim'

# =========================================================
# Git
# =========================================================

alias glog='PAGER="less -F -X" git log'                              # -F quit if one screen, -X no clear on exit
alias gadog='PAGER="less -F -X" git log --all --decorate --oneline --graph'
# Bare-repo dotfiles. Paths come from .env (see .env.example)
alias dotfiles='git --git-dir=${DOTFILES_GIT_DIR:-$HOME/.dotfiles} --work-tree=${DOTFILES_WORK_TREE:-$HOME}'

# =========================================================
# Video
# =========================================================

# $STREAM_DEVICE is set in .env (see .env.example)
alias stream='mpv av://v4l2:${STREAM_DEVICE:-/dev/video0} --fullscreen --demuxer-lavf-o=input_format=mjpeg,framerate=30 --profile=low-latency --untimed'

# =========================================================
# Work: Cloudflare D1 (wrangler)
# =========================================================
# $WRANGLER_D1_DATABASE is set in .env (see .env.example)

dbl() {
    npx wrangler d1 execute "${WRANGLER_D1_DATABASE:?set WRANGLER_D1_DATABASE in $ZDOTDIR/.env}" --local --command="$1"
}

dbTables() {
    npx wrangler d1 execute "${WRANGLER_D1_DATABASE:?set WRANGLER_D1_DATABASE in $ZDOTDIR/.env}" --"$1" --command="SELECT name FROM sqlite_schema WHERE type = 'table' AND name NOT LIKE 'sqlite_%';"
}

dbSchema() {
    npx wrangler d1 execute "${WRANGLER_D1_DATABASE:?set WRANGLER_D1_DATABASE in $ZDOTDIR/.env}" --"$1" --command="PRAGMA table_info($2);"
}

# =========================================================
# Remote host shortcut
# =========================================================
# $EDCORE_SSH_KEY / $EDCORE_SSH_HOST are set in .env (see .env.example)

edcore() {
    ssh -i "${EDCORE_SSH_KEY:?set EDCORE_SSH_KEY in $ZDOTDIR/.env}" \
        "${EDCORE_SSH_HOST:?set EDCORE_SSH_HOST in $ZDOTDIR/.env}"
}
