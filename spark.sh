# BEGIN spark tmux utilities
_spark_ssh_loop_cmd() {
  local target="$1"
  printf 'while true; do ssh %q; echo "%s disconnected; reconnecting in 3s..."; sleep 3; done' "$target" "$target"
}

_spark_attach_or_switch() {
  local session="$1"
  if [[ -n "${TMUX:-}" ]]; then
    tmux switch-client -t "$session"
  else
    tmux attach -t "$session"
  fi
}

_spark_open_grid() {
  local session="$1"
  shift
  local hosts=("$@")

  if tmux has-session -t "$session" 2>/dev/null; then
    _spark_attach_or_switch "$session"
    return
  fi

  tmux new-session -d -s "$session"

  # Create 4 side-by-side panes.
  tmux split-window -h -t "$session":0
  tmux split-window -h -t "$session":0
  tmux split-window -h -t "$session":0
  tmux select-layout -t "$session":0 even-horizontal

  # Start reconnecting SSH loops in visual order.
  tmux send-keys -t "$session":0.0 "$(_spark_ssh_loop_cmd "${hosts[1]}")" C-m
  tmux send-keys -t "$session":0.1 "$(_spark_ssh_loop_cmd "${hosts[2]}")" C-m
  tmux send-keys -t "$session":0.2 "$(_spark_ssh_loop_cmd "${hosts[3]}")" C-m
  tmux send-keys -t "$session":0.3 "$(_spark_ssh_loop_cmd "${hosts[4]}")" C-m

  tmux set-window-option -t "$session":0 synchronize-panes on

  _spark_attach_or_switch "$session"
}

spark() {
  local session="${1:-spark}"
  _spark_open_grid "$session" \
    spark-1 \
    spark-2 \
    spark-3 \
    spark-4
}

spark-admin() {
  local session="${1:-spark-admin}"
  _spark_open_grid "$session" \
    dgx1@spark-1 \
    dgx2@spark-2 \
    dgx3@spark-3 \
    dgx4@spark-4
}
# END spark tmux utilities
