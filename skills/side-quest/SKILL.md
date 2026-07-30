---
name: side-quest
description: Sanction a distraction on the spot — time-box it, log it in the parking lot, and note what the human is stepping away from. Use when someone wants to chase an off-OKR idea right now ("I know it's not a KR but I want to build this today"), says "side quest", asks to spend an afternoon on something off-plan, wants to extend or close a running side quest, or asks how much side-quest budget is left this week.
---

# Side quest

The parking lot only works if it isn't a straitjacket. Sometimes a human wants to chase the
shiny thing today, and the honest move is to sanction it — with a box, on the record — rather
than watch them do it anyway and call it something else. A side quest is a distraction that
said its name out loud. Your job is to make that take under a minute.

## Preflight

1. Check that `okrdev/config.md` exists. If not, okrdev isn't installed — point at
   `/okrdev:install` and stop. Read `side_quest_box_hours_per_week` from the config frontmatter
   (default 4).

2. Check that `okrdev/PARKING_LOT.md` exists — every install level has it, including Level 0.
   If it's somehow missing from an otherwise-installed repo, recreate it with the four standard
   sections (Captured / Side quests / Promoted / Archived) and carry on.

3. This skill works at every level. No active cycle is fine — Level 0 users get boxes and logs
   too; they just don't get the "stepping away from" reminder, because there's nothing on
   record to step away from yet.

## Check it's actually a side quest

4. One quick classification pass — not an interrogation, one question at most:
   - Serves an active KR? Then it's just work. Tag it `KR: <id>` and go — no box needed.
   - Something's broken and users are hurting? That's `emergency`. Tag it, go, and it gets its
     post-hoc review ("was it? what did it protect?") at the next check-in.
   - A bugfix, config change, or small cleanup? That's `maintenance`. Say so in one line, go.
   - None of the above, and they want to do it anyway? Side quest. Continue.

## Sanction it

5. **Find or capture the idea.** Check both inboxes: the Captured section of
   `okrdev/PARKING_LOT.md`, and — when `gh` is available — open `okrdev:parked` issues
   (`gh issue list --label okrdev:parked --state open`). A file line gets used as-is; an
   issue gets its close-with-comment in step 9, once the box is set. If it's parked nowhere,
   capture it now at the standard 10-second bar: one line, `energy` (high/med/low — how
   excited they are), `effort` (S/M/L — gut call). Do not start analyzing the idea; analysis
   is how a 10-second capture becomes a 40-minute detour.

6. **Set the box.** Required, always — a side quest without a time-box is just drift with
   permission. Ask for hours, or propose from the effort call: S ≈ 2h, M ≈ 4h. If it's an L,
   challenge it: that's not a side quest, that's a project wearing a costume. Offer to leave it
   in Captured as a promotion candidate for the next `/okrdev:plan` instead.

7. **Check the budget.** Sum the `box:` hours on side quests this person opened this ISO week
   and compare against `side_quest_box_hours_per_week`. Budgets are in box-hours because
   "10% of your time" is unmeasurable and box-hours are already captured. If this quest would
   blow the budget, say so plainly, once. If they proceed anyway, that's an override — proceed
   immediately and log one line in the Judgment calls section of this week's check-in file
   (`okrdev/checkins/<cycle>/<yyyy-Www>.md`, created from the skeleton if missing):
   `- <date> — <who> — <reason> — <branch/PR>`. At Level 0 there are no check-in files; put
   the overage note in the quest's `notes:` field instead.

8. **Say what they're stepping away from.** If there's an active cycle, name their KRs and
   their focus lines from the latest check-in — one or two lines, maximum. The point is a
   conscious trade, not guilt: "You're boxing 4h away from KR1.2, which is at 0.4 confidence.
   Still want it?" is coaching. Anything longer is a lecture, and lectures get this skill
   uninvoked by week three. No active cycle: skip this entirely, and at most note that
   `/okrdev:plan` is what gives side quests something to be traded against.

9. **Log it.** Move the line from Captured to the Side quests section (or add it fresh):

   ```markdown
   - [2026-07-13] <idea> — @alex — box: 4h — spent: 0h — status: open — notes: —
   ```

   If the idea arrived as an `okrdev:parked` issue, close the issue with the decision as a
   comment (`gh issue close <n> --comment "okrdev triage: side-quest, box: 4h"`). The
   quest still gets its line in the file — the Side quests section stays the budget's
   source of truth; issues are an inbox, not a second ledger.

10. **Write the ledger.** On an unprotected default branch, commit directly — never switch
    the human's working branch; use a temporary worktree from `origin/<default>`, commit
    there, push `HEAD:<default>`, and remove the worktree. On a protected default branch,
    open a small state PR — branch `okrdev/state-<date>-<slug>`, PR titled `okrdev: <what>`
    with a `KR:` line — and merge it immediately (`gh pr merge --squash`, or auto-merge when
    required checks must run first). That's ~30 seconds instead of ten; on-the-spot quests
    are rare enough not to matter. Narrate in plain words if the human is non-technical
    ("logging this in the shared parking lot").

11. **Go.** Confirm in one line — "Boxed at 4h, logged. Go." — and offer to help build it. A
    sanctioned side quest is real work, and it's the one place in this framework where the work
    is allowed to be purely fun. Any PRs or commits it produces get tagged `KR: side-quest`.

## During and after the quest

12. **Track the box.** Update `spent:` as the work happens, or when they report back. When
    spent reaches the box, remind them once — advisory, like everything here. Then it's their
    call:
    - Done? Set `status: done`, final `spent:`, one line in `notes:` if there's anything worth
      remembering.
    - Not done but worth more? Extend the box — new `box:` value, extension noted in `notes:`,
      and the extra hours count against this week's budget like any other box.
    - Not done and not worth more? Stop, set `status: done` with `notes: box spent, parked the
      rest`, and park the remainder as a fresh capture (same path as `/okrdev:park` — an
      `okrdev:parked` issue, or a Captured line as the fallback). Thursday's triage decides
      its fate, same as any idea.
    Never block. The box has exactly the authority everything else here has: it's written
    down, and it comes up at the next check-in when triage reviews `spent:` against `box:`.

13. **Budget queries.** When someone asks "how much side-quest budget do I have left?", sum
    this week's `box:` hours for them, subtract from the config budget, and answer in one line
    ("2h of 4h left this week"). If they just want the number, give just the number.
