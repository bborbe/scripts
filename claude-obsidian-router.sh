#!/usr/bin/env bash
# Launch Claude in the Personal Obsidian vault, routed through the local
# claude-code-router (https://github.com/bborbe/claude-code-router).
#
# The router listens on 127.0.0.1:8788 by default. Default ANTHROPIC_MODEL
# stays on the subscription frontier (claude-opus-4-7); switch backends
# mid-session with `/model <name>` — the router forwards to the matching
# upstream (Anthropic subscription / MiniMax / DeepSeek vLLM / Ollama Qwen)
# based on the model name.
#
# Critically: do NOT set ANTHROPIC_AUTH_TOKEN or ANTHROPIC_API_KEY here —
# the OAuth subscription bearer Claude Code already holds is what travels
# through the router for anthropic-sub requests; the router substitutes
# the right token per provider internally.
#
# Override paths via env (set in ~/.zshrc per machine):
#   OBSIDIAN_PERSONAL          — Personal vault (default: $HOME/Documents/Obsidian/Personal)
#   OBSIDIAN_ROOT              — Obsidian parent dir for --add-dir (default: $HOME/Documents/Obsidian)
#   WORKSPACES_ROOT            — Code workspaces parent for --add-dir (default: $HOME/Documents/workspaces)
#   CLAUDE_CODE_ROUTER_URL     — Router URL (default: http://127.0.0.1:8788)

set -euo pipefail

ulimit -n 8000

export DISABLE_AUTOUPDATER=1
export CLAUDE_CODE_DISABLE_AUTO_MEMORY=1
export MCP_REMOTE_CONFIG_DIR="$HOME/.mcp-personal"
export ANTHROPIC_BASE_URL="${CLAUDE_CODE_ROUTER_URL:-http://127.0.0.1:8788}"
export ANTHROPIC_MODEL="claude-opus-4-7"

OBSIDIAN_PERSONAL="${OBSIDIAN_PERSONAL:-$HOME/Documents/Obsidian/Personal}"
OBSIDIAN_ROOT="${OBSIDIAN_ROOT:-$HOME/Documents/Obsidian}"
WORKSPACES_ROOT="${WORKSPACES_ROOT:-$HOME/Documents/workspaces}"

cd "$OBSIDIAN_PERSONAL" || exit 1

claude \
--model "${ANTHROPIC_MODEL}" \
--effort high \
--permission-mode auto \
--mcp-config ~/.claude/mcp-obsidian-personal.json \
--strict-mcp-config \
--add-dir "$OBSIDIAN_ROOT" \
--add-dir "$WORKSPACES_ROOT" \
--add-dir ~/.claude/prompts \
--add-dir /tmp \
"$@"
