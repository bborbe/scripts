#!/usr/bin/env bash
set -euo pipefail

ulimit -n 8000

export DISABLE_AUTOUPDATER=1
export CLAUDE_CODE_DISABLE_AUTO_MEMORY=1
export CLAUDE_CODE_ATTRIBUTION_HEADER="0"
export MCP_REMOTE_CONFIG_DIR="$HOME/.mcp-personal"
export ANTHROPIC_BASE_URL="http://localhost:11434"
export ANTHROPIC_AUTH_TOKEN="ollama"
export ANTHROPIC_MODEL="qwen3.6:35b-a3b-coding-nvfp4"

cd ~/Documents/Obsidian/Personal || exit 1

claude \
--model "${ANTHROPIC_MODEL}" \
--effort high \
--mcp-config ~/.claude/mcp-obsidian-personal.json \
--strict-mcp-config \
--add-dir ~/Documents/Obsidian \
--add-dir ~/Documents/workspaces \
--add-dir ~/.claude/prompts \
--add-dir /tmp \
"$@"
