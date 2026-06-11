#!/usr/bin/env bash
# Launch Claude (Qwen via local Ollama backend) in the Personal Obsidian vault.
#
# Override paths via env (set in ~/.zshrc / direnv per machine):
#   OBSIDIAN_PERSONAL  — Personal vault (default: $HOME/Documents/Obsidian/Personal)
#   OBSIDIAN_ROOT      — Obsidian parent for --add-dir
#   WORKSPACES_ROOT    — Code workspaces parent for --add-dir

set -euo pipefail

ulimit -n 8000

export DISABLE_AUTOUPDATER=1
export CLAUDE_CODE_DISABLE_AUTO_MEMORY=1
export CLAUDE_CODE_ATTRIBUTION_HEADER="0"
export MCP_REMOTE_CONFIG_DIR="$HOME/.mcp-personal"
export ANTHROPIC_BASE_URL="http://localhost:11434"
export ANTHROPIC_AUTH_TOKEN="ollama"
export ANTHROPIC_MODEL="qwen3.6:35b-a3b-coding-nvfp4"
export ANTHROPIC_DEFAULT_OPUS_MODEL="${ANTHROPIC_MODEL}"
export ANTHROPIC_DEFAULT_SONNET_MODEL="${ANTHROPIC_MODEL}"
export ANTHROPIC_DEFAULT_HAIKU_MODEL="${ANTHROPIC_MODEL}"

OBSIDIAN_PERSONAL="${OBSIDIAN_PERSONAL:-$HOME/Documents/Obsidian/Personal}"
OBSIDIAN_ROOT="${OBSIDIAN_ROOT:-$HOME/Documents/Obsidian}"
WORKSPACES_ROOT="${WORKSPACES_ROOT:-$HOME/Documents/workspaces}"

cd "$OBSIDIAN_PERSONAL" || exit 1

claude \
--model "${ANTHROPIC_MODEL}" \
--effort high \
--permission-mode acceptEdits \
--mcp-config ~/.claude/mcp-obsidian-personal.json \
--strict-mcp-config \
--add-dir "$OBSIDIAN_ROOT" \
--add-dir "$WORKSPACES_ROOT" \
--add-dir ~/.claude/prompts \
--add-dir /tmp \
"$@"
