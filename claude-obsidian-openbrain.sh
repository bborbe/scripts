#!/usr/bin/env bash
# Launch Claude in the OpenBrain Obsidian vault (Seibert context),
# routed through claude-code-router on 127.0.0.1:8788. The router
# decides per-request which backend to forward to based on the `model`
# field — defaults to claude-opus-4-7 (subscription); switch
# mid-session with `/model <name>`. See
# github.com/bborbe/claude-code-router for config + provider list.
#
# Override paths via env (set in ~/.zshrc / direnv per machine):
#   OBSIDIAN_OPENBRAIN — OpenBrain vault (default: $HOME/Documents/Obsidian/OpenBrain)
#   OBSIDIAN_ROOT        — Obsidian parent for --add-dir
#   WORKSPACES_ROOT      — Code workspaces parent for --add-dir
#   CLAUDE_CODE_ROUTER_URL — router URL (default: http://127.0.0.1:8788)

set -euo pipefail

ulimit -n 8000

export DISABLE_AUTOUPDATER=1
export CLAUDE_CODE_DISABLE_AUTO_MEMORY=1
export MCP_REMOTE_CONFIG_DIR="$HOME/.mcp-openbrain"
export ANTHROPIC_BASE_URL="${CLAUDE_CODE_ROUTER_URL:-http://127.0.0.1:8788}"
export ANTHROPIC_MODEL="claude-opus-4-8"
export EFFORT_LEVEL="medium" #  low, medium, high, xhigh, max

OBSIDIAN_OPENBRAIN="${OBSIDIAN_OPENBRAIN:-$HOME/Documents/Obsidian/OpenBrain}"
OBSIDIAN_ROOT="${OBSIDIAN_ROOT:-$HOME/Documents/Obsidian}"
WORKSPACES_ROOT="${WORKSPACES_ROOT:-$HOME/Documents/workspaces}"

cd "$OBSIDIAN_OPENBRAIN" || exit 1

claude \
--model "${ANTHROPIC_MODEL}" \
--effort "${EFFORT_LEVEL}" \
--permission-mode auto \
--mcp-config ~/.claude/mcp-obsidian-openbrain.json \
--strict-mcp-config \
--add-dir "$OBSIDIAN_ROOT" \
--add-dir "$WORKSPACES_ROOT" \
--add-dir ~/.claude/prompts \
--add-dir /tmp \
"$@"
