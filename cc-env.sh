#!/usr/bin/env bash
# Shared environment for the cc-* launchers. Sourced, never executed.
#
# A launcher started from a WezTerm tab runs under `bash -lc` with launchd's
# minimal PATH and never reads ~/.zshrc, so `claude` (~/.local/bin) and the
# tools its hooks, MCP servers and Bash calls need (gh, jq, wezterm,
# vault-cli) were not found. Pin the PATH here so a launcher works the same
# from zsh, `bash -lc`, launchd or a supervisor spawn.

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

# Keep pyenv's shims off PATH. On macOS 26 every direct exec of a `#!` script
# leaks ~1 KiB into data.kalloc.1024 (kernel panics 2026-10-17, 11-13, 11-17),
# and a shim call is a chain of them (shim -> pyenv-exec -> pyenv-version-name
# -> ...). `pyenv global` is `system`, so the shims resolve to
# /opt/homebrew/bin/python3 anyway; a script that needs the `claude-scripts`
# venv must call that venv's python by absolute path.
_cc_path_dirs=()
IFS=':' read -r -a _cc_path_dirs <<< "$PATH"
_cc_kept=()
for _cc_dir in "${_cc_path_dirs[@]}"; do
	case "$_cc_dir" in
	"$HOME/.pyenv/shims" | "$HOME/.pyenv/plugins/pyenv-virtualenv/shims") ;;
	*) _cc_kept+=("$_cc_dir") ;;
	esac
done
PATH=$(IFS=':'; printf '%s' "${_cc_kept[*]}")
export PATH
unset _cc_path_dirs _cc_kept _cc_dir
