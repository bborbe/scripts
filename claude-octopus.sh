#!/bin/bash
# Launch Claude Code with personal configuration
# - MCP: sm-octopus, atlassian-personal, gemini, youtube-vision
# - Access: sm-octopus workspace

export DISABLE_AUTOUPDATER=1
export SHELL=/bin/bash

cd ~/Documents/workspaces/sm-octopus

npx @anthropic-ai/claude-code@latest \
  --model sonnet \
  --mcp-config ~/Documents/workspaces/sm-octopus/.mcp.json \
  --strict-mcp-config \
  --add-dir ~/Documents/Obsidian \
  --add-dir ~/Documents/workspaces \
  --add-dir ~/.claude/prompts \
  "$@"
