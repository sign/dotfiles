#!/usr/bin/env bash

ensure_env_key() {
  local key="$1"
  local prompt="$2"
  local env_file="${ENV_FILE:-$HOME/.env}"
  local value quoted

  if [[ -z "${!key:-}" && -f "$env_file" ]]; then
    set -a
    source "$env_file"
    set +a
  fi

  if [[ -n "${!key:-}" ]]; then
    return 0
  fi

  if [[ ! -t 0 ]]; then
    echo "$key is not set; skipping setup." >&2
    return 1
  fi

  echo "$prompt"
  read -r -s -p "$key (Enter to skip): " value
  echo

  if [[ -z "$value" ]]; then
    echo "Skipping setup."
    return 1
  fi

  if [[ "$value" == *$'\n'* || "$value" == *$'\r'* ]]; then
    echo "$key cannot contain newlines; skipping setup." >&2
    return 1
  fi

  export "$key=$value"
  touch "$env_file"
  chmod 600 "$env_file" 2>/dev/null || true
  printf -v quoted '%q' "$value"
  printf 'export %s=%s\n' "$key" "$quoted" >> "$env_file"
  echo "Saved $key to $env_file."
}
