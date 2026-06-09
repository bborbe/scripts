#!/usr/bin/env bash
set -euo pipefail

ulimit -n 8000
export DISABLE_AUTOUPDATER=1
export CLAUDE_CODE_DISABLE_AUTO_MEMORY=1
export MCP_REMOTE_CONFIG_DIR="$HOME/.mcp-seibert"

cd ~/Documents/Obsidian/Brogrammers

claude \
--model claude-opus-4-7 \
--effort high \
--mcp-config ~/.claude/mcp-seibert.json \
--strict-mcp-config \
--add-dir ~/Documents/Obsidian \
--add-dir ~/Documents/workspaces \
--add-dir ~/.claude/prompts \
--add-dir /tmp \
"$@"
