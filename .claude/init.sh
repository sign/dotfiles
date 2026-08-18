#!/usr/bin/env bash
set -e

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/../env.sh"

if ! command -v claude &> /dev/null; then
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
fi

if ! command -v codex &> /dev/null; then
  if [[ "$OSTYPE" == "linux-gnu"* || "$OSTYPE" == "darwin"* ]]; then
    curl -fsSL https://chatgpt.com/codex/install.sh | sh
  else
    echo "Unsupported OS: $OSTYPE" >&2
    exit 1
  fi
fi

# Marketplaces: refresh catalogs (true auto-update is UI-only:
# /plugin -> Marketplaces -> Enable auto-update)
claude plugin marketplace add talknagish/rylo-skills 2>/dev/null || true
claude plugin marketplace add DietrichGebert/ponytail 2>/dev/null || true
claude plugin marketplace add ayghri/i-have-adhd 2>/dev/null || true
claude plugin marketplace update

# Basic plugins: install if missing. Only user-scope plugins are managed here;
# project/local-scope ones can't be updated from this script anyway.
installed_plugins() {
  claude plugin list --json 2>/dev/null | python3 -c 'import json,sys
for p in json.load(sys.stdin):
    if p.get("scope") == "user": print(p["id"])'
}

existing=$(installed_plugins)
for plugin in \
  brand-skills@rylo-skills mobile-skills@rylo-skills finance-skills@rylo-skills \
  regulatory-skills@rylo-skills data-skills@rylo-skills workflow-skills@rylo-skills \
  research-skills@rylo-skills marketing-skills@rylo-skills \
  ponytail@ponytail i-have-adhd@i-have-adhd; do
  if ! grep -q "^${plugin%%@*}@" <<< "$existing"; then
    claude plugin install "$plugin"
  fi
  # install does not enable; enable at user scope. run from $HOME: inside a
  # project dir the CLI resolves scope to the project and rejects --scope user.
  (cd "$HOME" && claude plugin enable "$plugin" --scope user) 2>/dev/null || true
done

# Update all installed plugins (takes effect after Claude Code restart)
installed_plugins | while IFS= read -r plugin; do
  claude plugin update "$plugin" || echo "Could not update $plugin (skipping)" >&2
done

# Codex plugin marketplaces/plugins matching the Claude user plugin set above.
codex plugin marketplace add talknagish/rylo-skills 2>/dev/null || true
codex plugin marketplace add DietrichGebert/ponytail 2>/dev/null || true
codex plugin marketplace add ayghri/i-have-adhd 2>/dev/null || true
codex plugin marketplace upgrade 2>/dev/null || true

for plugin in \
  brand-skills@rylo-skills mobile-skills@rylo-skills finance-skills@rylo-skills \
  regulatory-skills@rylo-skills data-skills@rylo-skills workflow-skills@rylo-skills \
  research-skills@rylo-skills marketing-skills@rylo-skills \
  ponytail@ponytail i-have-adhd@i-have-adhd; do
  codex plugin add "$plugin" >/dev/null || echo "Could not install Codex plugin $plugin (skipping)" >&2
done

# MCP servers (user scope so they apply everywhere, like the plugins above)
claude mcp add --scope user --transport http linear-server https://mcp.linear.app/mcp 2>/dev/null || true
codex mcp add linear-server --url https://mcp.linear.app/mcp 2>/dev/null || true

if ensure_env_key WANDB_API_KEY "WandB MCP setup needs a W&B API key from https://wandb.ai/authorize"; then
  codex mcp add wandb \
    --url https://mcp.withwandb.com/mcp \
    --bearer-token-env-var WANDB_API_KEY

  claude mcp remove --scope user wandb 2>/dev/null || true
  claude mcp add --scope user --transport http wandb https://mcp.withwandb.com/mcp \
    --header "Authorization: Bearer ${WANDB_API_KEY}"
fi

# Skills (installed to ~/.agents/skills, where Codex scans directly; Claude
# Code gets symlinks in ~/.claude/skills).
# Use the skills CLI directly: the modern-web-guidance install wrapper prompts
# interactively. Pin agents so installs cover Claude Code and Codex without
# targeting every known agent, which fails noisily on agents without
# global-install support (e.g. PromptScript).
# The skills CLI is also cwd-sensitive — run from $HOME so installs are global,
# not project-local.
(
  cd "$HOME"
  npx -y skills add GoogleChrome/modern-web-guidance -g -y -a universal -a claude-code -a codex
  npx -y skills add uditgoenka/autoresearch -g -y -a universal -a claude-code -a codex
)
