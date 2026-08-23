# The method

This is the reference for the okrdev OKR system: every rule, its exact mechanics, and why it
exists. If you want the meeting scripts, read [rituals.md](rituals.md). If you want the coach's
side of the contract, read [ai-coach.md](ai-coach.md). This document is the rulebook they both
implement.

The system is deliberately small. One cycle file, one check-in file per week, one parking lot,
one lessons file — all markdown in your repo under `okrdev/`. Everything else in this document
is rules about what goes in those files and what the numbers mean.

## Cycles

A cycle is the unit of commitment. You plan OKRs at its start, check in weekly, and score at
its end.

**Length.** Quarterly by default (`2026-Q3`), because it's what most businesses already think
in. Six-week cycles are supported (`2026-C4`) for projects moving at AI speed, where a quarter
is long enough to be wrong three times. Set `cycle_length` in `okrdev/config.md`.

**Storage.** One file per cycle at `okrdev/okrs/<cycle>.md` — for example
`okrdev/okrs/2026-Q3.md`. The format is in
[templates/okrdev/okrs/cycle.md](../templates/okrdev/okrs/cycle.md), and a fully worked example
in [examples/acme-fitness/okrs/2026-Q3.md](../examples/acme-fitness/okrs/2026-Q3.md).

**Statuses.** The frontmatter carries one of four:

| Status | Meaning |
|--------|---------|
| `draft` | Written at planning, under discussion, open as a PR. Everything is still negotiable. |
| `active` | The PR merged. KR ids are now frozen (see below). This is the working state. |
| `scored` | The retro ran and every KR has a score. The cycle is closed and feeds `LESSONS.md`. |
| `abandoned` | The cycle died — check-ins stopped, priorities changed wholesale, the company pivoted. Closed unscored. |

**The restart-without-ceremony path.** Systems like this die by silent decay, not by decision:
the check-ins stop, the cycle file goes stale, and six weeks later nobody wants to reopen it
because reopening feels like admitting failure. So okrdev makes abandonment a first-class,
one-line operation. Mark the cycle `status: abandoned`, run `/okrdev:plan`, start fresh. No
retro required, no post-mortem, no apology. A dead cycle honestly closed is worth more than a
zombie cycle nobody looks at — and the lower the cost of restarting, the more likely you restart
instead of quietly quitting the whole method.

**Focus limits.** One to three objectives per cycle, each with two to four key results. These
are hard limits, not suggestions. Focus is the entire point of the framework; a cycle with six
objectives is a backlog wearing a costume. If you can't cut to three, that's the planning
conversation — the coach will push back, and it should.

## Objectives

An objective is qualitative, inspiring, and time-bound: the thing that, if true at the end of
the cycle, would make the cycle a success. "Make onboarding something people recommend" is an
objective. "Increase activation rate to 40%" is not — that's a key result hiding upstairs.

Every objective has **exactly one human DRI** — a directly responsible individual who owns it
end-to-end. Not a committee, not a pair, not "the team." Shared ownership is no ownership: when
two people own an objective, each assumes the other is watching it, and by week four nobody is.
The DRI is not necessarily the person doing all the work, and not necessarily the domain
expert — AI fills skill gaps. The DRI is the person who answers for the number.
[roles.md](roles.md) covers what DRI ownership means in practice.

## Key results — anatomy

A key result is the measurable claim that proves the objective moved. Each KR in the cycle
file looks like this:

```markdown
## KR1.2: Weekly active studios from 46 to 70
DRI: jordan
Confidence: 0.5
Score: —                      # set at retro
Notes: quality pair — health table row "support ticket volume"
```

The heading states the metric, the baseline, and the target in one line. The fields below it
carry everything the system tracks:

- **DRI** — exactly one human, same rule and same reasoning as objectives. The objective's DRI
  and a KR's DRI can differ.
- **Confidence** — 0.0–1.0, updated at every check-in. After each check-in the coach mirrors
  the latest value back into this field — a scribe duty, like writing `Score:` at retro, exempt
  from the revision protocol (which governs targets and baselines, not bookkeeping fields).
  Mechanics below.
- **Score** — 0.0–1.0, set once, at the retro. It stays `—` all cycle.
- **Notes** — free text: the quality pair for volume/speed KRs, milestone anchors, measurement
  source, whatever the retro will need to score honestly.

