#!/bin/bash
# Launch Claude Code with personal configuration
# - MCP: trading, atlassian-personal, gemini, youtube-vision
# - Access: trading workspace

export DISABLE_AUTOUPDATER=1
export SHELL=/bin/bash

MCP_REMOTE_CONFIG_DIR=".mcp-personal" \
npx @anthropic-ai/claude-code@latest \
  --model sonnet \
  --mcp-config ~/Documents/Obsidian/Personal/.claude/mcp-personal.json \
  --strict-mcp-config \
  --add-dir ~/Documents/Obsidian/Octopus \
  --add-dir ~/Documents/Obsidian/Personal \
  --add-dir ~/Documents/workspaces \
  --add-dir ~/.claude/prompts \
  "$@"

