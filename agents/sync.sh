#!/bin/bash
# Syncs shared agent config into Claude Code: registers MCP servers from
# agents/mcp.json at user scope and merges agents/allowlist.txt into
# ~/.claude/settings.json permissions.allow. Idempotent; safe to re-run.
# Copilot reads both sources directly (symlink and zprofile wrapper).

set -euo pipefail

AGENTS_DIR="$(cd "$(dirname "$0")" && pwd)"
SETTINGS="$HOME/.claude/settings.json"

hash claude 2>/dev/null || { echo "  ⚠ claude not installed, skipping agent sync"; exit 0; }
hash jq 2>/dev/null || { echo "  ⚠ jq not installed, skipping agent sync"; exit 1; }

echo "  Syncing MCP servers to Claude"
while IFS= read -r name; do
	if claude mcp get "$name" >/dev/null 2>&1; then
		echo "  ✓ MCP $name already registered"
	else
		echo "  → Registering MCP $name"
		claude mcp add-json --scope user "$name" \
			"$(jq -c --arg n "$name" '.mcpServers[$n] | del(.tools)' "$AGENTS_DIR/mcp.json")" >/dev/null
	fi
done < <(jq -r '.mcpServers | keys[]' "$AGENTS_DIR/mcp.json")

echo "  Syncing shell allowlist to Claude permissions"
mkdir -p "$(dirname "$SETTINGS")"
[ -f "$SETTINGS" ] || echo '{}' > "$SETTINGS"

rules=$(grep -v -e '^[[:space:]]*#' -e '^[[:space:]]*$' "$AGENTS_DIR/allowlist.txt" \
	| jq -R 'gsub("^\\s+|\\s+$"; "") | "Bash(\(.) *)"' | jq -s .)

tmp=$(mktemp)
jq --argjson rules "$rules" \
	'.permissions.allow = (((.permissions.allow // []) + $rules) | unique)' \
	"$SETTINGS" > "$tmp"

if cmp -s "$tmp" "$SETTINGS"; then
	rm "$tmp"
	echo "  ✓ permissions already up to date"
else
	mv "$tmp" "$SETTINGS"
	echo "  → Updated $SETTINGS ($(echo "$rules" | jq length) allowlist rules)"
fi
