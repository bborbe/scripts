#!/bin/bash
# Launch Claude Code with personal configuration
# - MCP: sm-octopus, atlassian-personal, gemini, youtube-vision
# - Access: sm-octopus workspace

cd ~/Documents/workspaces/sm-octopus

claude \
  --mcp-config ~/Documents/workspaces/sm-octopus/.mcp.json \
  --strict-mcp-config \
  --add-dir ~/Documents/Obsidian \
  "$@"
