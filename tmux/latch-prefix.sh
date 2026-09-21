#!/bin/sh
# Re-enter the prefix table after every prefix binding, which is what makes the
# prefix latch rather than fire once and drop back to typing.
#
# Commands in SKIP hand the keyboard to something else (a prompt, copy mode, a
# chooser, a popup). Re-latching those would leave the client in the prefix
# table while that thing owns the input, so they stay one-shot.
set -eu

SKIP='command-prompt|copy-mode|choose-tree|choose-client|choose-buffer|confirm-before|display-menu|display-popup|display-panes|customize-mode|clock-mode|detach-client|suspend-client|list-keys|show-messages'

# tmux needs a literal "\;" to chain the re-entry onto the bound command. The
# escape that emits one differs between BSD and GNU sed, so carry it in a
# variable that printf %s passes through untouched.
BACKSLASH='\'

generated=$(mktemp)
trap 'rm -f "$generated"' EXIT

# Dropping the bindings that already switch table keeps a config reload from
# stacking a second re-entry onto every key.
tmux list-keys -T prefix \
  | grep -vE 'switch-client -T ' \
  | grep -vE "[[:space:]](${SKIP})([[:space:]]|\$)" \
  | while IFS= read -r binding; do
      printf '%s %s; switch-client -T prefix\n' "$binding" "$BACKSLASH"
    done > "$generated"

tmux source-file "$generated"
