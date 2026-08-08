# Parking Lot

Ideas get captured here in seconds and triaged at the weekly check-in.
Nothing in Captured gets worked on. Ever. Triage first.

## Captured

<!-- One line per idea, exactly this shape:
     - [2026-07-13] <one-line idea> — @<who> — energy: high — effort: M
     energy (high/med/low) = how excited the capturer is; effort (S/M/L) = gut-call
     size. Both are 5-second calls, not analysis. -->

## Side quests (time-boxed, logged)

<!-- Sanctioned distractions. Every one gets a box; spent hours count against the
     budget in config.md:
     - [2026-07-13] <idea> — @<who> — box: 4h — spent: 2h — status: open — notes: — -->

- [2026-08-04] Evidence doctrine: docs/evidence.md + demo/domain-language wiring across method, rituals, and six skills — @alex — box: 4h — spent: 2h — status: done — notes: produced the evidence.md PR (KR: side-quest); spent is the coach's estimate, DRI to correct at review; coherence sweep parked in Captured
- [2026-08-06] Phase 1.5 — the adopter prescription's four doctrine edits (stack.md Tests, ai-coach.md conduct line, PR-template comment, adoption.md pointer) — @alex — box: 2h — spent: 1h — status: done — notes: decision-sourced (2026-08-06 W32 ruling), per docs/testing.md § Classification; all four surfaces wired in one PR (KR: side-quest); spent is the coach's estimate, DRI to correct; PR-template edit pulled the versioning policy → 0.5.0
- [2026-08-07] Local loop as 5th adopter-prescription item (#15) — @alex — box: 1h — spent: 1h — status: done — notes: decision-sourced (2026-08-06 prescription ruling); sanctioned at the W32 check-in to run immediately, not next week; closed by the item-5 PR (KR: side-quest) — spent is the coach's estimate, DRI to correct at review; W32 spend now at the 4h/week line
- [2026-08-07] okrdev website (site/) — open-core positioning + the three help paths (DIY free / DWY coached group / DFY Tech Guys on Demand) — @alex — box: 2h — spent: 2h — status: done — notes: DRI-directed; O2-adjacent (the curious→adopter funnel) but no KR measures it; fourth box this week — opened box-hours 9h, spend ~6h against the 4h budget, extending the W32 watch item; spent is the coach's estimate, DRI to correct; deploy target undecided (KR: side-quest, PR #28)

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
- [2026-07-30] Live-call coaching as a repeatable okrdev capability (Zoom RTMS-based, replacing the one-off local rig in docs/live-coached-sessions.md) → next-cycle candidate (W32 triage)
- [2026-07-30] Ship the live-coaching rig with okrdev (templates/live-coach/) instead of untracked facilitator tooling on one Mac → next-cycle candidate (W32 triage)
- [2026-08-04] Repo-topology doctrine refinements: seam test as decision procedure, Expo-style toolchain splits as exception class, satellites-conform-to-hub federation note → next-cycle candidate (merged into the 2026-07-30 repo-topology candidate)
- [2026-08-04] Planning throwaway-prototype homework (coach-built, deleted after the session) → next-cycle candidate (trial once in a real planning session before doctrining)
- [2026-08-04] roles.md § The DRI inversion paragraph → next-cycle candidate (promote only if load-bearing in real coaching conversations)
- [2026-08-04] examples/acme-fitness refresh (worked narrative-floor exchange, archived-epitaph example, domain-noun anchors) → next-cycle candidate (after the trigger fires in a live cycle)
- [2026-08-04] Coherence sweep one week after evidence.md lands → W33 focus (KR1.3 — defends the #1 health metric)
- [2026-08-04] Vocabulary watch: build/box/buy stumbles + the "demo" row's survival with non-code DRIs → next-cycle candidate (needs adopter data)
- [2026-08-04] Level 2 soft "anything to click?" nudge on KR-tagged PRs with no preview → next-cycle candidate (gated on dogfooding showing the want; argue against the footprint red line first)
- [2026-08-05] Plugin payload restructure — marketplace `source: "./"` ships the whole repo as every adopter's download (#8) → next-cycle candidate (effort M–L; KR2.2's 1.0 anchor doesn't need it)
- [2026-08-07] Pre-push hook silently no-ops in every worktree — core.bare leak (#19) → KR1.3
- [2026-08-07] Node pins have five copies and no rail keeping them equal (#16) → KR1.3
- [2026-08-07] branch-protection.sh claims code-owner review with no CODEOWNERS to route to (#13) → KR1.3

<!-- Ideas that survived triage and became KR work or planning input:
     - [2026-07-13] <idea> → KR2.1 (or: next-cycle candidate) -->

## Archived

- [2026-07-30] Native quick-capture app so parking works away from a repo session — reason: superseded by issues-as-capture-inbox (mobile capture via the GitHub app for free)
- [2026-07-30] Web dashboard that renders okrdev/ files — reason: explicit v0 non-goal; re-raise post-adoption if the files stop being enough
- [2026-08-04] Separate maintenance PR for pre-existing sync wrinkles — reason: delivered by #12 (versioning policy in adoption.md) and #14 (okrdev_version upgraded to current); the README repo-map decision folds into the coherence sweep

<!-- Ideas you decided against. Keep the reason — future-you will re-have this idea:
     - [2026-07-13] <idea> — reason: <one line> -->
