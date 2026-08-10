# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased

### Changed
- `pi.sh` — migrate to the teamvault-cli v5 invocation (`teamvault-cli password <key>`). The old `teamvault-password` binary was consolidated into the single cobra command in v5.0.0 and renamed to `teamvault-cli` in v5.2.x, and the hardcoded `--teamvault-config ~/.teamvault.json` pointed at a file that no longer exists since the config moved to XDG `~/.config/teamvault-cli/config.json`.

## v0.3.1

### Changed
- `wezterm-claude-snapshot` — refuse to overwrite a snapshot holding more sessions than the current run sees (archive it, exit 2, leave the restore script intact). Re-running post-reboot out of habit otherwise replaces the restore script with a one-session no-op and loses the UUIDs. `--force` overrides.

## v0.3.0

### Added
- `wezterm-claude-snapshot` — capture every running Claude Code session with its WezTerm window/tab before a reboot, and generate `~/.claude/wezterm-restore.sh` to re-open the tabs and `--resume` each session by UUID afterwards. Joins `wezterm cli list`, `ps`, and `~/.claude/sessions/<pid>.json`.

## v0.2.1

### Changed
- `update-all.sh` — drop `sudo` from `gcloud components update`. The SDK moved to a user-owned install in `$HOME`; running it under `sudo` wrote root-owned files into `~/.config/gcloud` and broke later user-level runs. Also moved the call above its own `echo` (it was printing "run brew update").

## v0.2.0

### Added
- `quant-route` — location-aware routing to home subnets over the Hetzner VPN (up/down/auto/status); direct on VLAN 20, VPN-routed off-VLAN. Covers quant/nuke, CO2 controllers (.177), rasp (.50), fire/sun/hell.
- `de.benjamin-borbe.quant-route.plist` — LaunchDaemon running `quant-route auto` at load, on network change, and every 3 min.

## v0.1.0

### Added
- CI workflow with shellcheck validation
- Claude Code workflow for @claude mentions in PRs/issues
- Makefile with test/check/precommit targets for shellcheck
- CHANGELOG.md for tracking changes

### Fixed
- pi.sh shebang to absolute path with strict mode (shellcheck SC2239)
