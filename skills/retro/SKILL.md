---
name: retro
description: Score a finished OKR cycle against the rubric, challenge inflated and sandbagged scores, extract three lessons into okrdev/LESSONS.md, and close the cycle as scored (or abandoned). Use when a cycle is ending or has ended, someone says "run our retro", "score the quarter", "close out this cycle", or a dead cycle needs an honest burial before planning the next one.
---

# Cycle retro

You are running okrdev's retro: score every KR against the rubric, make the scores survive
scrutiny, turn the cycle into exactly three lessons, and close the file. Budget ~60 minutes
of human time. Like check-ins, you pre-draft everything — the humans' time goes to judgment,
not arithmetic. The ritual script is in docs/rituals.md; the scoring rules in docs/method.md
(both ship with this plugin).

## 1. Preflight

1. **Is okrdev installed?** Check for `okrdev/config.md` in the repo root. Missing → say so
   and point at `/okrdev:install`. Stop.
2. Read `okrdev/config.md` frontmatter for `level` and `cycle_length`.
3. **Level 0?** There are no cycles at Level 0 — nothing to retro. Say so and point at
   `/okrdev:plan`, which handles the upgrade to Level 1 when they're ready.
4. **Find the cycle.** Look in `okrdev/okrs/` for the file with `status: active` (or the
   cycle the human named).
   - No active cycle and no file at all → nothing to score; point at `/okrdev:plan`.
   - Only `scored` or `abandoned` files → the last cycle is already closed. Summarize its
     LESSONS.md block in two lines and point at `/okrdev:plan`.
   - Active cycle whose `end` date is still weeks away → confirm intent: "Scoring now closes
     the cycle early — right call if it's truly done, otherwise wait." Proceed only on a
     clear yes.

## 2. The abandoned path — offer it when it's honest

If the cycle is dead — check-ins stopped weeks ago, the team pivoted, nobody can say what the
numbers are — don't force a scoring theater. Offer to close it unscored:

1. Flip the cycle file to `status: abandoned`.
2. Append one dated line to `okrdev/LESSONS.md`: the cycle id, `abandoned`, and the reason in
   the team's own words.
3. Commit, and point straight at `/okrdev:plan`.

Two minutes, no inquisition. Systems die by silent decay, not by decision — an honest
abandonment is a decision, and it beats a zombie cycle blocking the next real one.

## 3. Pre-draft the scoring sheet — before engaging the humans

Read, compute, and assemble everything first:

- **The cycle file**: every KR with its type, DRI, baseline, target, milestone anchors
  (`Notes:`), `Revised:` blocks, and `Status: dropped` markers.
- **Every check-in in `okrdev/checkins/<cycle>/`**: build a per-KR confidence history
  (needed for sandbag detection and for confronting score/confidence mismatches), pull
  evidence from "What moved," and collect the cycle's Judgment calls — overrides, emergency
  post-hoc reviews, mid-cycle revisions.
- **Check-in adherence**: check-ins held ÷ weeks in the cycle (e.g. `11/13`). This goes in
  LESSONS.md; a low number is usually the first lesson writing itself.
- **Proposed scores**: pre-fill wherever the actual is already in evidence. For each metric
  KR you'll need the actual number — pull it from check-ins if recorded, otherwise flag it
  for the DRI to bring.
- **Cycle-wide tallies**: emergency count (more than 2 in a cycle gets said out loud — the
  one unaudited escape hatch is where all gaming funnels), side-quest box-hours spent, and
  maintenance share if computable from PR/commit `KR:` tags.

## 4. Score, KR by KR

Walk the sheet with the room (solo mode: with the one human — you argue the other side).
For each KR, the DRI states the actual; you apply the rubric:

- **Metric KRs**: `score = clamp((actual − baseline) / (target − baseline), 0, 1)`.
  The formula exists so retros don't degenerate into vibes. No actual number available →
  that's not a scoring problem, it's an instrumentation lesson; score conservatively from
  what evidence exists and record why in `Notes:`.
- **Milestone KRs**: score the highest anchor fully reached — 0.3, 0.7, or 1.0 as defined at
  planning. No partial credit between anchors; the anchors were agreed precisely so nobody
  has to negotiate 0.55 versus 0.6 today.
- **Dropped KRs** (`Status: dropped`): not scored. One line on why they were dropped —
  they're reviewed in step 6, not averaged into anything.
- Record each score in the KR's `Score:` field.

While scoring, challenge in both directions:

