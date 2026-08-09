# Changelog

The plugin's version lives in `.claude-plugin/plugin.json`. An adopter repo
records the version it installed as the `okrdev_version` marker in its
`okrdev/config.md` — marker semantics are in docs/adoption.md. Pre-1.0:
minor bumps may change doctrine, not just add to it.

## Unreleased

## 0.7.0 — 2026-08-08

**Every shipped change now bumps the version.** The old rule exempted docs-only
changes and `install.sh`, on the correct reasoning that neither has an installed
copy in an adopter's repo that could fall behind. What changed is that the
version acquired a second consumer: listed in a plugin directory, it is the
distribution cache key, and the only signal that there is anything new to fetch.
Seven of the eight skills read `docs/` at runtime, so a docs fix is a behaviour
fix. Measured rather than assumed — a docs-only change at an unchanged version
is still retrievable by an explicit re-install, but nothing tells anyone to run
one.

- The empty-upgrade-prompt problem the old rule avoided is now solved in the
  upgrade path instead of in the version: `/okrdev:install` reports "this
  release changed no scaffolding, nothing to apply" rather than presenting an
  empty diff
- `docs/adoption.md` keeps the original rule and its reasoning verbatim, so the
  next reader sees what changed and why rather than only the conclusion

## 0.6.0 — 2026-08-08

**okrdev runs on Codex as well as Claude Code.** The coach block now installs
into whichever file the host agent reads — `CLAUDE.md` or `AGENTS.md` — and
nothing else about the install forks. `templates/CLAUDE-okrdev.md` carries no
platform tokens, so the block itself is unchanged; only its destination is a
parameter. Verified end-to-end against the real `codex` CLI, not against docs:
`codex plugin marketplace add` + `codex plugin add` installs and enables all
eight skills. Notes in `docs/codex.md`.

- The install skill resolves the instructions file, with existing markers
  winning over the host default, and refuses to write both files
- The install-footprint health metric names its destination by role rather than
  by filename (`okrdev/okrs/2026-Q3.md`, amended with a `Revised:` block)
- `.codex-plugin/plugin.json` — the Codex/OpenAI directory manifest, sharing
  the `skills/` tree and identity with the Claude manifest
- `assets/logo.svg` and `assets/composer-icon.svg`; the cursor underscore is
  dropped from the brand
- Directory-listing metadata on the Claude manifest: license, repository,
  homepage, keywords (the plugin was submitted to the Claude plugin directory
  on 2026-08-08)
- The plugin payload no longer ships a 6 MB generated PDF: 6.5 MB → 0.64 MB
- `PRIVACY.md`; the quickstart clones to `mktemp -d` rather than a fixed path
  in `$HOME` it then `rm -rf`s
- Headless install path: `install.sh` registers the marketplace and installs
  the plugin with no `/plugin` dialog (#18)
- The adopter prescription's fifth item: run the checks locally, with its
  local/CI parity warning (#21, #22)
- Open-source readiness: `.gitignore`, community health files, this
  changelog; outside-adopter references anonymized in the dogfood ledger

## 0.5.0 — 2026-08-06

- The adopter prescription (Phase 1.5), wired into the four surfaces
  adopters already meet: stack.md's Tests section, ai-coach.md's conduct
  line, the PR-template comment, adoption.md's pointer (#17)

## 0.4.0 — 2026-08-06

- Local test loop: opt-in pre-push hook (`tests/hooks/pre-push`) plus the
  local/CI parity advisory (#14)
- okrdev's own deterministic check suite, red-first on live defects — among
  them a shell injection in a shipped workflow template and a silently-dead
  script: Phase 0 (#9), Phase 1 (#10, #12), behind the required `check` job
- Testing doctrine: docs/testing.md (#7)

## 0.3.0 — 2026-08-05

- Evidence doctrine: docs/evidence.md — demos, domain words, and what counts
  as proof (#6)
- Live-coached sessions playbook: docs/live-coached-sessions.md (#3, #4, #5)

## 0.2.0 — 2026-07-30

- State writes redesigned for a protected main: issues as the capture inbox,
  batched ledger writes, protect-main as shipped best practice (#2)

## 0.1.0 — 2026-07-13

- Initial release: the method (docs/), eight coach skills, the install
  templates, the optional stack module, MANIFESTO.md
