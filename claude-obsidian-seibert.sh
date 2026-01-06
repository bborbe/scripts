#!/bin/bash
# Launch Claude Code with seibert configuration
# - MCP: atlassian-seibert, gemini
# - Access: sm-octopus workspace

export DISABLE_AUTOUPDATER=1
export SHELL=/bin/bash

cd ~/Documents/Obsidian/Seibert

MCP_REMOTE_CONFIG_DIR=".mcp-seibert" \
npx @anthropic-ai/claude-code@2.0.65 \
  --model sonnet \
  --mcp-config ~/Documents/Obsidian/Seibert/.claude/mcp-ben.json \
  --strict-mcp-config \
  --add-dir ~/Documents/workspaces/sm-octopus \
  --add-dir ~/Documents/workspaces/sm-isac \
  --add-dir ~/Documents/workspaces/sm-standup \
  --add-dir ~/Documents/workspaces/sm-sentinel \
  --add-dir ~/.claude/prompts \
  "$@"
