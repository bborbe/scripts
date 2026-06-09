#!/usr/bin/env bash
set -euo pipefail

ulimit -n 8000
export DISABLE_AUTOUPDATER=1
export CLAUDE_CODE_DISABLE_AUTO_MEMORY=1
export MCP_REMOTE_CONFIG_DIR="$HOME/.mcp-personal"

cd ~/Documents/Obsidian/Personal

ANTHROPIC_BASE_URL="https://api.minimax.io/anthropic" \
ANTHROPIC_AUTH_TOKEN="$(teamvault-password --teamvault-config ~/.teamvault.json --teamvault-key MOPmQL)" \
ANTHROPIC_MODEL="MiniMax-M3-highspeed" \
claude \
--model "MiniMax-M3-highspeed" \
--effort high \
--mcp-config ~/.claude/mcp-obsidian-personal.json \
--strict-mcp-config \
--add-dir ~/Documents/Obsidian \
--add-dir ~/Documents/workspaces \
--add-dir ~/.claude/prompts \
--add-dir /tmp \
"$@"
