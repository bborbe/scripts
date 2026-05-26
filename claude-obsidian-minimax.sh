#!/usr/bin/env bash
# Launch Claude Code with personal configuration
# - MCP: trading, atlassian-personal, gemini, youtube-vision
# - Access: trading workspace

ulimit -n 8000
export DISABLE_AUTOUPDATER=1
export CLAUDE_CODE_DISABLE_AUTO_MEMORY=1
# export SHELL=$(which bash)

cd ~/Documents/Obsidian/Personal

MCP_REMOTE_CONFIG_DIR="~/.mcp-personal" \
ANTHROPIC_BASE_URL="https://api.minimax.io/anthropic" \
ANTHROPIC_AUTH_TOKEN="$(teamvault-password --teamvault-config ~/.teamvault.json --teamvault-key MOPmQL)" \
ANTHROPIC_MODEL="MiniMax-M2.7-highspeed" \
claude \
--model "MiniMax-M2.7-highspeed" \
--effort high \
--mcp-config ~/.claude/mcp-obsidian-personal.json \
--strict-mcp-config \
--add-dir ~/Documents/Obsidian \
--add-dir ~/Documents/workspaces \
--add-dir ~/.claude/prompts \
--add-dir /tmp \
"$@"
