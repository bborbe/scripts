#!/bin/bash
# Launch Claude Code with personal configuration
# - MCP: trading, atlassian-personal, gemini, youtube-vision
# - Access: trading workspace

cd ~/Documents/Obsidian

claude \
  --mcp-config ~/Documents/Obsidian/.claude/mcp-personal.json \
  --strict-mcp-config \
  --add-dir ~/Documents/workspaces/trading \
  "$@"
