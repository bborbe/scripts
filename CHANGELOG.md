# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased

- fix: cap the deepseek compaction output at 64000 in `cc-brogrammers-deepseek`, aligning it with `cc-personal-deepseek`. Claude Code gives unrecognised model ids (all `deepseek-*`) a 32000 fallback output cap, so the compaction summary came back truncated (`stop_reason: max_tokens`); after 3 consecutive failures the auto-compact circuit breaker tripped and the session grew to 100% context until it was stuck on "Prompt is too long". 64000 is accepted unclamped (the unknown-model upper limit is 128000) and leaves ~113k of the 1M window for the summary at the 900000-token auto-compact window's 887k trigger.

## v0.8.1

- fix: unset the inherited `CLAUDE_CODE_SESSION_ID` in all 16 `cc-*` launchers. A pane spawned from a session inherited the CALLING session's `CLAUDE_CODE_SESSION_ID`, so the child resolved its own identity from the PARENT and wrote the parent's name as its trailing `agent-name` — it held its own name for the whole run, then ended it under the spawning session's name, while its own uuid stayed correct. Measured 3x on 2026-09-14 (`ae186815`, `f4c8fd2d`, `a4de4005`) and reproducible on demand via `/open` → `vault-cli task work-on --mode headless` → `wezterm cli spawn`. The launchers already defended against the sibling variable `CLAUDE_CODE_CHILD_SESSION`; this closes the same gap for the identity variable. No-op on a plain launch, where the variable is unset anyway.

## v0.8.0

- feat: `cc-discord-assistant-bro` now runs on deepseek (deepseek-v4-flash-max[1m] opus/fable tier, deepseek-v4-flash[1m] sonnet/haiku) via claude-code-router, effort high — matching `cc-personal-deepseek`.

## v0.7.0

- feat: point `cc-discord-assistant-bro` at a dedicated `BrogrammersAssistant` runtime vault (cwd) instead of the `Brogrammers` knowledge vault; the three team vaults (Brogrammers, OctopusAgent, OpenBrain) are now reached via `--add-dir`. Mirrors the personal assistant's move off the user vault — no narration rule, no tts MCP server — so a Discord-answered session cannot double-speak on the laptop.

## v0.6.5

- fix: pin `TEAMVAULT_CONFIG` to the personal instance in `cc-personal`. The launcher inherited whatever
  the calling shell exported, so a terminal left pointing at `seibert.json` (work) made every personal /
  nuke / quant secret lookup 404. `teamvault-cli config parse` then renders an EMPTY manifest and
  `kubectl apply` reports "no objects passed to apply" while the Makefile still exits 0 — images push,
  nothing deploys, the run looks clean. Hit 2026-09-06 during the weekly nuke rebuild: 8 quant components
  silently failed to apply on dev AND prod. Same class as the ~296 silent apply failures of 2026-08-23.

## v0.6.4

### Changed
- `git-status.sh` — fix false `DIRTY` reports: the stat-cache check `git diff-index --quiet HEAD` flagged mtime-only changes (content unchanged) as dirty, e.g. after a checkout or `go mod tidy` sweep; switched to `git diff --quiet HEAD`, which re-verifies file content.

## v0.6.3

### Changed
- `remote-k3s-shutdown-nuke.sh` — drop the decommissioned `nuke-k3s-agent-0`, `nuke-k3s-dev-0` and `nuke-k3s-prod-0` from the first pssh block (13 → 10 hosts), completing the sweep started in v0.6.2 for `update-all.sh`. All three are powered off; with `set -o errexit` their pssh failure aborted the script after the workers were stopped but **before** the kafka and master blocks — leaving Kafka and etcd live and mid-write during the Sunday backup window, the exact torn state the script exists to prevent. Commented out rather than deleted, matching the `nuke-boss` / `nuke-workspace` convention.

## v0.6.2

### Changed
- `update-all.sh` — drop the decommissioned `nuke-k3s-agent-0`, `nuke-k3s-dev-0` and `nuke-k3s-prod-0` from the pssh host list (22 → 19 hosts). All three are cordoned (`NotReady,SchedulingDisabled`) and powered off; their workloads moved to the nuke-dev / nuke-prod clusters. Commented out rather than deleted, matching the existing `nuke-boss` / `nuke-workspace` convention.

## v0.6.1

### Changed
- `virsh-start-all` — exclude `nuke-k3s-prod-0`; the VM was drained and shut down 2026-08-21 to reclaim ~32 GiB, but stays defined because its disk holds 391 retained local-path PVs.

## v0.6.0

### Added
- `deepseek-harness` — launch the DeepSeek Harness browser UI (`npx @deepseek-ai/dsh web`) in the foreground; configurable host/port/browser-open plus a single-instance guard.

## v0.5.0

### Added
- `k8s-delete-{error,not-running}[-force]-nuke-{dev,prod}` — delete scripts for the nuke K3s clusters.
- `k8s-delete-{error,not-running}[-force]-smallprod` — delete scripts for the GKE small-prod cluster.

### Changed
- `k8s-delete-{error,not-running}[-force]-{dev,staging,prod}` — rename to `octopus-{dev,staging,prod}` so the GKE cluster family is explicit in the name.
- `kubectlnukedev`/`kubectlnukeprod` — fix kubeconfig paths (nukedev pointed at `nuke-prod`, nukeprod at `octopus-prod`).

## v0.4.0

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
