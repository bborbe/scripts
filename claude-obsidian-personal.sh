#!/bin/bash
# Launch Claude Code with personal configuration
# - MCP: trading, atlassian-personal, gemini, youtube-vision
# - Access: trading workspace

export DISABLE_AUTOUPDATER=1
export SHELL=/bin/bash

cd ~/Documents/Obsidian/Personal

MCP_REMOTE_CONFIG_DIR=".mcp-personal" \
npx @anthropic-ai/claude-code@2.0.65 \
  --model sonnet \
  --mcp-config ~/Documents/Obsidian/Personal/.claude/mcp-personal.json \
  --strict-mcp-config \
  --add-dir ~/Documents/workspaces/trading \
  --add-dir ~/.claude/prompts \
  "$@"

