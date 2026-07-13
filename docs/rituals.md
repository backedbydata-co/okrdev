# Rituals

okrdev has four rituals and one recovery script. Each one is written here as a runnable script:
what the coach prepares, what the humans decide, what gets written where. If a ritual stops
earning its minutes, cut the ritual — but run these as written first, because most OKR ceremony
bloat comes from humans doing clerical work the coach should have done before anyone showed up.

| Ritual | Cadence | Real time | Skill |
|--------|---------|-----------|-------|
| Cycle planning | Once per cycle, before it starts | ~90 min | `/okrdev:plan` |
| Weekly check-in | Weekly | ~15 min | `/okrdev:checkin` |
| Parking-lot triage | Inside the check-in (or standalone) | ~5 min | `/okrdev:triage` |
| Cycle retro | Once per cycle, at the end | ~60 min | `/okrdev:retro` |
| Missed-cadence catch-up | Whenever a check-in is >10 days overdue | ~2 min | built into `/okrdev:checkin` |

The division of labor never changes: **the coach drafts, computes, and remembers; the humans
argue, decide, and own.** Every number in these scripts is wired to a behavior — confidence that
triggers nothing and check-ins nobody reads are theater, and okrdev refuses theater.

A Level 0 install (parking lot only — see [adoption.md](adoption.md)) runs exactly one ritual:
weekly triage via `/okrdev:triage`, standalone. Everything else requires an active cycle.
Definitions for every rule referenced below — KR quality, scoring, confidence, health metrics,
classification — live in [method.md](method.md). This doc is the choreography.

---

## Cycle planning (~90 minutes)

**When:** before the cycle starts — the last week of the old cycle or the first days of the new
one. Quarterly cycles (`2026-Q3`) by default; six-week cycles (`2026-C4`) if you've configured
them in `okrdev/config.md`.

**Who:** everyone who will be a DRI this cycle. Solo founders plan alone with the coach as
sparring partner — the script is the same, the arguing is just faster.

**Output:** `okrdev/okrs/<cycle>.md` with `status: draft`, opened as a PR, flipped to
`status: active` on merge. The merge freezes KR ids (see [method.md](method.md) on why
renumbering is forbidden).

### Before the session — the coach's homework

The coach prepares a complete straw-man cycle file before the humans meet. Planning that starts
from a blank page spends its first hour generating instead of deciding; a straw man means the
90 minutes go to the argument, which is the only part humans are needed for.

The coach reads, in order:

1. **`okrdev/MISSION.md`** — the alignment anchor. If it doesn't exist or is stale, planning
   stops here until it's fixed. The coach cannot answer "aligned to what?" without it.
2. **`okrdev/LESSONS.md`** — every prior retro. This is where planning gets its skepticism:
   last cycle's scores, adherence stat, and lessons are the evidence against this cycle's
   optimism ("last cycle you averaged 0.4 on aspirational KRs; this draft assumes double the
   throughput — what changed?").
3. **The Promoted section of `okrdev/PARKING_LOT.md`** — ideas that survived triage and were
   marked as next-cycle candidates. These earned a hearing; they get one.
4. **Brownfield only: the repo itself.** `git log`, open issues, recent PRs. A codebase adopting
   okrdev mid-life has implicit priorities already visible in what people have been shipping.
   The scan turns them into explicit straw-man candidates so the first cycle reflects reality
   instead of aspiration.

From these it drafts 1–3 candidate objectives, each with 2–4 candidate KRs, candidate health
metrics, and suggested DRIs — in the canonical cycle-file format, marked clearly as a draft.

### The script

1. **Context (10 min).** The coach summarizes the mission, last cycle's results (or the
   brownfield scan), and the promoted ideas. No decisions yet — shared facts first, so the
   argument that follows is about priorities, not about what happened.
2. **Argue the objectives (25 min).** One to three, no more. Each objective is qualitative,
   inspiring, and time-bound, and each gets exactly one human DRI. The coach's job here is
   subtraction: every objective beyond the first must justify the focus it steals. If the
   room wants five, the coach asks which two would hurt most to drop — those are the real ones.
