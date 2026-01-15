#!/bin/bash
# Launch Claude Code with seibert configuration
# - MCP: atlassian-seibert, gemini
# - Access: sm-octopus workspace

export DISABLE_AUTOUPDATER=1
export SHELL=/bin/bash

cd ~/Documents/Obsidian/Brogrammers

MCP_REMOTE_CONFIG_DIR="~/.mcp-seibert" \
npx @anthropic-ai/claude-code@latest \
  --model sonnet \
  --mcp-config ~/.claude/mcp-seibert.json \
  --strict-mcp-config \
  --add-dir ~/Documents/Obsidian \
  --add-dir ~/Documents/workspaces \
  --add-dir ~/.claude/prompts \
  "$@"
