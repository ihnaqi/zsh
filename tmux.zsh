# =========================================================
# tmux auto-launch  —  single-Ghostty model
# =========================================================
# Goals (the new rules):
#   1. There is only ever ONE Ghostty instance. We never want a second
#      Ghostty window/process spawned.
#   2. Ghostty ALWAYS boots directly into a tmux session.
#   3. Pressing Ctrl+Alt+T must NOT open another Ghostty. Instead it
#      creates a new tmux *window* inside the already-running Ghostty's
#      existing session and switches to it. (We already have one session
#      per Ghostty — there's no reason to spawn another session.)
#
# How the pieces fit together:
#   - This file (zsh) handles rule #2: when the single Ghostty shell
#     starts, it attaches to / creates the tmux session.
#   - It also defines `tmux-new-window`, the helper that implements
#     rule #3 (new window in the running Ghostty's session).
#   - Rules #1 and #3 also need config OUTSIDE the shell, because zsh
#     cannot stop the OS/window-manager from launching a new window.
#     See the "REQUIRED non-shell config" notes at the bottom.

# ---------------------------------------------------------
# Rule #2: boot the single Ghostty straight into tmux.
# ---------------------------------------------------------
# Only auto-launch tmux when ALL of these are true:
#   - tmux is installed
#   - we are NOT already inside a tmux session ($TMUX is empty)
#   - this is an interactive shell ($- contains "i")
#   - stdout is attached to a real terminal
#   - we are not inside an editor/IDE integrated terminal (VS Code, etc.)
if command -v tmux >/dev/null 2>&1 \
  && [[ -z "$TMUX" ]] \
  && [[ $- == *i* ]] \
  && [[ -t 1 ]] \
  && [[ "$TERM_PROGRAM" != "vscode" ]] \
  && [[ -z "$VSCODE_INJECTION" ]] \
  && [[ -z "$INSIDE_EMACS" ]]; then

  # Prefer reattaching to an existing detached session (e.g. one left
  # behind after the single Ghostty was closed) before making a new one.
  # `session_attached` is the number of attached clients; 0 == detached.
  detached_session="$(
    tmux list-sessions -F '#{session_attached} #{session_name}' 2>/dev/null \
      | awk '$1 == 0 { print $2; exit }'
  )"

  if [[ -n "$detached_session" ]]; then
    # `exec` so quitting tmux quits the shell (and the Ghostty window).
    exec tmux attach-session -t "$detached_session"
  else
    # Nothing to reuse — create the first session. tmux auto-numbers it.
    exec tmux new-session
  fi
fi

# ---------------------------------------------------------
# Rule #3: new tmux WINDOW inside the running Ghostty's session.
# ---------------------------------------------------------
# Bind Ctrl+Alt+T to call THIS instead of spawning a new terminal.
# We already have one session per Ghostty, so this just adds a window to
# it. Works both from inside tmux and from an external trigger (it
# targets the one attached client's current session).
tmux-new-window() {
  if ! command -v tmux >/dev/null 2>&1; then
    return 1
  fi

  if [[ -n "$TMUX" ]]; then
    # Inside tmux: add a window to the current session and select it.
    tmux new-window
  elif tmux has-session 2>/dev/null; then
    # Outside tmux but tmux is running (the single Ghostty is up): add a
    # window to the attached client's session. new-window selects it, so
    # the live Ghostty client jumps to the new window automatically.
    local client
    client="$(tmux list-clients -F '#{client_name}' 2>/dev/null | head -n1)"
    if [[ -n "$client" ]]; then
      tmux new-window -t "$client"
    else
      tmux new-window
    fi
  else
    # No Ghostty/tmux running at all — start the single instance, which
    # boots into tmux via rule #2 above.
    command -v ghostty >/dev/null 2>&1 && ghostty >/dev/null 2>&1 &!
  fi
}

# =========================================================
# REQUIRED non-shell config (zsh can't do these on its own) — DONE
# =========================================================
# These live OUTSIDE zsh because GNOME intercepts Ctrl+Alt+T before any
# shell runs. They are already configured on this machine:
#
# Rule #1 (single Ghostty instance):
#   - ~/.config/ghostty/config.ghostty has:  gtk-single-instance = true
#   - the launcher also passes --gtk-single-instance=true
#
# Rule #3 (Ctrl+Alt+T = new tmux window, not new Ghostty window):
#   GNOME's built-in "open terminal" key was the culprit. It is remapped:
#     - org.gnome.settings-daemon.plugins.media-keys terminal -> [] (off)
#     - a custom shortcut binds <Primary><Alt>t to:
#         ~/.config/zsh/ghostty-new-window.sh
#   That script adds a window to the running Ghostty's tmux session (or
#   launches Ghostty if none is running). See that file for details.
#
# To revert the GNOME remap:
#   gsettings reset org.gnome.settings-daemon.plugins.media-keys terminal
#   gsettings set   org.gnome.settings-daemon.plugins.media-keys \
#                   custom-keybindings "@as []"
#
# The `tmux-new-window` function above is the in-shell equivalent, handy
# if you ever want to trigger the same behaviour from a tmux/zsh binding.
