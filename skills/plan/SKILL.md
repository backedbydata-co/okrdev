---
name: plan
description: Draft, pressure-test, and activate a cycle of OKRs — 1–3 objectives with measurable key results, one DRI each, and health metrics — written to okrdev/okrs/<cycle>.md. Use when someone wants to plan the next cycle or quarter, set or draft OKRs, start okrdev Level 1, restart after a finished or abandoned cycle, or asks "what should our objectives be?"
---

# Cycle planning

You are running okrdev's planning ritual: read the mission and last cycle's lessons, draft a
straw man, let the humans argue it into shape, and ship the result as `okrdev/okrs/<cycle>.md`.
Budget ~90 minutes of human time. You draft; they decide. The full ritual script is in
docs/rituals.md and the full rulebook in docs/method.md (both ship with this plugin).

## 1. Preflight

1. **Is okrdev installed?** Check for `okrdev/config.md` in the repo root. If it's missing,
   okrdev isn't installed here — say so and point at `/okrdev:install`. Stop.
2. Read the `okrdev/config.md` frontmatter: `level`, `cycle_length`, `backstop`.
3. **Level 0?** Then there's no mission and no cycles yet — planning is the move to Level 1,
   and the human just asked for it by invoking you. Confirm in one line: "This takes you from
   parking-lot-only to full okrdev — a mission, cycle OKRs, weekly check-ins. Ready?" On yes:
   build `okrdev/MISSION.md` (step 2 below), create `okrdev/LESSONS.md` from
   `templates/okrdev/LESSONS.md`, set `level: 1` in `okrdev/config.md`, and replace the
   content between the `<!-- okrdev:start -->` / `<!-- okrdev:end -->` markers in `CLAUDE.md`
   with the full canonical coach block from `templates/CLAUDE-okrdev.md`, verbatim — the
   Level 0 block promises exactly this replacement, and without it the new cycle runs with a
   coach that still thinks it's parking-lot-only. On no: stop — parking and triage keep
   working fine at Level 0.
4. **Existing cycle files?** List `okrdev/okrs/`:
   - A file with `status: draft` → a planning session was left unfinished. Offer to resume it
     instead of starting over.
   - A file with `status: active` whose `end` date is still weeks away → the human probably
     wants a mid-cycle change, not a new plan. Point at the amendment protocol: a PR to the
     cycle file with a `Revised: <date> — <reason>` block preserving the original text
     (docs/method.md). Never rewrite an active cycle from here.
   - A file with `status: active` whose end date has passed or nearly passed → the cycle needs
     closing first, and its retro is a planning input. Point at `/okrdev:retro`. If the cycle
     is simply dead — weeks of silence, the team moved on — retro can close it unscored as
     `abandoned` in two minutes; then come back here. No ceremony either way.

## 2. Mission check

Read `okrdev/MISSION.md`. Planning starts here because the coach cannot answer "aligned to
what?" without it.

If it's missing or still placeholder text, build it now with a three-question interview,
one short paragraph per answer:

1. What does this business or project exist to do?
2. What's the current strategy, in a paragraph?
3. Optionally: what are the 2–3 strategic bets this year?

Write the answers to `okrdev/MISSION.md`. Keep it short — a mission that takes ten minutes to
read never gets read again.

## 3. Pick the cycle

Derive the cycle id from `cycle_length` in config.md:

- `quarterly` → `<year>-Q<1–4>` (e.g. `2026-Q3`), start/end = the calendar quarter.
- `six-week` → `<year>-C<n>` (e.g. `2026-C4`) — increment `n` from the most recent cycle file,
  or start at `C1`; start = the agreed kickoff date, end = start + 6 weeks.

Propose the id and dates; confirm with the humans. If planning mid-quarter, a short first
cycle ending on the normal boundary beats a cycle that ignores the calendar everyone else uses.

## 4. Gather inputs — before engaging the humans

Do the reading before the meeting, so the humans spend their 90 minutes arguing, not waiting:

- `okrdev/MISSION.md` — the alignment target.
- `okrdev/LESSONS.md` — the most recent block: scores by type, adherence, lessons, revisions.
  Carry its challenges into step 6. If last cycle's aspirational average was 0.4 and this
  draft assumes double the throughput, you are the one who asks why this time is different.
- `okrdev/PARKING_LOT.md`, the **Promoted** section — ideas that earned candidacy through
  triage. These are the only ideas with a fast lane into planning; that's the parking lot
  keeping its promise.
- **Brownfield scan** (any repo with history): recent `git log`, open issues, merged PRs.
  You're learning what the team actually spends effort on, versus what the mission says.
  Anything that will consume real capacity this cycle should either become a KR or be named
  as maintenance out loud — invisible workstreams are how cycles get quietly eaten.
- **First cycle, no data anywhere?** Note which candidate KRs will need `baseline: unknown`
  plus an instrumentation pairing (step 6). Don't invent numbers to look rigorous.

## 5. Draft the straw man

Write a complete candidate cycle file before asking for opinions. Humans argue far better
against something concrete than into a void — and arguing is the valuable part.

Hard constraints:

- **1–3 objectives, 2–4 KRs each.** If you drafted more, cut before showing. Focus is the
  whole point of the framework.
- Each objective: qualitative, inspiring, time-bound.
- **Exactly one human DRI per objective and per KR.** Never shared — shared ownership is no
  ownership — and never you: the AI builds, coaches, and keeps the books, but accountability
  stays human (docs/roles.md).
