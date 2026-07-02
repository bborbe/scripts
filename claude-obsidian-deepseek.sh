#!/usr/bin/env bash
# Launch Claude in the Personal Obsidian vault, routed through
# claude-code-router on 127.0.0.1:8788, with deepseek-v4-flash[1m] as
# the default model. The router forwards `deepseek-*` requests to
# vllm.seibert.tools with the provider token swapped in at the router
# (see ~/.claude-code-router/config.yaml); switch mid-session with
# `/model <name>`. See github.com/bborbe/claude-code-router.
#
# Override paths via env (set in ~/.zshrc / direnv per machine):
#   OBSIDIAN_PERSONAL  — Personal vault (default: $HOME/Documents/Obsidian/Personal)
#   OBSIDIAN_ROOT      — Obsidian parent for --add-dir
#   WORKSPACES_ROOT    — Code workspaces parent for --add-dir
#   CLAUDE_CODE_ROUTER_URL — router URL (default: http://127.0.0.1:8788)

set -euo pipefail

ulimit -n 8000

export DISABLE_AUTOUPDATER=1
export CLAUDE_CODE_DISABLE_AUTO_MEMORY=1
export MCP_REMOTE_CONFIG_DIR="$HOME/.mcp-personal"
export ANTHROPIC_BASE_URL="${CLAUDE_CODE_ROUTER_URL:-http://127.0.0.1:8788}"
#export ANTHROPIC_MODEL="deepseek-v4-pro-fast[1m]" # Non-Think
#export ANTHROPIC_MODEL="deepseek-v4-pro[1m]" # Think Normal
export ANTHROPIC_MODEL="deepseek-v4-pro-max[1m]" # Think Max
# Pin subagent tiers (opus/sonnet/haiku) to the same backend so the
# whole session stays on DeepSeek even when Claude Code dispatches a
# subagent by tier name. Otherwise `haiku` would route to
# anthropic-subscription via the router's "haiku" → claude-* mapping.
export ANTHROPIC_DEFAULT_OPUS_MODEL="${ANTHROPIC_MODEL}"
export ANTHROPIC_DEFAULT_SONNET_MODEL="${ANTHROPIC_MODEL}"
export ANTHROPIC_DEFAULT_HAIKU_MODEL="${ANTHROPIC_MODEL}"
export EFFORT_LEVEL="high" #  low, medium, high, xhigh, max

OBSIDIAN_PERSONAL="${OBSIDIAN_PERSONAL:-$HOME/Documents/Obsidian/Personal}"
OBSIDIAN_ROOT="${OBSIDIAN_ROOT:-$HOME/Documents/Obsidian}"
WORKSPACES_ROOT="${WORKSPACES_ROOT:-$HOME/Documents/workspaces}"

cd "$OBSIDIAN_PERSONAL" || exit 1

claude \
--model "${ANTHROPIC_MODEL}" \
--effort "${EFFORT_LEVEL}" \
--permission-mode acceptEdits \
--mcp-config ~/.claude/mcp-obsidian-personal.json \
--strict-mcp-config \
--add-dir "$OBSIDIAN_ROOT" \
--add-dir "$WORKSPACES_ROOT" \
--add-dir ~/.claude/prompts \
--add-dir /tmp \
"$@"