KRs come in two shapes:

- **Metric KRs** state a number moving: baseline → target. These score by formula (below).
- **Milestone KRs** state a thing reaching a stage: "Payments migration live for all
  customers." These are legitimate — some work is genuinely stepwise — but they must define
  their scoring anchors *at planning*: what state earns 0.3, what earns 0.7, what earns 1.0.
  Written in `Notes:`. Anchors defined at planning are a rubric; anchors improvised at the
  retro are a negotiation, and negotiations drift toward whatever score feels comfortable.
  Phrase each anchor as an observable past-tense event — "first paying customer migrated,"
  "all studios off the old plan" — never as an implementation state ("backend deployed,"
  "integration mostly complete"). An event either happened or it didn't, so the anchor is
  binary at the retro; a state-phrased anchor reopens exactly the negotiation this rule
  exists to close. **A milestone KR without anchors is not a KR yet** — since okrdev dropped
  the `committed` type, anchors are the only place a must-land outcome can say so, and the
  coach refuses to close planning on a milestone KR whose 1.0 is undefined.

## Every KR is a stretch

There is one kind of KR. A score around **0.7 is success**; 1.0 every time means the targets
were never stretches. A good KR is close to a coin flip at kickoff — genuinely uncertain,
worth reaching for. Scores are reported as one list, because with one type there is nothing to
keep separate and nothing to average across.

**Why there is no `committed` type, recorded because okrdev shipped one through 0.9.0.** A
committed KR is by construction work you already know how to do — the retired wording conceded
it in as many words: *"all-committed means you're planning only what you already know how to
do."* That is precisely the work that does not need a goal wrapped around it. Payroll runs
because payroll runs. Writing it down as a key result and scoring it 1.0 at the retro adds
ceremony to a certainty and spends the scarcest input to planning — attention — on the half of
the work that was never in doubt.

The cost is not only ceremony. A goal set that contains its own certainties lets you answer
*"how do we hit this?"* with effort, because for some of the set that actually works. A goal
set of nothing but genuine stretches forces the harder and more useful question — **what would
have to be true?** — because no amount of pushing gets you there. Removing the certainties is
what makes the few real pathways visible, and it is the whole reason for the change.

**Promises do not disappear. They stop being goals.** Work that must land, that someone is
owed, that keeps the lights on, is still tracked — as `maintenance` in the work classification
below, or as a floor in whatever capacity model the DRI keeps outside this framework. A
commitment is a thing you do, not a thing you aim at, and okrdev deliberately does not model
it: a floor describes how a person's week is committed, not how the business is doing.

**What carries the load at the two places the type used to be read:**

- **Telling a co-owner what will land — `Confidence:`.** A live number updated at every
  check-in beats a binary frozen at planning, when you knew least. *"KR1.1 at 0.9, KR1.2 at
  0.4"* is a more honest promise than a type column, and it stays true as the cycle moves.
  The type was already losing this argument: a `committed` KR sitting at 0.5 was a documented
  smell, and it was the confidence telling the truth.
- **KRs where partial credit is meaningless — milestone anchors.** Some outcomes are binary in
  the world: a customer is billed or is not, the migration completed or it did not. That is a
  property of the metric rather than of a promise, and it is carried by writing anchors where
  only 1.0 passes. This is why the anchor rule above is enforced rather than encouraged.

## KR quality rules

The coach enforces these at planning (`/okrdev:plan`) — as pushback, not as a veto. Each rule
exists because its violation is the most common way OKRs rot.

1. **Outcome, not output.** "Ship the referral feature" is output — you can ship it and change
   nothing. "Referred signups from 0 to 50/month" is outcome. Output KRs let you succeed on
   paper while the business stands still, which is worse than failing, because you don't
   notice.

2. **Measurable.** If two reasonable people could disagree at the retro about whether the KR
   was hit, it isn't a KR yet. "Improve reliability" is a wish. "Sev-1 incidents from 4/quarter
   to ≤1" is a KR.

3. **Baseline → target, both stated.** A target without a baseline is unfalsifiable — "grow to
   1,000 users" means nothing if you don't record you're at 850. `baseline: unknown` is
   allowed, but only when paired with an instrumentation task in the same KR or cycle: you're
   allowed not to know the number yet, you're not allowed to plan on never knowing it.

