---
name: triage
description: Walk every parked idea — open okrdev:parked GitHub issues plus the parking lot's Captured section — to a decision (promote, archive, or side-quest with a time-box); then check the side-quest budget. Use when the user says "triage the parking lot", "triage the parked issues", "go through my parked ideas", "clean up the ideas list", or as the parking-lot step of a weekly check-in.
---

# Triage

Give every parked idea a decision — the inbox is open `okrdev:parked` issues plus
`okrdev/PARKING_LOT.md`'s Captured section — then sweep the open side-quests and report the
box-hours budget. Triage is the other half of the capture deal:
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
   - Gather the second inbox: when `gh` is authed and the repo's remote is GitHub, list the
     open parked issues with `gh issue list --label okrdev:parked --state open`. Two inboxes
     — issues and the file's Captured section — one ledger: every item gets the same
     three-way decision, and every decision lands in the file.
   - Find the active cycle: the file in `okrdev/okrs/` with `status: active`. No active cycle
     (Level 0, or between cycles) is fine — triage still runs; it just changes what "promote"
     means (step 4).
   - Note whether you were invoked from a check-in. If so, decisions also get mirrored into
     the check-in file (step 6).

2. **Report the state before deciding anything.** Two lines: how many items are in the
   inboxes (open `okrdev:parked` issues plus Captured lines, oldest first — ideas shouldn't
   rot at the bottom), and the side-quest budget: for each
   person, sum the `box:` hours of side quests they opened this ISO week (by the line's date)
   and compare to the weekly budget. Box-hours are a crude proxy for committed distraction
   time — say so — but it's the number everyone agreed to steer by. Quests still open from
   earlier weeks don't count against this week's budget; the step-5 sweep handles their
   staleness. If both inboxes are empty, say so, do the side-quest sweep (step 5), and be
   done in a minute.

3. **Walk every inbox item to a decision — issues and Captured lines alike.** Read the item
   back — one line, no elaboration — and ask: promote, archive, or side-quest? Three options, because each maps to a distinct
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
     check their budget from step 2, and move the line (for an issue item, write one) to
     `## Side quests` as
     `- [<today>] <idea> — @alex — box: <n>h — spent: 0h — status: open — notes: —` — the
     file's Side quests section stays the budget's source of truth, wherever the idea was
     captured. If the box would blow the weekly budget, say so plainly and ask anyway — you
     warn, you never block. If they proceed over budget, log it: at Level 1+, append a
     judgment-call line
     (`- <date> — <who> — <reason> — <branch/PR>`) to the `## Judgment calls` section of this
     week's check-in file at `okrdev/checkins/<cycle>/<yyyy-Www>.md`, creating it from the
     template if it doesn't exist. At Level 0, where there are no check-in files, record it
     in the item's `notes:` field instead.

   Three verbs make the 30-second reason faster (full lens in
   [../../docs/evidence.md](../../docs/evidence.md)): **buy** — a solved problem the market
   already sells; archive with "already solved elsewhere — adopt X" as the epitaph, the
   sharpest reason line there is ("duplicate of what CRM already does" is the house example).
   **Box** — keeps-the-lights-on work; box, as in: it gets one — a bounded budget (a
   side-quest time-box or the maintenance share), never open-ended investment — and it never
   auto-promotes to next-cycle candidacy on its own. **Build** — work only this team
   can do that a stakeholder of the mission would recognize as winning; that's what promote
   is reserved for. Reasons, not extra questions — the pace stays thirty seconds per item.

   Issue items get their decision recorded by closing the issue with a comment —
   `gh issue close <n> --comment "okrdev triage: promoted → KR1.3"`,
   `"okrdev triage: archived — <reason>"`, or `"okrdev triage: side-quest, box: 4h"` — and
   the decision line ALSO lands in the file's Promoted / Archived / Side quests section. The
   file is the single canonical, git-versioned ledger; issues are an inbox, not a second
   ledger. Inbox to zero, every triage: every swept `okrdev:parked` issue ends up closed,
   whatever the decision — a parked issue is never assigned, milestoned, or worked.

   If the human refuses to decide on an item, it stays in its inbox — the Captured line stays
   put, the issue stays open — deferral is an override like any other, and you never block. But keep count. When an item survives its third
   triage, say what you see: "Energy was high on July 13. You haven't missed it since.
   Archive it?" Undecided ideas cost a little attention every single week; that's the case
   for deciding.

4. **Date the decisions today.** Lines landing in Promoted, Archived, or Side quests carry
   today's date — these sections are a log of decisions, not of captures. Keep the idea text
   verbatim, issue titles included.

5. **Sweep the open side-quests.** For every `status: open` item in `## Side quests`:
   - Ask for a `spent:` update and write it.
   - Finished → `status: done` — and ask once at the close: "anything to show? a link, a
     screenshot, one line." Record it in `notes:`; "no" costs nothing, and the question is
     never asked mid-box. Demoable output is the strongest promotion argument at the next triage.
   - Box blown (`spent` at or past `box`, still open) → force a named decision: close it as
     done-enough, extend the box once with a reason in `notes:`, or promote it — a side-quest
     that keeps eating hours is evidently real work and should compete at planning like real
     work. Unbounded side-quests are just distractions with paperwork.

6. **Write the ledger — one batched commit or PR per triage, never one per item.** Update
   `okrdev/PARKING_LOT.md` with every decision from this sweep, then:
   - **Unprotected default branch** → commit directly, same mechanics as `/okrdev:park`'s
     file fallback (temporary worktree if you're on a working branch; commit message like
     `okrdev: triage — 2 promoted, 3 archived, 1 side-quest`).
   - **Protected default branch** → a small state PR: branch `okrdev/state-<date>-triage`,
     push, open a PR titled `okrdev: triage — <summary>` with a `KR:` line, then merge it
     immediately (`gh pr merge --squash`) — or enable auto-merge when required checks must
     run first. Because the write is batched, this costs ~one PR per week, not one per idea.

   If you were invoked from a check-in, also copy the decision lines into the `## Parking
   lot triage` section of this week's check-in file — the check-in is the ritual's record;
   the parking lot is the ledger.

7. **Close with a summary.** A few lines, no more: N promoted (and where), N archived, N
   side-quests sanctioned with total hours boxed, budget remaining per person, and what's
   left in the inboxes — ideally "nothing," file and issues both. If deferred items remain,
   name them, so leaving them parked was a decision someone made out loud.

The full protocol — why nothing in Captured gets worked on, box-hours budgeting, what happens
to Promoted items at cycle boundaries — lives in
[../../docs/parking-lot.md](../../docs/parking-lot.md).
