#!/usr/bin/env bash

# Open *.rylo.cc links in the Chrome profile signed in to your @rylo.com account.
#
# Finicky's own `profile` option needs to read Chrome's "Local State" file, which
# device management blocks on Rylo Macs (it then silently opens the wrong profile).
# So Finicky hands rylo.cc links to a tiny wrapper app that lets Chrome pick the
# profile itself via --profile-email.
#
# Usage: ./finicky.sh [you@rylo.com]
# Without an argument the account is taken from git or gcloud, else prompted for.

EMAIL="${1:-$({ git config --global user.email; gcloud auth list --format='value(account)' 2> /dev/null; } | grep -m1 '@rylo\.com$')}"
APP="${FINICKY_APP:-$HOME/.finicky/Rylo Chrome.app}"
CONFIG="${FINICKY_CONFIG:-$HOME/.finicky.js}"

if [[ -z "$EMAIL" && -t 0 ]]; then
    read -r -p "Chrome work account (you@rylo.com, Enter to skip): " EMAIL
fi

if [[ ! "$EMAIL" =~ ^[A-Za-z0-9._%+-]+@rylo\.com$ ]]; then
    echo "Finicky setup skipped: no @rylo.com account found (got '$EMAIL')."
    echo "Re-run with your Chrome work account: ./finicky.sh you@rylo.com"
    exit 0
fi

# `open -n` is required: without it a running Chrome never sees the arguments.
mkdir -p "$(dirname "$APP")"
osacompile -o "$APP" << EOF || exit 1
on open location theURL
	if theURL starts with "http" then
		do shell script "open -n -a 'Google Chrome' --args --profile-email=$EMAIL " & quoted form of theURL
	end if
end open location
EOF

cat > "$CONFIG" << EOF
export default {
  defaultBrowser: "Google Chrome",
  handlers: [
    {
      match: /^https?:\/\/([^\/]+\.)?rylo\.cc([\/:?#]|$)/,
      browser: { name: $(jq -n --arg app "$APP" '$app'), appType: "path" },
    },
  ],
};
EOF

echo "Wrote $CONFIG (rylo.cc links open in the Chrome profile of $EMAIL)."

if [[ -z "${FINICKY_CONFIG:-}" ]]; then
    # Finicky does not reliably notice the rewritten config while running.
    pkill -x Finicky && sleep 1
    open -a Finicky
    echo "If Finicky is not your default browser yet, set it from the Finicky window."
fi
