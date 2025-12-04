#!/bin/bash
# Launch Claude Code with seibert configuration
# - MCP: atlassian-seibert, gemini
# - Access: sm-octopus workspace

cd ~/Documents/Obsidian

claude \
  --mcp-config ~/Documents/Obsidian/.claude/mcp-seibert.json \
  --strict-mcp-config \
  --add-dir ~/Documents/workspaces/sm-octopus \
  "$@"
