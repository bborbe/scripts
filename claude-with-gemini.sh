# Point Claude to your local LiteLLM proxy
export ANTHROPIC_BASE_URL=http://localhost:4000

# LiteLLM needs a dummy key to accept the request (value doesn't matter)
export ANTHROPIC_API_KEY=sk-1234 

# Disable beta features that might confuse Gemini (Critical Step)
export CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS=1

# Disable auto-update
export DISABLE_AUTOUPDATER=1
export SHELL=/bin/bash

# Run the tool
claude-legacy --model sonnet "$@"