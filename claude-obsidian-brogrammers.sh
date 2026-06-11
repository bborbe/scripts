#!/usr/bin/env bash
# Launch Claude in the Brogrammers Obsidian vault (Seibert context).
#
# Override paths via env (set in ~/.zshrc / direnv per machine):
#   OBSIDIAN_BROGRAMMERS — Brogrammers vault (default: $HOME/Documents/Obsidian/Brogrammers)
#   OBSIDIAN_ROOT        — Obsidian parent for --add-dir
#   WORKSPACES_ROOT      — Code workspaces parent for --add-dir

set -euo pipefail

ulimit -n 8000

export DISABLE_AUTOUPDATER=1
export CLAUDE_CODE_DISABLE_AUTO_MEMORY=1
export MCP_REMOTE_CONFIG_DIR="$HOME/.mcp-seibert"
export ANTHROPIC_MODEL="claude-opus-4-7"

OBSIDIAN_BROGRAMMERS="${OBSIDIAN_BROGRAMMERS:-$HOME/Documents/Obsidian/Brogrammers}"
OBSIDIAN_ROOT="${OBSIDIAN_ROOT:-$HOME/Documents/Obsidian}"
WORKSPACES_ROOT="${WORKSPACES_ROOT:-$HOME/Documents/workspaces}"

cd "$OBSIDIAN_BROGRAMMERS" || exit 1

claude \
--model "${ANTHROPIC_MODEL}" \
--effort high \
--permission-mode auto \
--mcp-config ~/.claude/mcp-seibert.json \
--strict-mcp-config \
--add-dir "$OBSIDIAN_ROOT" \
--add-dir "$WORKSPACES_ROOT" \
--add-dir ~/.claude/prompts \
--add-dir /tmp \
"$@"
