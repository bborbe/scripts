#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

BRAVE_SEARCH_API_KEY="$(teamvault-password --teamvault-config ~/.teamvault.json --teamvault-key dwkkzw)" \
MINIMAX_API_KEY="$(teamvault-password --teamvault-config ~/.teamvault.json --teamvault-key MOPmQL)" \
pi \
--provider minimax \
--model MiniMax-M3-highspeed \
"$@"