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
- [2026-08-04] Repo-topology doctrine, when promoted: seam test as the decision procedure (a second repo iff a different audience speaks a different language about the same words), Expo-style toolchain splits as the named exception class, satellites-conform-to-hub federation note — @alex — energy: med — effort: S
- [2026-08-04] Planning throwaway-prototype homework (coach-built, deleted after the session, never for non-code objectives) — trial once in a real planning session before doctrining it; drop the idea if it changes no argument in two cycles — @alex — energy: low — effort: S
- [2026-08-04] roles.md § The DRI: one paragraph on the inversion (about the outcome the DRI is precisely the expert; the coach is the builder extracting that knowledge — why straw-men arrive in the DRI's vocabulary and an evidence line is a probe, not an audit) — promote from evidence.md's one-liner only if load-bearing in real coaching conversations — @alex — energy: low — effort: S
- [2026-08-04] examples/acme-fitness refresh after the narrative-floor trigger fires in a live cycle: one worked exchange in an example check-in (the question, a "nothing clickable — next artifact is the signed contract" answer, the Judgment-calls re-class line) + one "archived — already solved elsewhere, adopt X" epitaph in the example parking lot + rephrase the example okrs' "behind a flag" anchors into domain-noun events — lifted from real usage, never invented — @alex — energy: med — effort: S
- [2026-08-04] Separate maintenance PR for pre-existing sync wrinkles (keep the evidence.md diff clean): repo-root CLAUDE.md coach block one revision behind templates/CLAUDE-okrdev.md (rule 3 issue-capture wording); okrdev/config.md okrdev_version behind the shipped template (0.1.0 at capture); decide README repo-map row or stated exemption for docs/live-coached-sessions.md; write the one-line versioning policy into adoption.md § Upgrading (skills/templates change → bump plugin.json + template config together; docs-only → no bump — today it's only reconstructable from git history) — @alex — energy: med — effort: S
- [2026-08-04] Coherence sweep one week after evidence.md lands (per the cycle's #1 health metric): grep "three triggers" appears nowhere; threshold triple (3 check-ins / ≥0.5 / once per KR) verbatim across method.md, rituals.md, skills/checkin, skills/coach, and the template comment; fence sentence in both ai-coach.md and evidence.md; build/box/buy wording matching across evidence.md, parking-lot.md, skills/triage, skills/coach — @alex — energy: med — effort: S
- [2026-08-04] Vocabulary watch: if real DRIs stumble on build/box/buy despite the verbs being everyday words, spend shipping-explained.md glossary rows deliberately (a budget decision, not a default); same watch on whether the "demo" row's definition survives contact with non-code DRIs — @alex — energy: low — effort: S
- [2026-08-04] Level 2 evaluation, only if dogfooding shows the want: soft "anything to click?" nudge on KR-tagged PRs with no preview (okr-gate or PR template) — must be argued against the install-footprint red line and the non-code fence before any template change — @alex — energy: low — effort: S

## Side quests (time-boxed, logged)

<!-- Sanctioned distractions. Every one gets a box; spent hours count against the
     budget in config.md:
     - [2026-07-13] <idea> — @<who> — box: 4h — spent: 2h — status: open — notes: — -->

- [2026-08-04] Evidence doctrine: docs/evidence.md + demo/domain-language wiring across method, rituals, and six skills — @alex — box: 4h — spent: 2h — status: done — notes: produced the evidence.md PR (KR: side-quest); spent is the coach's estimate, DRI to correct at review; coherence sweep parked in Captured
- [2026-08-06] Phase 1.5 — the adopter prescription's four doctrine edits (stack.md Tests, ai-coach.md conduct line, PR-template comment, adoption.md pointer) — @alex — box: 2h — spent: 1h — status: done — notes: decision-sourced (2026-08-06 W32 ruling), per docs/testing.md § Classification; all four surfaces wired in one PR (KR: side-quest); spent is the coach's estimate, DRI to correct; PR-template edit pulled the versioning policy → 0.5.0

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
