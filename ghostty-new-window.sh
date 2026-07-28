#!/usr/bin/env bash
# =========================================================
# Ctrl+Alt+T handler  —  single-Ghostty / tmux model
# =========================================================
# Bound to <Primary><Alt>t as a GNOME custom keyboard shortcut so it runs
# INSTEAD of GNOME's built-in "open a terminal" action.
#
# Behaviour:
#   - If the single Ghostty is already running (tmux server up): add a new
#     WINDOW to the session the live Ghostty client is showing, and select
#     it (so focus switches to the new window). No new Ghostty window.
#   - If nothing is running: launch the one Ghostty, which boots into tmux
#     via tmux.zsh.

if command -v tmux >/dev/null 2>&1 && tmux has-session 2>/dev/null; then
  # Session that the currently-attached Ghostty client is viewing.
  session="$(tmux list-clients -F '#{client_session}' 2>/dev/null | head -n1)"
  if [ -n "$session" ]; then
    # new-window selects the window by default -> the attached Ghostty
    # client jumps focus to it automatically.
    tmux new-window -t "${session}:"
  else
    tmux new-window
  fi
else
  # No Ghostty/tmux yet — start the single instance (detached from this
  # short-lived shortcut process so it keeps running).
  setsid ghostty >/dev/null 2>&1 &
fi
