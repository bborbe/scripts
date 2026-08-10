#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

BRAVE_SEARCH_API_KEY="$(teamvault-cli password dwkkzw)" \
MINIMAX_API_KEY="$(teamvault-cli password MOPmQL)" \
pi \
--provider minimax \
--model MiniMax-M3-highspeed \
"$@"