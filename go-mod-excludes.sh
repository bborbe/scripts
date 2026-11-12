#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

# Thin wrapper over `updater fix` — the single source of truth for go.mod
# excludes and replaces lives in
#   updater/src/updater/gomod_excludes.py
# (STANDARD_EXCLUDES, OBSOLETE_EXCLUDES_PREFIXES, OBSOLETE_REPLACES,
#  TOOLS_GO_OBSOLETE_REPLACES).
#
# Usage: go-mod-excludes.sh [directories...]
#   directories: optional paths to modules or parent directories
#                (defaults to current directory)
#
# `--no-git` preserves this script's original contract: edit go.mod, do not
# commit. The caller commits (see /go-update-deps -> /coding:commit).
#
# 2026-10-15 — reduced from a 93-line reimplementation to this wrapper. It used
# to carry its own list of 39 `-dropexclude` and 2 `-dropreplace` directives and
# to *add* five replace directives. Four of those five (anthropic-sdk-go,
# go-header, go-diskfs, ginkgolinter/types) are in updater's own removal lists,
# so updater stripped them on its next run and the two writers fought on every
# pass; the fifth (opencontainers/runtime-spec) is in neither list. updater now
# owns the lists outright.

exec updater --yes --no-git fix "${@:-.}"
