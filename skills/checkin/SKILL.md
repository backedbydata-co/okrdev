---
name: checkin
description: Run the weekly okrdev check-in — pre-drafts the confidence table, "what moved" from git and merged PRs, the drift check, and health metrics before the humans arrive, then walks them through the parts only they can do. Use when someone says "run our check-in", "weekly check-in", "let's do the OKR check-in", "time for the checkin", when a check-in is overdue and the user agrees to catch up, or when a single DRI wants to file their async contribution to this week's check-in.
---

# Weekly check-in

The check-in is fifteen minutes because you do the homework first. Everything computable gets
pre-drafted from git, PRs, and last week's file before you engage anyone. The humans only do
what humans must: adjust confidence, make triage calls, name next week's focus. If this ritual
costs more than its minutes, it dies — protect the fifteen.

## Preflight

1. Check that `okrdev/config.md` exists. If not, okrdev isn't installed in this repo — say so
   and point at `/okrdev:install`. Stop.

2. Read `okrdev/config.md`: `level`, `checkin_cadence`, `side_quest_box_hours_per_week`, and
   `backstop`. If `level: 0`, there is no cycle and no check-in ritual yet — that's by design.
   Offer the two things that make sense instead: triage the parking lot now (`/okrdev:triage`),
   or draft a first cycle (`/okrdev:plan`). Stop.

3. Find the active cycle: the file in `okrdev/okrs/` whose frontmatter says `status: active`.
   - A `draft` but nothing active → planning isn't finished; point at `/okrdev:plan`. Stop.
   - Nothing at all → point at `/okrdev:plan`. Stop.
   Read the cycle file fully: objectives, KR ids, types, DRIs, current confidence, the health
   metrics table, and the `start`/`end` dates. Compute how far through the cycle you are —
   `(today − start) / (end − start)` — you'll need it for the sandbag triggers.

4. Compute this week's file path. ISO week via `date +%G-W%V` (today that gives something like
   `2026-W29`). The path is deterministic: `okrdev/checkins/<cycle>/<yyyy-Www>.md`, e.g.
   `okrdev/checkins/2026-Q3/2026-W29.md`. Deterministic paths are the point — overrides logged
   on a Tuesday and async contributions on a Thursday land in the same file without anyone
   coordinating.

5. If the file already exists, do not clobber it. It may hold judgment calls logged mid-week or
   another DRI's async section. Load it, fill only what's empty, and append — never rewrite
   someone else's lines.

## Handle gaps first

6. Find the most recent **held** check-in in `okrdev/checkins/<cycle>/` — the newest file whose
   KR confidence table has at least one KR row. Skip files that have one but left it empty:
   those are week files created to log a judgment call or pre-drafted and never held, and
   counting them as check-ins is how a skipped ritual silences its own alarm (the definition
   and the reasoning are in [rituals.md](../../docs/rituals.md)). If it's more than 10 days
   old (or there is none and the cycle started more than 10 days ago), offer the gap-spanning
   catch-up before anything else: one "what moved" covering the whole gap, one confidence pass,
   two minutes total. No week-by-week archaeology, and no guilt trip — systems die by silent
   decay, and the recovery has to be cheaper than the shame of the lapse. Note the span in the
   What moved section ("covers W27–W29").

7. If the cycle is effectively dead — the end date has passed unscored, or the team says they
   quietly stopped — offer to close it without ceremony: set `status: abandoned` in the cycle
   file, then point at `/okrdev:plan` for a fresh start. A dead cycle closed honestly is worth
   more than a zombie one maintained out of duty.

## Pre-draft everything