4. **"Launch X" needs a usage pair.** A launch KR is acceptable only alongside a KR (or the
   same KR's second clause) measuring what happens after launch — adoption, usage, revenue,
   retention. Launches are the most seductive output-dressed-as-outcome pattern: the party
   happens, the metric doesn't.

**The first-cycle exception.** A brand-new or never-measured business can't state baselines it
doesn't have, and pretending otherwise produces fiction. So "Instrument X and establish a
baseline" is a valid, complete KR in a first cycle. It scores like a milestone KR. The point
of cycle one is often to make cycle two measurable — that's not a cop-out, it's the bootstrap.

5. **Every volume/speed KR names its quality pair.** If a KR pushes more or faster — more
   signups, more content, faster shipping, shorter response times — it must name, in `Notes:`
   or the health-metrics table, the quality metric it could break: churn, error rate, refund
   rate, support load. This is Grove's pairing rule and the working half of the Goodhart
   defense: any measure you push hard enough stops measuring what you meant. The pair is the
   tripwire.
6. **The customer's words, not the toolchain's.** Every noun phrase in a KR heading should
   survive being said to a customer or stakeholder of that objective. "Migrate lead data to
   Postgres" feels concrete but fails: Postgres is a noun the implementation chose, and the
   migration can land while leads still wait 9 days. "Lead-to-first-appointment time from
   9 days to 3" survives, and leaves the implementation free. The carve-out: the domain isn't
   always the customer — "Sev-1 incidents from 4/quarter to ≤1" passes, because sev-1 is a
   first-class noun of the reliability domain the objective lives in. The ban is on tool
   names and internal mechanism (Postgres, React, the webhook retry queue), not on a
   technical domain's own terms — and the stakeholder test is primary, the tool-name ban
   only its most common verdict: when an objective's stakeholders are engineers (platform,
   infra, dev tools), their tools are the domain's own nouns, and "Postgres major-version
   upgrade downtime from 4h to 0" passes for the platform team whose customers say Postgres
   daily. Why it's a rule: implementation-speak is the detectable
   surface form of the output KR rule 1 bans in substance — completable while the business
   stands still. The canned pushback: "Postgres is how, not what — what does the studio owner
   notice when this works?" The full before/after table is in [evidence.md](evidence.md).

## KR ids are frozen

Ids follow the pattern `KR<objective>.<number>` — `KR1.2` is the second key result under
Objective 1. The moment a cycle goes `status: active`, its ids freeze:

- A dropped KR keeps its number forever, with `Status: dropped` added under its heading. It
  does not disappear, and nothing renumbers around it.
- **Renumbering is forbidden.** Not discouraged — forbidden.
- Across cycles, the canonical form is `<cycle>/KR1.2` (e.g. `2026-Q3/KR1.2`), because `KR1.2`
  alone is ambiguous the moment a second cycle exists.

Why so rigid: KR ids are referenced everywhere downstream — `KR:` lines on PRs and commits,
check-in confidence tables, judgment-call log lines, drift reports, `LESSONS.md`. Positional
ids silently corrupt every one of those references. If dropping KR1.2 turns KR1.3 into the new
KR1.2, then every PR tagged `KR: 1.2` before the drop now points at different work than every
PR tagged after it, and nobody can tell which is which. Frozen ids make history greppable; a
gap in the numbering is a feature — it shows where a KR died.

## Amendments — the mid-cycle change protocol

OKRs are living documents. A KR that reality has invalidated by week 4 should change — grinding
out a cycle against a target everyone knows is wrong is theater. But the audit trail is sacred:
a retro scoring against silently rewritten targets is scoring fiction.

So mid-cycle changes follow one protocol:

1. The change goes through a **PR to the cycle file** — visible, reviewable, deliberate.
2. The original text is **preserved in a `Revised:` block** with the date and reason:

   ```markdown
   ## KR1.2: Weekly active studios from 46 to 60
   Revised: 2026-08-14 — two enterprise studios churned in July for reasons unrelated to
   this KR; original target assumed their volume. Original: "from 46 to 70".
   ```

3. **The coach never silently edits an active KR.** Not to fix a typo, not to "clarify," not
   when asked casually in a session. It drafts the PR and hands it to a human.

