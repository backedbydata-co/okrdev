# Parking Lot

Ideas get captured here in seconds and triaged at the weekly check-in.
Nothing in Captured gets worked on. Ever. Triage first.

## Captured

<!-- One line per idea, exactly this shape:
     - [2026-07-13] <one-line idea> — @<who> — energy: high — effort: M
     energy (high/med/low) = how excited the capturer is; effort (S/M/L) = gut-call
     size. Both are 5-second calls, not analysis. -->

- [2026-07-30] Live-call coaching as a repeatable okrdev capability (Zoom RTMS-based, replacing the one-off local rig in docs/live-coached-sessions.md) — @alex — energy: med — effort: L
- [2026-07-30] Ship the live-coaching rig with okrdev (templates/live-coach/) instead of leaving it as untracked facilitator tooling on one Mac — it took a day to build and dies with the machine — @alex — energy: med — effort: M

## Side quests (time-boxed, logged)

<!-- Sanctioned distractions. Every one gets a box; spent hours count against the
     budget in config.md:
     - [2026-07-13] <idea> — @<who> — box: 4h — spent: 2h — status: open — notes: — -->

## Promoted

- [2026-07-23] Headless install path → KR2.2 (drafted in 2026-Q3 plan)
- [2026-07-30] Template-validation CI for this repo (YAML/JSON/bash lint, dead-link check) → KR1.3
- [2026-07-30] `/okrdev:uninstall` skill (procedure exists in adoption.md but no skill runs it) → next-cycle candidate
- [2026-07-30] Issues-as-capture-inbox: park via `okrdev:parked` GitHub issue (phone/web/collaborator capture, zero CI); triage sweeps + closes into the file ledger → KR1.3
- [2026-07-30] Protected-main guidance for L0/L1: batch state writes into the weekly triage commit + optional `okrdev/**` path-ignore for CI → KR1.3 (bundled with no-commits-to-main)
- [2026-07-30] okrdev itself should not allow commits to main, and advise that as best practice for others' repos → KR1.3 (sequence: redesign state writes first, then protect main)
- [2026-07-30] Repo-topology doctrine in adoption.md — "one team, one mission, one repo": monorepo default for multi-surface products, seam list (OSS-boundary, Expo-forced companion repo, team/mission) — @alex — energy: high — effort: M → next-cycle candidate
- [2026-07-30] Monorepo-aware Level 2 templates: workspace-glob CODEOWNERS, fan-in `ci` aggregate job, warning to never path-filter the required check — @alex — energy: med — effort: M → next-cycle candidate
- [2026-07-30] Per-surface "definition of shipped" + DRI verify variants (store release ritual, EAS/TestFlight links, MCP test transcript; long-lived-client expand/contract caveat) — @alex — energy: med — effort: M → next-cycle candidate
- [2026-07-30] `repos:` federation list in config.md — drift check / PR bridge / planning scan loop `gh -R` over satellite repos — @alex — energy: med — effort: M → next-cycle candidate
- [2026-07-30] Install-skill sibling-okrdev detection — link to an existing hub install instead of scaffolding a duplicate — @alex — energy: med — effort: S → next-cycle candidate
- [2026-07-30] Multi-surface repos: default okrdev state writes to auto-merged PRs (actor-scoped bypass blast radius spans all surfaces) — @alex — energy: low — effort: S → next-cycle candidate
- [2026-07-30] Exclude bot-authored PRs from maintenance/emergency tally denominators in checkin/coach/retro — @alex — energy: low — effort: S → next-cycle candidate

<!-- Ideas that survived triage and became KR work or planning input:
     - [2026-07-13] <idea> → KR2.1 (or: next-cycle candidate) -->

## Archived

- [2026-07-30] Native quick-capture app so parking works away from a repo session — reason: superseded by issues-as-capture-inbox (mobile capture via the GitHub app for free)
- [2026-07-30] Web dashboard that renders okrdev/ files — reason: explicit v0 non-goal; re-raise post-adoption if the files stop being enough

<!-- Ideas you decided against. Keep the reason — future-you will re-have this idea:
     - [2026-07-13] <idea> — reason: <one line> -->