3. **Argue the KRs (30 min).** Two to four per objective, one DRI each. This is where the coach
   pushes back hardest, per the quality rules in [method.md](method.md):
   - **Outcome, not output.** "Launch the referral program" only survives paired with a KR that
     measures whether anyone uses it.
   - **Baseline → target, stated.** `baseline: unknown` is allowed — but only paired with an
     instrumentation task, and "instrument X and establish a baseline" is itself a valid
     first-cycle KR. New businesses can't state numbers they don't have; they can commit to
     getting them.
   - **Sandbag check, at the source.** A target barely above the baseline's existing trend gets
     challenged now, not discovered at the retro. Retro-only sandbag detection is too late to
     change anything.
   - **Type declared.** Each KR is `committed` (expected score 1.0; a miss requires a root-cause
     note) or `aspirational` (0.7 ≈ success). The coach challenges an all-aspirational cycle —
     some things, like payroll and uptime, are not stretch goals — and an all-committed one,
     which usually means nobody's reaching.
   - **Milestone KRs get anchors now.** If a KR isn't a metric, define what 0.3, 0.7, and 1.0
     look like during planning. Anchors invented at the retro are scored by mood.
4. **Health metrics (10 min).** Pick 2–4 for the cycle — monitored, not targeted, each with a
   red line and a source. Every volume or speed KR must name the quality metric it could break,
   either in its `Notes:` or in the health table. This is the Goodhart defense: for every target
   you push, something watches what the pushing might damage.
5. **Confidence and close (10 min).** Every KR starts at confidence 0.5 — a good stretch KR is
   a coin flip at kickoff. If a DRI wants to start at 0.9, that's a planning smell: either the
   target is soft or the KR is already done. The coach writes the final file with
   `status: draft`.
6. **PR and activate (5 min).** The coach opens a PR with the cycle file. Everyone who owns
   something approves it. Once approvals are in, the coach pushes a final commit on the PR
   branch flipping `status: draft` → `active`, then merges — merge is go-live. Ids are now
   frozen; from here, any change to a KR goes through the amendment protocol
   ([method.md](method.md)) — a PR with a `Revised:` block preserving the original text. The
   PR isn't bureaucracy: it's the one moment the whole plan is reviewed as a unit, and it gives
   the cycle a written record of who agreed to what.

Time estimates are guides, not gates. But if planning routinely runs past two hours, the straw
man wasn't good enough — that's coach feedback, not human failure.

---

## Weekly check-in (~15 minutes, for real)

**When:** same time every week. The file is `okrdev/checkins/<cycle>/<yyyy-Www>.md` — one per
ISO week, e.g. `okrdev/checkins/2026-Q3/2026-W29.md`. Deterministic paths mean the coach, the
gate, and the humans always agree on where this week's record lives.

**Who:** every DRI. Solo and async variants below.

**Output:** the completed weekly file, committed directly to main (state writes bypass branch
protection for `okrdev/**` — a 15-minute ritual can't wait on CI).

The fifteen-minute claim is load-bearing. Check-ins die when they cost more than they return,
and they cost too much when humans spend the meeting reconstructing what happened. So the rule
is absolute: **the coach pre-drafts the entire file before any human engages.**

### Before the session — the coach's homework

1. Create the weekly file from the template
   ([../templates/okrdev/checkins/checkin.md](../templates/okrdev/checkins/checkin.md)) at its
   deterministic path.
2. Pre-fill the **KR confidence** table with last week's numbers as `Prev`.
3. Pre-draft **What moved** from `git log` and merged PRs since the last check-in.
4. Pre-compute the **Drift check**: substantive PRs and commits since last check-in with no
   `KR:` line and no match against last week's focus (the full 4-step mechanics are in
   [ai-coach.md](ai-coach.md)).
5. Pull current values for the **Health metrics** table.
6. Note anything queued for **Judgment calls** review — in particular, any `emergency` work
   since last week, which is due its post-hoc line.

Humans arrive to a file that is 80% written. Their 15 minutes are the 20% that requires
judgment.

### The script

