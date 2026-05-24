#!bash

BRAVE_SEARCH_API_KEY="$(teamvault-password --teamvault-config ~/.teamvault.json --teamvault-key dwkkzw)" \
MINIMAX_API_KEY="$(teamvault-password --teamvault-config ~/.teamvault.json --teamvault-key MOPmQL)" \
pi --provider minimax --model MiniMax-M2.7-highspeed