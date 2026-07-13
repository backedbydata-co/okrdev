---
okrdev_version: 0.1.0
level: 2                      # 0 parking lot | 1 method | 2 collab rails
cycle_length: quarterly
checkin_cadence: weekly
side_quest_box_hours_per_week: 4
strict_gate: false
backstop: jordan
---

# okrdev config

How Acme Fitness runs okrdev:

- **The team.** maya (founder — sales, pricing, partnerships), jordan (product and
  engineering), priya (onboarding, support, ops). Three people; no titles beyond this list.
- **Check-in.** Thursdays 09:30, 15 minutes. The coach pre-drafts the file Wednesday night;
  anyone can fill their sections async before the call.
- **Level 2 rails.** PR template with the `KR:` line, okr-gate in warn mode (strict stays
  off until warn-mode noise proves low), CODEOWNERS routes payment and migration paths to
  jordan.
- **Backstop.** jordan. If a DRI and the coach are both stuck for more than ~30 minutes,
  stop and call him — that's what this field is for.
- **State writes.** Parking-lot and check-in commits go straight to main via the `okrdev/**`
  bypass ruleset; everything else goes through a PR.