1. **Wins first.** The coach opens by asking each attendee for one win, and writes them into
   `## Wins` — the first section of every check-in, on purpose. Accountability without
   celebration dies by week four; a ritual that opens with drift and blockers becomes a ritual
   people dread, then skip, then delete.
2. **KR confidence.** Walk the table. Each DRI updates their numbers (0.0–1.0) with a one-line
   evidence note. The coach enforces the triggers — this is where confidence stops being theater:
   - **Below 0.5 two weeks running** → the coach forces a named decision: re-scope, re-staff,
     kill, or accept-the-miss. The decision is logged in Judgment calls. Hoping is not on the
     list.
   - **Unchanged 3+ weeks** → the DRI writes one line of evidence for why the number is right.
     A confidence that never moves is a confidence nobody is checking.
   - **≥0.9 early in the cycle** → early-sandbag flag. The coach proposes raising the target,
     logged as a revision if accepted. (Same if the target is actually hit before 60% of the
     cycle has elapsed.)
3. **What moved.** Review the pre-draft; DRIs add non-code work — sales calls, ops changes,
   marketing pushes. This section is the canonical ledger for non-code KR progress; in most
   real businesses the work that moves KRs never touches a PR, and if it isn't recorded here
   it didn't happen as far as the retro is concerned.
4. **What's blocked.** One line per blocker, each with a next action and an owner. A blocker
   without an owner will be a blocker next week too. The coach volunteers for anything
   mechanical: red CI, stale reviews, merge conflicts (its unblocking duties are contractual —
   see [ai-coach.md](ai-coach.md)).
5. **Health metrics.** Compare each to its red line. A breach is discussed now, not noted for
   later: a crossed red line can pause the KR pushing on it until the metric recovers. This is
   the moment the pairing from planning pays off.
6. **Drift check.** The coach presents its pre-computed orphans — as questions, never
   accusations ("this PR doesn't map to anything — what was it?"). Answers usually take
   seconds: it's maintenance, it belongs to KR2.1 and the tag was forgotten, or it's real
   drift and gets a judgment call. Note the coach will already have raised anything sensitive
   privately with the DRI in-session before it appears here — the check-in records decisions,
   not demerits.
7. **Judgment calls.** Review the append-only log: overrides since last week (already logged
   as they happened), any mid-cycle revisions, and the **emergency audit** — every piece of
   work classified `emergency` since last check-in gets its post-hoc line: *was it actually an
   emergency, and what did it protect?* Thirty seconds each. The one unaudited escape hatch is
   where all gaming funnels, so this one stays audited. If emergencies are recurring (more
   than ~5% of PRs, or more than two this cycle), the coach says so.
8. **Parking-lot triage.** Run the triage script (next section). Five minutes.
9. **Focus for next week.** Each DRI names 1–3 items, each mapped to a KR. This section feeds
   next week's drift check — focus items are one of the two things orphaned work is matched
   against — so vague focus lines buy vague accountability.
10. **Commit.** The coach commits the file to main and confirms in one line.

Two standing signals the coach reads out when they fire, without ceremony: the **maintenance
share** (if maintenance-classified work exceeds ~30% of PRs, the coach asks whether that's
underinvestment being paid down or a KR-shaped hole — a prompt, not an alarm; the proxy is
crude and the coach says so) and the confidence-trigger decisions above.

### The 3-line degraded mode

Some weeks are travel, launches, or flu. A check-in of confidence deltas plus one focus line
per DRI is **explicitly valid**:

```markdown
## KR confidence
KR1.1 0.6→0.7 (activation up), KR1.2 0.5→0.5, KR2.1 0.4→0.3 (vendor slipped)

## Focus for next week
alex: close vendor decision (KR2.1)
```

A thin check-in preserves the streak, the confidence history, and the drift baseline. A skipped
one starts the decay that kills the system. Do not let the perfect ritual beat the three-line
one.

### Solo mode

Same script, with the coach as the other party. It asks for your win and doesn't accept "none."
It challenges your confidence numbers against the evidence — the flat 0.6 you've reported three
weeks running gets the evidence rule applied just as it would in a room. It argues the other
side at triage. Ten minutes, not fifteen: you're not waiting on anyone. The frontmatter's
`attendees:` is just your name (or omitted).

