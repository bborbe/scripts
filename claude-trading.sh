#!/usr/bin/env bash
# Launch Claude Code with personal configuration
# - MCP: trading, atlassian-personal, gemini, youtube-vision
# - Access: trading workspace

export DISABLE_AUTOUPDATER=1
# export SHELL=$(which bash)

cd ~/Documents/workspaces/trading

MCP_REMOTE_CONFIG_DIR="~/.mcp-personal" \
claude \
  --model sonnet \
  --mcp-config ~/.claude/mcp-personal.json \
  --strict-mcp-config \
  --add-dir ~/Documents/Obsidian \
  --add-dir ~/Documents/workspaces \
  --add-dir ~/.claude/prompts \
  "$@"

