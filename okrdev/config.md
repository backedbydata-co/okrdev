---
okrdev_version: 0.5.0         # used by upgrade and uninstall — don't edit by hand
level: 1                      # 0 parking lot | 1 method | 2 collab rails
cycle_length: quarterly       # quarterly | six-week
checkin_cadence: weekly
side_quest_box_hours_per_week: 4
strict_gate: false            # record of the Level 2 strict-mode decision. The gate itself is controlled by the OKRDEV_STRICT_GATE repo variable (gh variable set OKRDEV_STRICT_GATE --body true) — flip both together
backstop: alex                # the human to call when DRI + coach are both stuck
---

# okrdev config

okrdev runs on itself. This repo *is* the okrdev framework, and it uses okrdev to plan its own
development — the first and most honest test of whether the method survives contact with real
work.

- Solo project: Alex is the sole DRI and, being the whole company, his own backstop. When the
  coach and Alex are both stuck, the escalation is "sleep on it, decide tomorrow."
- Level 1 (method only). No Level 2 rails yet — that's itself a candidate for an early KR.
- Check-ins are async/solo: Alex runs `/okrdev:checkin` whenever the week's work is done.
