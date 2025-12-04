#!/bin/bash
# Launch Claude Code with personal configuration
# - MCP: trading, atlassian-personal, gemini, youtube-vision
# - Access: trading workspace

cd ~/Documents/workspaces/trading

claude \
  --mcp-config ~/Documents/workspaces/trading/.mcp.json \
  --strict-mcp-config \
  --add-dir ~/Documents/Obsidian \
  "$@"
