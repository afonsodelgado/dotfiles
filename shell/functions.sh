# Sourced by both bash and zsh. tmux layouts adapted from Omarchy's default/bash/fns/tmux.

# Tmux Dev Layout: editor on the left, a command (e.g. claude) on the right, terminal below.
# Usage: tdl <command> [<second_command>]
tdl() {
  [[ -z $1 ]] && { echo "Usage: tdl <command> [<second_command>]"; return 1; }
  [[ -z $TMUX ]] && { echo "You must start tmux to use tdl."; return 1; }

  local current_dir="${PWD}"
  local editor_pane ai_pane ai2_pane
  local ai="$1"
  local ai2="$2"

  editor_pane="$TMUX_PANE"
  tmux rename-window -t "$editor_pane" "$(basename "$current_dir")"

  # Terminal strip along the bottom (15%), then the command pane on the right (30%).
  tmux split-window -v -p 15 -t "$editor_pane" -c "$current_dir"
  ai_pane=$(tmux split-window -h -p 30 -t "$editor_pane" -c "$current_dir" -P -F '#{pane_id}')

  if [[ -n $ai2 ]]; then
    ai2_pane=$(tmux split-window -v -t "$ai_pane" -c "$current_dir" -P -F '#{pane_id}')
    tmux send-keys -t "$ai2_pane" "$ai2" C-m
  fi

  tmux send-keys -t "$ai_pane" "$ai" C-m
  tmux send-keys -t "$editor_pane" "$EDITOR ." C-m
  tmux select-pane -t "$editor_pane"
}

# Swarm layout: the same command started in N tiled panes.
# Usage: tsl <pane_count> <command>
tsl() {
  [[ -z $1 || -z $2 ]] && { echo "Usage: tsl <pane_count> <command>"; return 1; }
  [[ -z $TMUX ]] && { echo "You must start tmux to use tsl."; return 1; }

  local count="$1"
  local cmd="$2"
  local current_dir="${PWD}"
  local -a panes

  local first_pane="$TMUX_PANE"
  tmux rename-window -t "$first_pane" "$(basename "$current_dir")"
  panes+=("$first_pane")

  while (( ${#panes[@]} < count )); do
    local new_pane
    new_pane=$(tmux split-window -h -t "${panes[-1]}" -c "$current_dir" -P -F '#{pane_id}')
    panes+=("$new_pane")
    tmux select-layout -t "$first_pane" tiled
  done

  local pane
  for pane in "${panes[@]}"; do
    tmux send-keys -t "$pane" "$cmd" C-m
  done
  tmux select-pane -t "$first_pane"
}