Dropping a KR is an amendment like any other: PR, `Status: dropped`, reason, number retained.
Raising a target after a sandbag flag (below) is too — logged as a revision, so the retro can
see the target moved and why.

**Health-metric rows amend the same way.** A red line or a measurement source can be wrong for
the same reasons a target can, so the protocol reaches them too — with one placement rule,
because a table cell has nowhere to put a `Revised:` block. The note goes on its own line
directly beneath the health-metrics table, naming the metric it revises:

```markdown
| Metric | Red line | Source |
|--------|----------|--------|
| Support ticket volume | >40/wk | Helpdesk dashboard |

Revised: 2026-08-14 — support ticket volume: source moved from the helpdesk dashboard to the
weekly export; the dashboard counts reopened tickets twice. Original source: "Helpdesk
dashboard". Red line unchanged.
```

Two rules keep this from becoming the loophole the protocol exists to close. **A red line is
never renegotiated during its own breach** — fix the breach, then amend, in that order. A line
argued down while it is red will be argued down generously, which is the whole failure mode.
And **automating a metric's source only ever adds detections, never removes them**: if a script
takes over part of the measuring, the manual pass it replaces stays until someone shows the
script catches what the human caught. A metric that got easier to satisfy without anyone
deciding it should be is no longer measuring what it was named for.

## Scoring

Every KR gets a score from 0.0 to 1.0, set once, at the retro (`/okrdev:retro`). The rubric is
mechanical on purpose: without one, retros degenerate into vibes, and vibes always average
around "we did fine."

**Metric KRs** score by formula:

```
score = clamp((actual − baseline) / (target − baseline), 0, 1)
```

Went from 46 to 62 against a target of 70: (62 − 46) / (70 − 46) = 0.67. The clamp means
overshooting caps at 1.0 and going backwards floors at 0.0. The formula works for
downward-good metrics too — the sign takes care of itself as long as baseline and target are
stated honestly.

**Milestone KRs** score against the 0.3 / 0.7 / 1.0 anchors defined at planning. Reached the
0.7 stage but not the 1.0 stage: score 0.7. Landed between anchors: score the last anchor
fully reached, and resist the urge to interpolate generously — the anchors exist precisely so
this isn't a judgment call.

**Reporting** is a single list of scores — there are no types to separate. A KR that scored
far below the confidence it carried into the final weeks gets a root-cause note in the same
retro: not blame, but an explanation concrete enough that planning can prevent the repeat. The
scores, notes, and a three-lesson summary land
in `okrdev/LESSONS.md`, which the next planning session reads first — last cycle's actuals are
the reality check against next cycle's ambition.

## Confidence

Every KR carries a confidence number: the DRI's current estimate, 0.0–1.0, of the probability
the KR hits its target. It's updated at every weekly check-in and it is the method's early
warning system — scores tell you what happened, confidence tells you what's about to.

**New KRs default to 0.5.** A good stretch KR is a coin flip at kickoff. Starting at 0.8
means the target is soft; starting at 0.2 means it was never a plan.

A confidence number that never changes anything is theater, so four triggers wire it to
behavior:

1. **Below 0.5 two consecutive weeks → a named decision.** The coach forces a choice among
   four: **re-scope** (amend the KR via the protocol above), **re-staff** (change who or what
   is on it), **kill** (drop it, number retained), or **accept-the-miss** (keep pushing, eyes
   open). The decision is logged in the check-in's Judgment calls section. Any of the four is
   legitimate — what's not legitimate is a fifth option: watching the number sink week after
   week while everyone hopes. Hope is not a decision.

2. **Unchanged three-plus weeks → one line of evidence.** A confidence stuck at 0.6 for a
   month usually means nobody is looking, not that nothing is moving. The coach asks the DRI
   for a single line of evidence supporting the number — a metric reading, a shipped change, a
   customer signal. Evidence ranks — the ladder is in [evidence.md](evidence.md): anything you
   can click or measure beats anything you can only narrate. If the evidence exists, fine,
   write it down. If it doesn't, the honest number is probably different, and now you know.

3. **At or above 0.9 early → the early-sandbag flag.** Near-certainty in week one or two means
   the target wasn't a stretch. See the next section.