8. Before engaging any human, draft the full file (create it from the canonical skeleton below
   if it doesn't exist):

   ```markdown
   ---
   cycle: 2026-Q3
   week: 2026-W29
   attendees: [alex, jordan]     # omit or single-name for solo mode
   ---

   ## Wins

   ## KR confidence
   | KR | DRI | Prev | Now | Δ | Evidence/note |
   |----|-----|------|-----|---|---------------|

   ## What moved

   ## What's blocked

   ## Health metrics
   | Metric | Red line | Now | OK? |

   ## Drift check

   ## Judgment calls

   ## Parking lot triage

   ## Focus for next week
   ```

   Fill it in this order:

   a. **KR confidence table.** One row per KR (skip `Status: dropped` ones). `Prev` = last
      check-in's `Now`; for a KR's first appearance use the cycle file's `Confidence:` value.
      Leave `Now` blank — that's the human's call, not yours, and the reading you take in (g)
      doesn't change that: a reading reaches the Evidence/note cell and never this column.
      While you're here, scan the last three check-ins for flat streaks and early-high values,
      and note any KR whose Evidence/note entries have been narrative-only ("on track," "feels
      close") for all three — reading only the DRI's own half of each cell, because a
      `measured` clause is your sentence and scanning your own writing tells you nothing —
      then grep the Judgment calls of every check-in this cycle
      (`okrdev/checkins/<cycle>/*.md`) for an evidence re-class line on each such KR ("KR2.1
      moves through negotiation — expected evidence: the signed contract"). The
      `expected evidence:` marker is the grep contract — every re-class line carries it,
      demoable-slice answers included ("KR1.2 — expected evidence: clickable export flow").
      A re-classed KR is never asked the narrative-floor question again this cycle. You'll
      enforce the triggers in step 11.

   b. **What moved.** Ground truth, best effort by environment: `git log` on the default branch
      since the last check-in date (e.g. `git log --since="2026-07-06" --format='%h %s%n%b'`),
      plus merged PRs when `gh` is available
      (`gh pr list --state merged --limit 100 --json number,title,body,mergedAt`, filtered to
      the window). Extract `KR:` lines from PR bodies and commit messages using the canonical
      grammar — first line matching
      `/^KR:\s*(([0-9]{4}-[QC][0-9]+\/)?(KR)?[0-9]+\.[0-9]+|side-quest|maintenance|emergency)\s*$/im`,
      first match wins. Group the summary by KR, in plain language.

   c. **Drift check.** Match every substantive change from (b) against the active KR ids and
      the last check-in's "Focus for next week". Substantive = a new feature or more than about
      an hour of new-capability work; bugfixes, config, docs, and small refactors are
      maintenance and don't count as drift. Orphans — substantive changes with no `KR:` line
      and no focus match — go in the Drift check section phrased as questions ("PR #84 added a
      referral widget — which KR was that for?"), never accusations. At Level 2, include
      anything currently wearing a `needs-kr` label.

   d. **Health metrics.** Copy the table from the cycle file. Fill `Now` from any source you
      can actually read (dashboards you have access to, queries you can run); leave the rest
      for the humans. Mark `OK?` honestly.

   e. **Counts for the taxonomy signals.** Tally PRs/commits in the window by classification.
      Note any `emergency`-tagged work (each needs a post-hoc line, step 14) and the
      maintenance share (step 14 again).

   f. **Open-PR bridge report.** For each attendee: `gh pr list --state open` with checks,
      review requests, and labels. You are the notification bridge — non-technical DRIs never
      see GitHub notifications. Keep only what's actionable: preview ready to click, gate
      warning, review request gone stale, red CI.

   g. **Take a reading on every KR.** Go and look at where each KR actually stands, so the
      confidence walk argues with a fact instead of a memory. You are not inventing the
      measurement: milestone anchors and the measurement source already live in the KR's
      `Notes:` (that's what the field is for), so the work is reading what's written and
      fetching what it names — the ledger you just built in (b), the check-in history, `git`,
      `gh`, the filesystem, a dashboard you can open. Four rules make a reading worth having.

      **Name the source beside the number, every time.** "0 of 17 merged PRs in `<repo>` carry
      `KR: 1.3`" is a sentence that exposes its own blind spot; "4" is not. A wrong number that
      says where it came from gets corrected in ten seconds; a bare number gets believed. This
      is the ordinary case, not the edge one — histories move between repos, work lands in a
      system you can't read, and the query you can run is rarely the question the KR asks.

      **Hand over candidate lists, not totals, wherever the unit is a judgment.** Merged PRs
      are not improvements and commits are not progress, so a coach that reports "5 of 8" has
      quietly decided what counts. Show what you found and give the unit question back to the
      DRI, whose call it is.

      **Say "no reading from here" out loud, and write nothing.** Most KRs worth having measure
      something no repo can see: a stopwatch, a signed contract, another team's week. Absence
      belongs in the room and never in the file — a column that reads "—" for the same KRs
      every week is a scoreboard of what the coach happens to be able to count, and a cycle
      that watches one long enough starts writing KRs to fill it.

      **Never propose the number.** You may not say "so that's about a 0.5." The reading goes
      in front of the DRI; the DRI names the confidence.

      A reading rides the existing Evidence/note cell, prefixed `measured <yyyy-mm-dd>:` and
      sitting ahead of the DRI's own words — the same grep-contract idiom as `expected
      evidence:` in (a), so everything that reads the human's evidence can tell the two apart.
      It gets no new column, no new section and no new cycle-file field: that whole class is
      ruled out in [evidence.md](../../docs/evidence.md), and nothing here is special enough
      to reopen it. The step only ever *adds* a detection — it retires no question the humans
      were already asked, which is the standing rule for automating a measurement source in
      [method.md](../../docs/method.md#amendments--the-mid-cycle-change-protocol).

      One thing you must not do: widen a query until it returns something. If a KR's source
      can't be reached without guessing, report what you actually ran and what came back, then
      offer the DRI a one-line measurement source for that KR's `Notes:`. That is an edit to an
      active KR — it goes through the revision protocol as a PR with a `Revised:` block, never
      silently, not even to make the coach more useful.

## Run the ritual

9. **Wins first.** Open by asking each attendee for one win — before status, before numbers.
   Accountability without celebration dies by week four. Write one line per attendee. When a
   win is code-shaped and you already hold the preview URL from 8f, offer the link into the
   win line — offer, never require, and a win with no artifact ("closed the vendor, verbal
   yes") is written with identical weight. Never mention the absence of a demo.

10. **Deliver the bridge report** from 8f in a line or two per person, plain words only ("your
    pricing-page proposal has a preview link ready — want the click-test steps?"). Skip it
    entirely if nothing is actionable.

11. **Walk the confidence table.** Each DRI sets `Now` for their KRs; you fill `Δ`. New KRs
    default to 0.5 — a good stretch KR is a coin flip at kickoff. Read out (g)'s reading for a
    KR before its DRI names anything, and name the KRs that had no reading just as plainly.
    Where the reading and the DRI's instinct disagree you've found the reason this step exists:
    ask the question and let them answer it ("the ledger has two of six weeks held with the
    cycle a third gone — what makes 0.8 still right?"). Their reconciliation, in their words,
    is the evidence line. Then enforce the triggers, because a confidence number that changes
    nothing is theater:
    - **Below 0.5 two consecutive weeks** → force a named decision, one of: re-scope,
      re-staff, kill, accept-the-miss. Talk it through, then log the decision in Judgment
      calls. Don't let the conversation end with "let's see how next week goes" — that's what
      last week said.
    - **Unchanged 3+ weeks** → the DRI writes one line of evidence in the table's
      Evidence/note column. A flat 0.6 with no evidence isn't confidence, it's a screensaver.
      Your `measured` clause never satisfies this one, however good it is: the trigger tests
      whether the DRI is still looking, and a sentence you wrote tests only whether you are.
    - **≥ 0.9 early** (from week one, or the target already hit before 60% of the cycle) →
      raise the early-sandbag flag and propose raising the target. If accepted, that's a
      mid-cycle revision: a PR to the cycle file with a `Revised: <date> — <reason>` block
      preserving the original text. Never edit an active KR silently, not even to make it
      harder.
    - **Narrative-only evidence 3 check-ins running, at ≥0.5** (from your 8a scan, minus any
      KR re-classed in any of this cycle's Judgment calls) → ask once, generatively: "anything I can
      click, a number I can pull — or what would the first demoable slice be?" Accept a
      one-line answer — "nothing clickable; this KR moves through calls, next artifact is the
      signed contract" is complete, and itself evidence. Record it as a Judgment-calls line
      ("KR2.1 moves through negotiation — expected evidence: the signed contract"): that line
      is the permanent re-class, and it's what next week's 8a scan reads. Once per KR per
      cycle — never twice. Fires only here, inside the walk; below 0.5 the named-decision
      trigger owns the KR instead. When the unchanged-3+-weeks rule trips on the same KR
      the same week — flat confidence and narrative evidence usually travel together — ask
      only this question: its answer is the evidence line, satisfying both. Evidence ranks
      per docs/evidence.md: clickable or measurable beats narrated.

12. **What moved.** Present your pre-draft, then ask each DRI what moved that git can't see —
    sales calls, ops fixes, a partnership conversation, a pricing page rewrite in some CMS.
    Add a line each, mapped to a KR where one applies. This section is the canonical ledger
    for non-code KR work; in most real businesses the work that moves the number isn't a PR.

13. **What's blocked, then health metrics.** Capture blockers and do something about them now:
    translate red CI into plain language and propose the fix, draft the nudge for a stale
    review, hand over preview URLs with click-test steps. If you and the DRI are both stuck,
    invoke the backstop from `okrdev/config.md`. Then walk the health metrics table. A crossed
    red line can pause the KR pushing on it — raise it, let the humans decide, and record the
    decision in Judgment calls. This is the Goodhart defense; it only works if a breach
    actually interrupts something.

14. **Drift check and Judgment calls.** Go through the orphans conversationally, one at a
    time, before anything lands in the file — private first, always. Each gets classified
    (`KR: <id>`, `side-quest`, `maintenance`, `emergency`) or acknowledged as drift, and the
    decision is recorded in the DRI's own words. Record decisions, not demerits. Then:
    - Every `emergency` since the last check-in gets its post-hoc line: was it an emergency,
      and what did it protect? If emergencies are recurring (more than ~5% of PRs or more than
      2 this cycle), say so — the one unaudited escape hatch is where all gaming funnels.
    - If maintenance exceeds ~30% of PRs by count, ask whether that's chronic underinvestment
      surfacing. It's a prompt, not an alarm — the proxy is crude, and you should say so.
    - Overrides logged mid-week are already in this section; read them back so they were seen.

15. **Parking lot triage.** Run the triage over both inboxes (same procedure as
    `/okrdev:triage`): open `okrdev:parked` issues when `gh` is available
    (`gh issue list --label okrdev:parked --state open`), plus every item in the Captured
    section of `okrdev/PARKING_LOT.md`. Each gets a decision — promote (to a KR or a
    next-cycle candidate), archive with a one-line reason, or sanction as a side quest with a
    time-box. Issue items get closed with the decision as a comment; every decision also
    lands in the file's ledger sections, which stay canonical. Check open side quests'
    `spent:` against `box:`, and each person's box-hours opened this ISO week against the
    budget in config. Every item gets asked; a refusal to decide is a deferral the coach
    counts (third survival gets named, per the triage skill). The section exists so ideas get
    decided on a cadence instead of on impulse — both inboxes to zero, every week.

16. **Focus for next week.** Each DRI names 1–3 items, each mapped to a KR. This is what next
    week's drift check matches against, so vague focus lines make next week's drift check
    useless — push for specific ones.

## Write and commit

17. Assemble the file at the deterministic path, and write it as one batched state write —
    one commit or PR per check-in, never one per item. On an unprotected default branch,
    commit directly: if you're on a working branch, never stash or switch it (the human may
    have uncommitted work) — use a temporary worktree (`git worktree add` from
    `origin/<default>`), commit the file there, push `HEAD:<default>`, and remove the
    worktree. On a protected default branch, open a small state PR: branch
    `okrdev/state-<date>-<slug>`, push, PR titled `okrdev: <what>` with a `KR:` line, then
    merge it immediately (`gh pr merge --squash`) — or enable auto-merge when required checks
    must run first. Because writes are batched by ritual, that costs about one PR a week.
    (The actor bypass in the stack's branch-protection script is an optional convenience, not
    the assumed path.) Narrate what you're doing in plain words for non-technical attendees
    ("saving this to the shared record").

    The pre-draft is a draft, and it stays out of the repo until every `Now` is filled. A file
    carrying KR rows *is* a held check-in by definition — it's the marker staleness and the
    confidence mirror both read — so a pre-draft committed with the column blank tells the
    tripwires this week happened and tells the mirror the cycle's confidences are empty. Hold
    it in the session and write once, here.

18. Mirror each KR's final `Now` confidence into the cycle file's `Confidence:` field, in the
    same commit or state PR, or a follow-up state write. This is a scribe duty, like writing `Score:` at
    retro — it keeps the cycle file current and is exempt from the revision protocol, which
    governs targets and baselines, not bookkeeping fields.

19. Close with one line: biggest confidence move, anything on fire, next check-in date. Done
    means done — no action-item ceremony beyond what's already in Focus and Judgment calls.

## Modes

- **Solo mode.** One attendee (frontmatter `attendees` omitted or single-name). You are the
  other party: ask for the win anyway, challenge flat confidence, argue the other side of every
  triage call. The ritual's value is the argument; without a teammate, you're it.
- **Async mode.** DRIs can't meet. Interview each one whenever they show up (they just run
  `/okrdev:checkin`); each contributes their own confidence rows, wins line, non-code moves,
  and focus lines. Sections are per-DRI so appends never collide. Pre-draft the shared sections
  on first touch; run triage with the first DRI who can make the calls, deferring items that
  aren't theirs to decide. The file is complete when everyone has contributed or the week ends.
- **Three-line mode.** Explicitly valid: confidence deltas plus one focus line per DRI, nothing
  else. Offer it when someone is rushed — a degraded check-in filed beats a perfect one skipped.

## What you never do

Never guilt-trip a missed week. Never write drift to the file before discussing it. Never edit
an active KR outside the revision protocol. Never block — if a human overrides anything here,
proceed immediately, confirm conversationally, and log one line in Judgment calls:
`- <date> — <who> — <reason> — <branch/PR>`.

Never carry another business's detail into the file. The reading in step 8g reaches into
whatever the DRI's week contained, so what lands here is how okrdev was used, anonymized, with
the gap marked — `(local read, anonymized)` in an Evidence/note cell, "details stay out of this
file by the partition rule" in What moved — and never names, figures, metric units, prices,
customer detail, or a hash-reference, repo name or path belonging somewhere else. Redact your
own draft; don't ask. The rule is [evidence.md](../../docs/evidence.md#the-partition).
