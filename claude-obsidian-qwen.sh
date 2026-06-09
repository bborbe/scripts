#!/usr/bin/env bash

ulimit -n 8000
export DISABLE_AUTOUPDATER=1
export CLAUDE_CODE_DISABLE_AUTO_MEMORY=1
export CLAUDE_CODE_ATTRIBUTION_HEADER="0"
export MCP_REMOTE_CONFIG_DIR="~/.mcp-personal"

cd ~/Documents/Obsidian/Personal || exit 1

# Note the '--' right after the model selection
ollama launch claude --model qwen3.6:35b-a3b-coding-nvfp4 -- \
--mcp-config ~/.claude/mcp-obsidian-personal.json \
--strict-mcp-config \
--add-dir ~/Documents/Obsidian \
--add-dir ~/Documents/workspaces \
--add-dir ~/.claude/prompts \
--add-dir /tmp \
"$@"