4. **Narrative-only evidence three check-ins running, at ≥0.5 → one question, once.** When a
   KR's evidence lines have been narration ("on track," "feels close") for three consecutive
   check-ins while its confidence sits at or above 0.5, the coach asks once, generatively:
   "anything I can click, a number I can pull — or what would the first demoable slice be?" A
   one-line answer settles it — including "nothing clickable; this KR moves through calls,
   and the next artifact is the signed contract," which is itself evidence. The answer is
   logged as one Judgment-calls line and permanently re-classes the KR's expected evidence
   type for the cycle: the trigger never fires twice on the same KR. Below 0.5, trigger 1
   owns the conversation instead — stacking a demo request on a KR already being re-scoped or
   killed is nagging. When trigger 2 trips on the same KR the same week — flat confidence
   and narrative evidence usually travel together — this question subsumes it: one ask, and
   the answer doubles as the evidence line. The calibration argument lives in
   [evidence.md](evidence.md).

## Sandbagging detection

Sandbagging — setting targets you secretly know you'll hit — is the quiet failure mode of
every OKR system. It produces beautiful scorecards and zero ambition. okrdev checks for it at
three points, because catching it only at the retro is catching it after the wasted quarter:

- **At planning:** a target barely above the baseline's existing trend gets challenged. If the
  metric grew 8% a quarter for the last year, a 10% target isn't a goal, it's a forecast.
- **Mid-cycle:** confidence at ≥0.9 from week one, or a target hit before 60% of the cycle has
  elapsed, prompts the coach to propose raising the target. If the DRI agrees, the raise goes
  through the amendment protocol and is logged as a revision — the retro scores against the
  new target with full visibility into the change.
- **At the retro:** a KR that was hit early and rode flat-high confidence the whole way gets
  named, so next cycle's planning calibrates against it.

Two deliberate limits. First, **a KR whose 1.0 anchor was the only passing state never
triggers sandbag detection** — a binary outcome scoring 1.0 is the outcome happening, not a
soft target. Second, the flag is a conversation, never an accusation: naive systems that punish every 1.0 teach people to score
0.93, which is worse than the sandbagging — now the data is dirty too.

## Health metrics

Each cycle names two to four health metrics: numbers that are **monitored, not targeted**.
They live in a table at the bottom of the cycle file:

```markdown
## Health metrics (monitored, not targeted)
| Metric | Red line | Source |
|--------|----------|--------|
| Support ticket volume | >40/wk | Helpdesk dashboard |
| Checkout error rate | >0.5% | Vercel logs |
```

Health metrics are the system-level Goodhart defense. Your KRs are the numbers you're pushing;
health metrics are the numbers you might break by pushing. Nobody is trying to move them —
their job is to hold still while everything else moves.

The mechanics:

- Every metric has a **red line**, decided at planning while heads are cool. A red line
  negotiated during a breach will be negotiated generously.
- The coach checks all health metrics at **every weekly check-in** — they have their own
  section in the check-in file.
- **A breach can pause the KR pushing on it.** If support volume crosses its red line while
  you're sprinting on a signup KR, the check-in decides whether the sprint pauses until the
  line is back under. That decision is the whole point: growth that breaks the thing that
  keeps customers is not growth you want to score.
- The pairing rule from the quality section connects the two layers: every volume/speed KR
  names which health metric (or `Notes:` metric) is watching its blind side.

## Work classification

Alignment doesn't mean pretending all work is KR work. Real weeks contain bug fixes, real
emergencies, and the occasional sanctioned detour. The taxonomy makes each honest instead of
invisible: every **substantive** unit of work carries exactly one classification.

| Tag | Meaning | Rule |
|-----|---------|------|
| `KR: <id>` | Serves a key result | Name it before starting; tag the PR or commit |
| `side-quest` | Sanctioned distraction | Time-boxed always; logged in the parking lot |
| `maintenance` | Keeping the lights on | Auto-classified, silently |
| `emergency` | Couldn't wait | Post-hoc audit at the next check-in |

**What counts as substantive:** a new feature, or more than about an hour of new-capability
work. Bug fixes, config changes, docs, and small refactors are `maintenance` automatically —
the coach states the classification in one line ("treating this as maintenance") and moves on.
It never interrogates. This threshold exists for survival: a coach that demands a KR
justification for every typo fix gets its CLAUDE.md block deleted by week three, and then
nothing gets classified. Cheap compliance on small things buys real compliance on big ones.

