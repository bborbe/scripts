#!/bin/bash
# Launch Claude Code with personal configuration
# - MCP: trading, atlassian-personal, gemini, youtube-vision
# - Access: trading workspace

export DISABLE_AUTOUPDATER=1
export SHELL=/bin/bash

npx @anthropic-ai/claude-code@latest \
  --model sonnet \
  --add-dir ~/Documents/Obsidian \
  --add-dir ~/.claude/prompts \
  "$@"
