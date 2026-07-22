#!/usr/bin/env bash
set -e

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

# Skills (installed to ~/.agents/skills, symlinked into ~/.claude/skills).
# Use the skills CLI directly: the modern-web-guidance install wrapper prompts
# interactively. Pin agents because bare -y targets every known agent and
# fails noisily on agents without global-install support (e.g. PromptScript).
# The skills CLI is also cwd-sensitive — run from $HOME so installs are global,
# not project-local.
(
  cd "$HOME"
  npx -y skills add GoogleChrome/modern-web-guidance -g -y -a universal -a claude-code
  npx -y skills add uditgoenka/autoresearch -g -y -a universal -a claude-code
)