**`KR: <id>`** is the default and the goal. The tag goes in a `KR:` line in the PR
description — or in the commit message, for repos that ship straight to main. The canonical
grammar, shared by the coach and the okr-gate action: the first line matching

```
^KR:\s*(([0-9]{4}-[QC][0-9]+\/)?(KR)?[0-9]+\.[0-9]+|side-quest|maintenance|emergency)\s*$
```

case-insensitive, first match wins. Accepted id forms: `1.2`, `KR1.2`, and the cross-cycle
long form `2026-Q3/KR1.2`; short ids resolve against the active cycle. The gate that reads
them is Level 2 territory; see [adoption.md](adoption.md).

**`side-quest`** is how the parking lot stays a rudder instead of a straitjacket. A side-quest
is always time-boxed, always logged in `okrdev/PARKING_LOT.md`, and drawn from a weekly
box-hours budget (default 4 hours per person per week, set in `config.md`). Sanctioned
distraction is the pressure valve that makes "park it" a livable default — the full protocol
is in [parking-lot.md](parking-lot.md), and `/okrdev:side-quest` runs it.

**`emergency`** is the escape hatch, and escape hatches attract traffic. So every emergency
gets a post-hoc line at the next check-in answering two questions: *was it actually an
emergency, and what did it protect?* Not to punish — most emergencies are real — but because
the one unaudited category is where all the gaming funnels. If `emergency` were free, every
Tuesday feature would be an emergency by Friday. The coach also watches the rate: emergencies
above roughly 5% of PRs, or more than two a cycle, get raised as a pattern. Recurring
emergencies aren't emergencies; they're an unplanned KR the cycle is missing.

**The maintenance signal.** When maintenance-classified work exceeds roughly 30% of PRs by
count, the coach asks a question: is this a temporary cleanup push, or is the codebase (or the
business) telling you it's underinvested — and does that deserve a real KR next cycle? It's a
prompt, not an alarm, and the coach says so, because the proxy is crude: PR count weights a
one-line dependency bump the same as a week-long refactor. A crude signal honestly labeled
beats a precise-looking one nobody believes.

**Non-code work counts.** Sales calls, ops fixes, marketing launches — in most real businesses
the work that moves a KR isn't a PR. The check-in's "What moved" section is the canonical
ledger for non-code KR work; DRIs add their lines there and that's the record. The automated
drift check covers what git can see — PRs and commit messages. Per-item classification is for
code only; asking a founder to tag every phone call is exactly the kind of ceremony that gets
the framework uninstalled.

**Challenged, never blocked.** Classification is a conversation the coach starts, not a gate
it closes. Work that traces to nothing gets questioned before it starts — and if the human
says go anyway, the coach goes, immediately, and logs one judgment-call line. The authority
model, override mechanics, and drift-check procedure live in [ai-coach.md](ai-coach.md).

## Where each rule lives

| Concern | File |
|---------|------|
| Cycle OKRs, health metrics, revisions | `okrdev/okrs/<cycle>.md` |
| Weekly confidence, what moved, drift, judgment calls | `okrdev/checkins/<cycle>/<yyyy-Www>.md` |
| Captured ideas, side-quests and their boxes | `okrdev/PARKING_LOT.md` |
| Scores, lessons, adherence stats | `okrdev/LESSONS.md` |
| Cadence, budgets, backstop | `okrdev/config.md` |
| Mission and strategy the cycle serves | `okrdev/MISSION.md` |

The rituals that read and write these files — planning, check-in, triage, retro — are scripted
in [rituals.md](rituals.md). Run them with `/okrdev:plan`, `/okrdev:checkin`,
`/okrdev:triage`, and `/okrdev:retro`. Their writes are batched: one ledger commit per triage
or check-in, not one per item — and on a protected default branch, that batch lands as a
small, immediately merged state PR. Capture itself doesn't commit at all where the repo lives
on GitHub: `/okrdev:park` files an `okrdev:parked` issue, and triage sweeps the inbox into the
file ledger, which stays the single canonical record. Mechanics in
[adoption.md](adoption.md#protected-main-and-okrdev) and [parking-lot.md](parking-lot.md).
