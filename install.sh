#!/usr/bin/env bash
# Installs the delivery-pipeline skills into your Claude Code skills directory.
# Usage:  ./install.sh
set -euo pipefail

dest="${HOME}/.claude/skills"
src="$(cd "$(dirname "$0")" && pwd)/skills"

mkdir -p "$dest"

for skill in "$src"/*/; do
    name="$(basename "$skill")"
    rm -rf "${dest:?}/${name}"
    cp -R "$skill" "${dest}/${name}"
    echo "installed: ${name}"
done

echo
echo "Done. Restart Claude Code to load the skills."
echo

# autopilot depends on the 'superpowers' plugin (writing-plans, executing-plans).
# It's a Claude Code plugin, installed via slash commands inside Claude Code —
# a shell script can't install it, so we detect it and print the commands if missing.
if [ -d "${HOME}/.claude/plugins" ] && \
   find "${HOME}/.claude/plugins" -maxdepth 5 -iname 'superpowers*' -print -quit 2>/dev/null | grep -q .; then
    echo "✓ superpowers plugin detected — autopilot's full chain is ready."
else
    echo "⚠ superpowers plugin NOT detected. 'autopilot' needs it for the"
    echo "  writing-plans and executing-plans phases. Install it from inside Claude Code:"
    echo "    /plugin marketplace add obra/superpowers-marketplace"
    echo "    /plugin install superpowers@superpowers-marketplace"
fi
