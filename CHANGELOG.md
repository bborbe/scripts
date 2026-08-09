# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