The point of solo mode is that the ritual survives having no audience. Most solo founders quit
OKRs because the accountability loop had nobody on the other end. Here there is someone — it
just isn't a human, and it writes everything down.

### Async mode

When the team can't meet, the coach runs the check-in as a series of interviews:

1. The coach pre-drafts the file as usual.
2. It interviews each DRI separately, whenever they're available that week: win, confidence
   updates with evidence, additions to What moved, blockers, their focus lines. Each DRI also
   triages the Captured items they parked.
3. It merges everything into the single weekly file. Per-DRI sections mean contributions never
   collide — the file format was designed for exactly this.
4. It posts a one-paragraph digest to each DRI: what the others reported, any cross-DRI
   blockers, anything that needs a live conversation.

Anything that needs an argument — a confidence-trigger decision that affects two DRIs, a
contested triage call — is flagged for the next live session rather than resolved by the coach.
The coach merges records; it doesn't arbitrate.

---

## Parking-lot triage (~5 minutes, inside the check-in)

Triage is step 8 of the check-in, but it's runnable standalone with `/okrdev:triage` — and at
Level 0 it's the whole ceremony, run weekly on its own. The full capture-and-triage protocol is
in [parking-lot.md](parking-lot.md); this is the in-ritual script.

**The rule that makes the parking lot work: every item in Captured gets a decision, every
week.** Capture is only safe as an alternative to acting on impulse if captured ideas reliably
get their hearing. A parking lot that silently accumulates becomes a graveyard, and people stop
parking things in graveyards — they go back to just building the idea.

For each Captured item, in order, one of three calls:

1. **Promote.** It's worth real work. Either it maps to a current KR (move it to Promoted with
   the KR id: `→ KR2.1`) or it's marked `next-cycle candidate` and will be read at the next
   planning session. Promotion is not permission to start today — it's a routing decision.
2. **Archive.** Not worth it, or not now, with a one-line reason. Archiving is a success, not a
   failure: the idea got its hearing and lost on the merits. The reason line matters because
   ideas recur, and "archived 2026-07: duplicate of what CRM already does" saves the same
   ten-minute debate in October.
3. **Side-quest.** Worth doing, doesn't serve a KR, small enough to time-box. It moves to the
   Side quests section with a `box:` (hours) and burns against the budget — default 4 box-hours
   per person per week, configurable in `okrdev/config.md`, summed from the `box:` fields. If
   the box would blow the budget, it waits or shrinks. The coach reports budget remaining as
   part of the call.

Thirty seconds per item is the pace. The `energy` and `effort` fields captured with each idea
exist for this exact moment — a high-energy small item and a low-energy large one usually
decide themselves. If an item genuinely can't be decided in thirty seconds, that's a signal
it's really a planning question: mark it `next-cycle candidate` and move on.

While you're in the section, the coach also reads out open side-quest boxes (`spent:` vs
`box:`) and closes any that are done or expired.

---

## Cycle retro (~60 minutes)

**When:** the cycle's final week, replacing that week's check-in. Score before you plan — the
retro's outputs are planning's inputs, and running them back-to-back (retro, break, planning)
works well if calendars allow it.

**Who:** every DRI. Solo mode works the same way, with the coach challenging where a peer would.

**Output:** every KR scored in the cycle file, cycle `status: scored`, and a dated block
appended to `okrdev/LESSONS.md`.

### Before the session — the coach's homework

The coach pre-computes proposed scores for every metric KR (the formula is deterministic),
assembles the confidence history per KR, collects every `Revised:` block and dropped KR,
computes the check-in adherence stat (check-ins held / weeks in cycle), and pulls the cycle's
judgment-call and emergency totals. Humans arrive to a scored straw man and spend the hour on
the contested cases.

### The script