- **Inflation.** A score must trace to evidence. "0.8 — what's the actual?" is the whole
  move. Milestone claims replay their anchors: "0.7 claimed — show the thing in its 0.7
  state," in its own medium — a preview for code; the signed contract, the published page,
  the hire started for everything else. The anchors from planning are the demo script.
  Confidence history is your mirror: a KR that sat at 0.9 all cycle and scores 0.4
  (or the reverse) means the check-ins were theater — name it, kindly.
- **Sandbagging.** The signals: target hit before 60% of the cycle had elapsed, plus
  confidence ≥0.9 flat from week one. Flag it as an input to next planning's target-setting,
  not as an accusation. **Never flag a KR whose 1.0 anchor was the only passing state** — a
  binary outcome scoring 1.0 is the outcome happening, and naive 1.0-flagging just teaches
  people to score 0.93.
- **Confidence collapses.** Any KR that scored far below the confidence it carried into the
  final weeks gets a root-cause note in its `Notes:` before the retro moves on. This is where
  a broken promise now surfaces: not from a type column, but from the gap between what the
  DRI believed in week ten and what landed. Root-cause the plan and the system, not the
  person — policed people game classifications; coached people use them.
- **Certainties that slipped in.** Any KR that never dropped below 0.9 and scored 1.0 without
  a binary anchor was not a goal — it was maintenance in a KR costume. Name it as an input to
  next planning, where the "goal or certainty?" check exists to catch it earlier.

## 5. Report the results

One list. Every KR is a stretch, so there are no types to separate and nothing to average
across a boundary that no longer exists.

Calibration to say out loud:

- **A healthy cycle** lands well around 0.6–0.7. All 1.0s → targets were too soft (see the
  sandbag flags). Everything ≤0.3 → the plan was fantasy; next planning should assume less
  throughput, and LESSONS.md is how it will know.

## 6. Revisions and judgment calls review

Walk every `Revised:` block and every dropped KR, one question each: was it the right call,
made early enough — or did the revision quietly convert a miss into a win? Re-scoping to
declare victory is inflation with paperwork.

Then the cycle's judgment calls, assembled in step 3: overrides (what pattern do they show?),
emergencies (were they? what did they protect? recurring emergencies mean something upstream
is broken), side-quests (did the box-hours budget hold?), and evidence re-class lines,
each replayed against the cycle's end state: "expected evidence was the signed contract —
did it arrive?" This is the framework keeping
its core promise — the coach never blocks, it remembers, and the retro is where the memory
gets read.

## 7. Extract exactly three lessons

Three, not five — scarcity forces ranking. Lessons are about the system, not people. The
test for each: would it change what next cycle's planning session does? If not, it's an
observation, not a lesson. Good ones sound like: "we can't score what we don't instrument —
baseline KRs first," or "our average is 0.45; plan for 60% of the throughput
we feel like we have."

## 8. Write it down

Append a dated block to `okrdev/LESSONS.md` (append-only — never edit prior blocks; they're
the planning record):

```markdown
## 2026-Q3 — scored 2026-10-01
Scores: KR1.1 0.7, KR1.2 0.4, KR2.1 1.0, KR2.2 0.8 — avg 0.725. (KR1.3 dropped W33.)
Confidence collapse: KR1.2 rode 0.8 into W12 and scored 0.4 — root cause in cycle file.
Check-in adherence: 11/13 weeks.
Revisions: KR1.1 target raised in W31 (early sandbag flag) — right call.
Lessons:
1. <lesson>
2. <lesson>
3. <lesson>
```

Then close the cycle file: every `Score:` filled, root-cause notes on confidence collapses
in place, and `status: active` → `status: scored`.

Commit both files. If the repo runs cycle-file changes through PRs (it did at planning),
open one titled `Retro: <cycle>` — same audit-trail rationale, and it can merge immediately:
the retro conversation was the review. Otherwise commit directly to main. With non-technical
humans, narrate the step in plain words as you do it.

## 9. Roll forward

- Point at `okrdev/PARKING_LOT.md`'s Promoted section — those items plus the fresh
  LESSONS.md block are next planning's inputs, and they're ready now.
- Propose `/okrdev:plan`. Momentum matters: a scored cycle with no successor is how teams
  drift back to unexamined work. If the team needs a breather, fine — but get the planning
  session on the calendar before the room empties.

## Async mode

When the team can't meet: interview each DRI separately about their KRs (actuals, proposed
scores, root causes), merge into one scoring sheet, flag any KR where your rubric result and
the DRI's proposal disagree, and resolve those with the objective's DRI before writing
anything. The LESSONS.md block notes it was run async — a retro nobody attended together is
still a retro, but the record should say so.
