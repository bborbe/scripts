#!/usr/bin/env bash
set -euo pipefail

ulimit -n 8000

export DISABLE_AUTOUPDATER=1
export CLAUDE_CODE_DISABLE_AUTO_MEMORY=1
export MCP_REMOTE_CONFIG_DIR="$HOME/.mcp-personal"
export ANTHROPIC_BASE_URL="https://api.minimax.io/anthropic"
export ANTHROPIC_AUTH_TOKEN="$(teamvault-password --teamvault-config ~/.teamvault.json --teamvault-key MOPmQL)"
export ANTHROPIC_MODEL="MiniMax-M3-highspeed"

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