1. **Score every KR (30 min).** Per the rubric in [method.md](method.md):
   - **Metric KRs:** `clamp((actual − baseline) / (target − baseline), 0, 1)`. The formula is
     the formula; the discussion is about whether `actual` is measured honestly, not about
     what the number feels like.
   - **Milestone KRs:** scored against the 0.3 / 0.7 / 1.0 anchors defined at planning. If the
     anchors are missing, that's this cycle's first lesson.
   - **Committed and aspirational are reported separately, never averaged together.** A 1.0 on
     a committed KR and a 0.7 on an aspirational one are both successes; blending them into
     "0.85" destroys both signals.
   - **Committed misses get a root-cause note.** Not blame — a sentence on what broke, because
     a committed KR was a promise and promises that break silently break again.
   - The coach challenges in both directions. **Inflation:** "0.9 — show me the number."
     **Sandbagging:** an aspirational KR that hit early while confidence sat high and flat from
     week one gets named as a sandbag candidate — the lesson is about next cycle's targets, not
     this cycle's score. A committed KR scoring 1.0 is never flagged; committed KRs are
     *supposed* to score 1.0, and flagging them just teaches people to report 0.93.
2. **Revisions review (10 min).** Walk every `Revised:` block and every `Status: dropped` KR.
   Was each amendment a legitimate response to new information, or a target quietly walking
   toward the actual? The audit trail exists to be read exactly once, here.
3. **Adherence and process (5 min).** The coach reports the check-in adherence stat and the
   cycle's judgment-call, override, and emergency totals. A cycle with 6/13 check-ins didn't
   fail because the KRs were wrong — that's a lesson about cadence, and it goes in the file.
4. **Three lessons (10 min).** Exactly three — fewer means nobody thought, more means nobody
   will read them. Each lesson is a sentence a future planning session can act on ("we can't
   land more than one committed KR per DRI while doing support rotation"), not a platitude
   ("communicate better").
5. **Write and close (5 min).** The coach appends the dated block to `okrdev/LESSONS.md` —
   cycle id, scores summary (committed and aspirational separate), the three lessons, the
   adherence stat, the revisions review — and flips the cycle file to `status: scored` via PR.
   Promoted parking-lot items marked `next-cycle candidate` roll forward automatically:
   planning reads them next.

`LESSONS.md` is append-only and planning reads it first. The retro is the only mechanism that
makes cycle N+1 smarter than cycle N; skip it and you're not iterating, you're just restarting.

---

## The missed-cadence catch-up (~2 minutes)

Systems like this die by silent decay, not by decision. Nobody decides to stop doing check-ins;
a week gets skipped, then the next one is awkward because of the gap, then the awkwardness is
the reason. The catch-up script exists to make the gap cost two minutes instead of the system.

**Trigger:** the most recent check-in is more than 10 days old while a cycle is `active`. The
coach raises it at the start of any session — before other work, in one line, no guilt:
"Last check-in was W27, we're in W29. Two-minute catch-up, or should we close this cycle?"

### The catch-up script

1. The coach pre-drafts a single check-in file for the **current** week, spanning the whole
   gap: What moved and the Drift check are computed since the last check-in, however long ago
   that was. Missed weeks are not back-filled — the gap stays visible in the file dates, and
   that's fine. The record is honest, not decorative.
2. The human gives confidence updates (deltas since the last recorded numbers) and one focus
   line per DRI. The 3-line mode is the expected shape here, not the fallback.
3. Anything that piled up in Captured gets a fast triage pass.
4. The coach commits the file. The streak is repaired; next week is a normal check-in.

See [../examples/acme-fitness/checkins/2026-Q3/2026-W36.md](../examples/acme-fitness/checkins/2026-Q3/2026-W36.md)
for a real one: two skipped weeks, spanned and recovered in under ten minutes.

### When the cycle is actually dead

Sometimes the answer to the coach's question is "honestly, that cycle stopped mattering weeks
ago." Then close it: `status: abandoned` in the cycle file, no scoring, no post-mortem
ceremony, and start fresh with `/okrdev:plan` whenever you're ready. An abandoned cycle
recorded in ten seconds is worth more than a zombie cycle maintained out of guilt — and far
more than a quiet uninstall. The one thing the coach will ask for is a single line on why, in
`okrdev/LESSONS.md`, because the next planning session deserves to know.
