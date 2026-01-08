#!/usr/bin/env bash
set -e

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  # Linux
  curl -fsSL https://claude.ai/install.sh | bash
elif [[ "$OSTYPE" == "darwin"* ]]; then
  # macOS
  brew install --cask claude-code
else
  echo "Unsupported OS: $OSTYPE" >&2
  exit 1
fi

# Basic plugins
echo "/plugin install code-review"
echo "/plugin install commit-commands"
echo "/plugin install security-guidance"


