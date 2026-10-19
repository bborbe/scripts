#!/usr/bin/env bash
# Shared environment for the cc-* launchers. Sourced, never executed.
#
# A launcher started from a WezTerm tab runs under `bash -lc` with launchd's
# minimal PATH and never reads ~/.zshrc, so `claude` (~/.local/bin) and the
# tools its hooks, MCP servers and Bash calls need (gh, jq, wezterm,
# vault-cli) were not found. Pin the PATH here so a launcher works the same
# from zsh, `bash -lc`, launchd or a supervisor spawn.

# Keep Claude's TUI in the normal screen buffer instead of the alternate
# screen, so the session's output stays in the tab's scrollback afterwards.
export CLAUDE_CODE_DISABLE_ALTERNATE_SCREEN=1

CC_SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

for dir in \
	/usr/local/sbin \
	/usr/local/bin \
	/opt/homebrew/sbin \
	/opt/homebrew/bin \
	"$HOME/.bun/bin" \
	"$HOME/Documents/workspaces/go/bin" \
	"$CC_SCRIPTS_DIR" \
	"$HOME/.local/bin"; do
	case ":$PATH:" in
	*":$dir:"*) ;;
	*) [ -d "$dir" ] && PATH="$dir:$PATH" ;;
	esac
done
export PATH
