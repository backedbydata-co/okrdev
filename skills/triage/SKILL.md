---
name: triage
description: Walk every Captured idea in the okrdev parking lot to a decision — promote, archive, or side-quest with a time-box — and check the side-quest budget. Use when the user says "triage the parking lot", "go through my parked ideas", "clean up the ideas list", or as the parking-lot step of a weekly check-in.
---

# Triage

Give every idea in `okrdev/PARKING_LOT.md`'s Captured section a decision, sweep the open
side-quests, and report the box-hours budget. Triage is the other half of the capture deal:
"park it" is only an acceptable answer because every parked idea gets a fair hearing within a
week. Skip triage for a few weeks and the parking lot stops being a rudder and becomes a
graveyard — and people stop parking.

Usually this runs inside `/okrdev:checkin` as the "Parking lot triage" section. It also runs
standalone, any day, at any install level — a Level 0 install is exactly a parking lot plus
this ritual.

Pace matters: seconds to a minute per item, not a debate. An item that needs real discussion
has answered its own question — it's a planning topic. Promote it as a next-cycle candidate
and argue about it at planning, where arguing is the job.

## Procedure

1. **Check the install and load context.**
   - No `okrdev/` directory → point at `/okrdev:install` and stop.
   - `okrdev/PARKING_LOT.md` missing or missing its section headings → repair it to the
     canonical format (see the format reference in [../park/SKILL.md](../park/SKILL.md)),
     preserving any existing lines, then continue.
   - Read `okrdev/config.md` for `side_quest_box_hours_per_week` (default 4).
   - Find the active cycle: the file in `okrdev/okrs/` with `status: active`. No active cycle
     (Level 0, or between cycles) is fine — triage still runs; it just changes what "promote"
     means (step 4).
   - Note whether you were invoked from a check-in. If so, decisions also get mirrored into
     the check-in file (step 6).

2. **Report the state before deciding anything.** Two lines: how many items are in Captured
   (oldest first — ideas shouldn't rot at the bottom), and the side-quest budget: for each
   person, sum the `box:` hours of side quests they opened this ISO week (by the line's date)
   and compare to the weekly budget. Box-hours are a crude proxy for committed distraction
   time — say so — but it's the number everyone agreed to steer by. Quests still open from
   earlier weeks don't count against this week's budget; the step-5 sweep handles their
   staleness. If Captured is empty, say so, do the side-quest sweep (step 5), and be done in
   a minute.

3. **Walk every Captured item to a decision.** Read the line back — one line, no elaboration —
   and ask: promote, archive, or side-quest? Three options, because each maps to a distinct
   claim about the idea: it serves an objective, it doesn't, or it's worth a bounded detour.

   - **Promote** — the idea earns real work.
     - Maps to an existing KR in the active cycle: move it to `## Promoted` as
       `- [<today>] <idea> → KR2.1`. The KR's DRI decides when it gets built; promotion is
       alignment, not a start date.
     - Worth pursuing but not this cycle: `- [<today>] <idea> → next-cycle candidate`.
       Planning reads Promoted before drafting, so nothing promoted gets lost.
     - Wants to be a *new* KR mid-cycle: rare, and never silent. That's a mid-cycle amendment
       — a PR to the cycle file per the amendment protocol in
       [../../docs/method.md](../../docs/method.md). Challenge it first: if it can wait for
       planning, it's a next-cycle candidate. Mid-cycle scope addition is how focused cycles
       die.
     - No active cycle: every promote is `→ next-cycle candidate` (read: planning candidate).
       When a few of these accumulate, say so — that's the signal to run `/okrdev:plan`.
   - **Archive** — move to `## Archived` as `- [<today>] <idea> — reason: <one line>`. The
     reason is required; "no longer excited" is a perfectly good one. Frame it right:
     archiving is the parking lot working as designed. Most ideas should die here, on
     purpose, with a one-line epitaph instead of a half-built feature.
   - **Side-quest** — the human wants to just do it, bounded. Ask for a time-box in hours,
     check their budget from step 2, and move the line to `## Side quests` as
     `- [<today>] <idea> — @alex — box: <n>h — spent: 0h — status: open — notes: —`. If the
     box would blow the weekly budget, say so plainly and ask anyway — you warn, you never
     block. If they proceed over budget, log it: at Level 1+, append a judgment-call line
     (`- <date> — <who> — <reason> — <branch/PR>`) to the `## Judgment calls` section of this
     week's check-in file at `okrdev/checkins/<cycle>/<yyyy-Www>.md`, creating it from the
     template if it doesn't exist. At Level 0, where there are no check-in files, record it
     in the item's `notes:` field instead.

   If the human refuses to decide on an item, it stays in Captured — deferral is an override
   like any other, and you never block. But keep count. When an item survives its third
   triage, say what you see: "Energy was high on July 13. You haven't missed it since.
   Archive it?" Undecided ideas cost a little attention every single week; that's the case
   for deciding.

4. **Date the decisions today.** Lines moved to Promoted, Archived, or Side quests carry
   today's date — these sections are a log of decisions, not of captures. Keep the idea text
   verbatim.

5. **Sweep the open side-quests.** For every `status: open` item in `## Side quests`:
   - Ask for a `spent:` update and write it.
   - Finished → `status: done`.
   - Box blown (`spent` at or past `box`, still open) → force a named decision: close it as
     done-enough, extend the box once with a reason in `notes:`, or promote it — a side-quest
     that keeps eating hours is evidently real work and should compete at planning like real
     work. Unbounded side-quests are just distractions with paperwork.

6. **Write and commit.** Update `okrdev/PARKING_LOT.md` and commit directly to the default
   branch — same mechanics as `/okrdev:park` (temporary worktree if you're on a working
   branch; state-PR fallback if protection rejects the push; commit message like
   `okrdev: triage — 2 promoted, 3 archived, 1 side-quest`). If you were invoked from a
   check-in, also copy the decision lines into the `## Parking lot triage` section of this
   week's check-in file — the check-in is the ritual's record; the parking lot is the ledger.

7. **Close with a summary.** A few lines, no more: N promoted (and where), N archived, N
   side-quests sanctioned with total hours boxed, budget remaining per person, and what's
   left in Captured — ideally "nothing." If deferred items remain, name them, so leaving
   them parked was a decision someone made out loud.

The full protocol — why nothing in Captured gets worked on, box-hours budgeting, what happens
to Promoted items at cycle boundaries — lives in
[../../docs/parking-lot.md](../../docs/parking-lot.md).
