# Changelog

The plugin's version lives in `.claude-plugin/plugin.json`. An adopter repo
records the version it installed as the `okrdev_version` marker in its
`okrdev/config.md` — marker semantics are in docs/adoption.md. Pre-1.0:
minor bumps may change doctrine, not just add to it.

## Unreleased

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
