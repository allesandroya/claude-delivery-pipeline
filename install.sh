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
echo "NOTE: 'autopilot' also needs the 'superpowers' plugin (writing-plans, executing-plans)."
echo "      See https://github.com/obra/superpowers"