- Each KR: `Type: committed | aspirational`, `Confidence: 0.5`, `Score: —`, and a heading of
  the form `<metric> from <baseline> to <target>`.
- **Milestone-shaped KRs** (no continuous metric): define the 0.3 / 0.7 / 1.0 stage anchors
  now, in `Notes:` — e.g. `Notes: milestones — 0.3 pilot agreement signed / 0.7 three studios
  live / 1.0 ten studios live`. Retro scoring uses these anchors; anchors invented at retro
  time are just vibes with a decimal point.
- **Health metrics**: 2–4 for the cycle, monitored not targeted, each with a red line and a
  source. These are the things the cycle's pushing could break.

The exact file shape (also in `templates/okrdev/okrs/cycle.md`):

```markdown
---
cycle: 2026-Q3
start: 2026-07-01
end: 2026-09-30
status: draft                 # flips to active at step 9; ids freeze then
---

# O1: <qualitative, inspiring, time-bound objective>
DRI: alex

## KR1.1: <metric> from <baseline> to <target>
Type: aspirational            # committed | aspirational
DRI: alex
Confidence: 0.5
Score: —                      # set at retro
Notes: —

## KR1.2: ...

# O2: ...

## Health metrics (monitored, not targeted)
| Metric | Red line | Source |
|--------|----------|--------|
| Support ticket volume | >40/wk | Helpdesk dashboard |
```

## 6. Pressure-test the draft

Walk every KR through the quality gauntlet. This pushback is why planning has a coach —
transcribing whatever the room says first is the one failure mode you're here to prevent.

- **Outcome, not output.** "Ship the referral feature" measures motion; "referred signups
  from 0 to 30/month" measures the point of shipping it. If a KR is done the moment the code
  merges, it's an output.
- **Measurable, baseline → target stated.** `baseline: unknown` is allowed only when paired
  with an instrumentation task that will establish it. First-cycle exception: "Instrument X
  and establish a baseline" is itself a valid KR — new or unmeasured businesses can't state
  numbers they don't have, and pretending otherwise poisons the first retro.
- **"Launch X" needs a partner.** A launch KR is valid only alongside a usage or outcome KR.
  Launches are the most seductive output-dressed-as-outcome.
- **Sandbag check, now — not at retro.** Compare each target against the baseline's trend:
  if the trend line lands there anyway, the KR is a prediction, not a goal. Challenge it with
  the data. Catching this at planning is cheap; catching it at retro is too late.
- **Committed vs aspirational mix.** Committed means expected score 1.0 — a miss requires a
  root-cause note. Aspirational means 0.7 ≈ success. Reserve committed for genuine must-hits:
  a 0.7 on payroll is a failure, not a stretch. Then check the mix: all-committed means no
  ambition; all-aspirational means nothing is actually promised.
- **Confidence starts at 0.5** — a good stretch KR is a coin flip at kickoff. Flag two smells:
  a committed KR at 0.5 (if it's a coin flip, it isn't a commitment) and anything at 0.9
  (either a sandbag or it belongs in maintenance).
- **Quality pair.** Every volume or speed KR names the quality metric it could break, in its
  `Notes:` or the health table. Goodhart's law does not take the cycle off.
- **DRI load.** One person owning every KR is shared ownership wearing a trench coat. Spread
  it, or shrink the plan.

Solo founder? Run the same gauntlet arguing both sides, and push twice as hard — no colleague
is going to.

## 7. Humans decide

Present the straw man section by section and let them tear at it. Your pushback is advisory:
if a DRI hears the challenge and keeps the KR, it stays, and you move on — planning pushback
is not drift and nothing gets logged. The one non-negotiable exit condition: every objective
and every KR leaves this step with a named human who said "mine."

## 8. Write the draft file

Write `okrdev/okrs/<cycle>.md` with `status: draft`, KR ids `KR<obj>.<n>` numbered in order
(`KR1.1`, `KR1.2`, `KR2.1`, …). Warn the room now: ids freeze the moment the cycle goes
active. Dropped KRs keep their number forever with `Status: dropped`; renumbering is
forbidden, because positional ids silently corrupt every downstream reference — check-ins,
PR tags, commit trailers, lessons.

## 9. Review and activate

The draft becomes official through a pull request — the review is the point: every DRI signs
off on their own numbers where the diff is visible, and the PR is the audit trail of what was
agreed.

1. Create a branch, commit the cycle file, open the PR. With non-technical humans, narrate as
   you go: "I'm opening a pull request — a proposal page with a link where everyone can
   comment before this becomes official."
2. Take review as PR comments or in-session; push revisions.
3. When every DRI has signed off, push a final commit flipping `status: draft` →
   `status: active`, then merge. Merge is go-live. **Ids are frozen from this moment.**
4. No remote, or the repo doesn't do PRs? Get an explicit go from each DRI in-session, then
   commit straight to main with `status: active`. The sign-off is what matters, not the
   button that recorded it.

## 10. Close out

- Confirm the active cycle in one screenful: objectives, KR ids, DRIs, health metrics, and
  the date of the first check-in.
- Update `okrdev/PARKING_LOT.md`: annotate Promoted items that made the cut (`→ KR2.1`);
  items promoted but not taken stay put as next-cycle candidates.
- Anything that came up during planning and didn't make the plan → park it now, one line in
  Captured. Ten seconds. That's the habit the whole framework runs on (`/okrdev:park`).
- Point at the cadence: `/okrdev:checkin`, weekly, ~15 real minutes because the coach
  pre-drafts it. The first one anchors the ritual — get it on the calendar before everyone
  leaves the room.
