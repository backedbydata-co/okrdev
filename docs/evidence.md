# Evidence — demos, domain words, and what counts as proof

The demo argues, the metric decides. okrdev already runs on evidence — the check-in table has
an Evidence/note column, previews arrive with click-test steps, the retro's whole move is
"what's the actual?" — but the standard those behaviors share was never written down. Here it
is: **a claim about progress must be checkable, and checkable in the domain's own words.**
Anything you can click or measure beats anything you can only narrate, and nothing you can
click outranks the number it was supposed to move.

One admission rule governs everything below, stated up front so nobody has to infer it: this
doctrine enters okrdev as plain words wired into behaviors that already exist — a KR quality
rule, a phrasing rule for anchors, a fourth confidence trigger, a reason vocabulary for
triage. Never as a new file in your repo, a new field, a new ritual, or a word a DRI has to
learn. The install footprint doesn't move. The check-in is still fifteen minutes.

## Why this document exists

The [manifesto](../MANIFESTO.md) says numbers you don't act on are theater. This document is
that belief pointed at a subtler theater: *claims* you can't check. When execution was
expensive, a status report was roughly honest — the work was hard enough that narrating it
cost almost as much as doing it. Cheap execution inverts that. When building is cheap,
narrative about building is cheaper still, and the scarce thing becomes a claim someone can
check in under a minute. okrdev's own mission file says it plainly: "the job this cycle is
not more features — it's evidence."

Sources, named honestly once, the way [method.md](method.md) names Grove: the language
discipline below comes from strategic domain-driven design, the demo discipline from Apple's
demo-review culture, and the counterweight from Amazon's written narratives — all stripped to
plain words. The meta-filter, so future contributors don't cargo-cult the other halves:
okrdev borrows the *strategic* half of each tradition only, and only where it wires into an
existing behavior. What got refused, and why, is recorded at the end of this document.

## The ladder

Five rungs, ordered by how directly a reader can check the claim for themselves — you
operated it beats it exists beats you were told — annotated honestly with what each rung can
still hide, because no rung is immune. This is the single canonical copy:
[method.md](method.md)'s confidence triggers and the ritual skills point here rather than
restating it.

| Rung | Evidence | What it can still hide |
|------|----------|------------------------|
| 1 | **Metric movement** — the KR's own number moved | Measurement dishonesty (the retro's job to catch) |
| 2 | **Demo** — a clickable preview, a recording, a live artifact *in the state claimed* | Unbuilt depth behind the happy path; absent adoption |
| 3 | **Shipped artifact** — merged PR, signed contract, sent campaign, published page | "Nobody uses it" |
| 4 | **External signal** — a customer said or did something specific and attributable | Cherry-picking; one voice mistaken for a market |
| 5 | **Internal narrative** — "on track," "feels close" | Everything. Admissible, but the floor |

The ordering is argued, not assumed. Metric beats demo on principle: okrdev is an *outcome*
system, and a demo is a beautifully compressed *output* — the best leading indicator there
is, and never the verdict. A slick demo of the wrong thing is more dangerous than a dull
report about the right thing, because it recruits belief. So the demo argues; the number it
was supposed to move decides.

Demo beats shipped artifact by the ladder's own criterion: a demo is the claim inspected
now, in the state claimed; an artifact is a record that something once happened, inspected
later if ever. Records go unexamined — "merged" quietly substitutes for "works" — but a demo
cannot be watched without being examined.

Nothing on any rung requires a screen. The same ladder, translated for KR work that never
touches a repo:

| Rung | Non-code form |
|------|---------------|
| 1 | The pipeline number, the close rate, the churn figure — moved |
| 2 | The thing in the state claimed, inspectable now: the pricing page as it reads today, the recorded pitch, the draft contract you can read |
| 3 | The signed contract, the paid invoice, the sent campaign, the booked pipeline |
| 4 | An attributable customer signal — a named prospect's reply, a renewal conversation |
| 5 | "The deal is progressing" |

For non-code work, rungs 2 and 3 often collapse — the signed contract is at once the
artifact and the demo. When they do, cite it once; the ladder ranks evidence, it doesn't
demand two exhibits.

## The demo review okrdev already runs

Here is the claiming move of this whole document: okrdev already has demo-driven review
installed, and nobody had named it. Coach rule 10 — "hand preview URLs directly in chat with
click-test steps" — *is* a demo review: a runnable artifact, a decider with authority (the
DRI), a concrete interaction script, and a same-day verdict.
[dri-onboarding.md](dri-onboarding.md) already states its iron rule — "never merge anything
you haven't clicked" — and the repo's own doctrine writing already practices
proof-by-demonstration: [live-coached-sessions.md](live-coached-sessions.md) carries a status
line that reads "rig built and proven end-to-end on a live Zoom call (2026-07-30)." Dated, checkable,
rung 2.

What naming the practice buys: the DRI's verdict on a preview is rung-2 evidence the next
check-in can cite. "Clicked the export flow Tuesday, works as specced" is a real
Evidence/note line, and it costs nothing new — the click already happened.

And the verdict is a lap of the loop, not the end of it. "Not right" is the review working:
the coach revises and hands back a fresh preview — same day, where the rails allow — and the
cycle repeats until the DRI says right. This is where demos earn their iterate role: each
preview is a draft of the idea cheap enough to throw away, and the argument advances by
showing the next draft, not by defending the last one.

## Demo in the customer's words

The deep reason demos beat documents isn't vividness — it's vocabulary enforcement. A
document about the customer's problem can be written entirely in your vocabulary and nobody
notices; the customer never reads it. A demo has to be *operated*, and the moment it's
operated in the customer's vocabulary — their nouns on the buttons, their workflow in the
steps — mistranslation becomes visible in thirty seconds, for free. This is why the
click-test steps matter more than the preview URL: the steps are the domain language, made
falsifiable. "Click these three things and tell me if the export works" only lands if
"export" means to the DRI what it means to the customer.

A KR heading, a milestone anchor, and a click-test step all pass the same test: **would a
stakeholder of this objective use these nouns?** That test is KR quality rule 6 in
[method.md](method.md). The full before/after table:

| Before (the toolchain's words) | After (the customer's words) |
|-------------------------------|------------------------------|
| "Migrate lead data to Postgres and ship the new intake form" | "Lead-to-first-appointment time from 9 days to 3" |
| "Ship the webhook retry queue with dead-lettering" | "Recovered failed payments from 0% to 60%" |
| "Rebuild the booking flow in React; API p95 under 200ms" | "Studios booking a first class within 24h from 30% to 55%" |

Every "before" can be completed while the business stands still — the migration lands and
leads still wait nine days; the retry queue ships and the recovered-payment rate doesn't
budge; the rebuild is flawless and studios still don't book. Every "after" leaves the
implementation free (that's the AI's job, per the manifesto) and freezes the outcome. The
carve-out matters: the domain isn't always the customer — "sev-1 incidents from 4 to ≤1" is
a fine KR, because sev-1 is a first-class noun of the reliability domain. The ban is on tool
names and internal mechanism, not on a technical domain's own terms.

The brownfield warning, because this is where the disease enters: `git log` speaks
implementation language, so a first cycle drafted from a repo scan will inherit git-log-speak
unless the coach translates upward — straw-man KRs take their vocabulary from
`okrdev/MISSION.md` and prior check-ins' "What moved" lines, and arrive in the DRI's words,
not the repo's. In a knowledge-extraction conversation, the party who imposes their jargon on
the expert gets a corrupted model — and about the *outcome*, the DRI is precisely the expert.

## The narrative floor

[method.md](method.md) states confidence trigger 4 tersely; this section is the calibration
argument, because a trigger this close to the nag-rate red line has to defend every one of
its thresholds.

The trigger: the same KR shows narrative-only evidence (rung 5) three check-ins running while
its confidence sits at or above 0.5 → the coach asks once, generatively: "anything I can
click, a number I can pull — or what would the first demoable slice be?" A one-line answer
settles it, is logged as one Judgment-calls line, and permanently re-classes the KR's
expected evidence type for the cycle. The trigger never fires twice on the same KR.

- **Three weeks, not two.** The flat-confidence rule (trigger 2) waits three-plus weeks to
  ask for one *line*. This ask is heavier — produce or name an artifact — so it must not fire
  faster than the lighter rule. A heavier ask on a shorter fuse is how coaching becomes
  auditing.
- **Only while confidence is ≥0.5.** Below 0.5, trigger 1's named-decision conversation owns
  the KR — re-scope, re-staff, kill, or accept-the-miss. Stacking a demo request on a DRI
  whose KR is drowning is nagging, and it demands evidence about a target that may not
  survive the week.
- **Once per KR per cycle, with a permanent opt-out.** This is the difference between a
  tripwire and a nag. Fired weekly, this trigger breaches the nag-rate red line by week four
  — and worse, it teaches DRIs to fabricate rung-3 evidence to make the question stop, which
  corrupts the evidence signal exactly the way naive 1.0-flagging corrupts scores. Asked
  once, with the answer recorded, it stays a tripwire.
- **Phrased generatively, never forensically.** "What would the first demoable slice be?"
  hands the DRI a next action; "why is there no evidence?" hands them a citation. The coach
  records decisions, not demerits.
- **"Nothing clickable" is a complete answer.** "This KR moves through calls — the next
  artifact is the signed contract" is itself evidence: it names the KR's real medium and its
  next checkable artifact. The Judgment-calls line ("KR2.1 moves through negotiation —
  expected evidence: the signed contract") is the permanent record, and the next check-in's
  pre-draft greps for it — which is what makes "never twice" enforceable with zero format
  change. A sales KR answers once, in week three, and is never asked again.
- **When triggers collide, one question.** Narrative evidence and flat confidence usually
  travel together, so the week this trigger fires is often a week trigger 2 fired too. This
  question subsumes the lighter ask: its answer is written as the Evidence/note line and the
  Judgment-calls re-class — a DRI never fields two evidence demands about one KR in one
  walk.
- **Honored, then audited.** Mid-cycle, a re-classed KR is never re-asked. At the retro, the
  re-class line is replayed beside the `Revised:` blocks — "expected evidence was the signed
  contract; did it arrive?" The opt-out is real, and it has a due date.

## Build, box, or buy

Three plain verbs for the triage call and the planning argument — a reason vocabulary, not a
new question. The thirty-seconds-per-item pace survives because these are faster reasons, not
extra process.

- **Build** — work only this team can do that a stakeholder of the mission would recognize as
  winning. Objectives live here, and nothing else does; this is the real question behind
  planning's subtraction step ("every objective beyond the first must justify the focus it
  steals").
- **Box** — necessary but not differentiating: it keeps the lights on. Box, as in: it gets
  one — a bounded budget, the maintenance share or a side-quest time-box, never open-ended
  investment — and it never auto-promotes to next-cycle candidacy on its own. When the maintenance share crosses ~30%, this is often what's
  happening — a boxed thing quietly absorbing effort. The honest moves are pay it down and
  stop, or buy your way out; never promote it to an objective by attrition.
- **Buy** — a solved problem the market already sells. Archive with "already solved
  elsewhere — adopt X" as the epitaph: the sharpest reason line there is, because it survives
  the idea's inevitable October rerun. The triage script's "duplicate of what CRM already
  does" is the house example. For the buy decision itself, [stack.md](stack.md)'s
  What/Why/Exit format is the house style — every bought thing documents its exit.

Why this lens earns a place in a framework premised on cheap execution: when building is
cheap, teams build the buyable *because they can*. The half-day CRM clone, the hand-rolled
auth, the bespoke dashboard — each is an afternoon of agent work and a permanent maintenance
liability. The build-the-buyable trap gets worse, not better, in exactly the era okrdev is
built for, which is why the archive verb needed sharpening most. (Practitioners will
recognize the core/supporting/generic lens from strategic domain-driven design; okrdev keeps
the verbs and drops the vocabulary.)

## The fence

**The coach never treats a week without a demo as a week without progress.**

This is an absolute — the mirror of the drift-check rule that the coach never flags a week of
customer interviews as drift just because no PRs merged — and it's printed inside that same
paragraph in [ai-coach.md](ai-coach.md), so the two fences can never drift apart. "What
moved" remains the canonical ledger for work that can't screenshot. Sales calls, ops moves, a
pricing negotiation — these are KR work with no PR and no demo possible, and the ladder's
non-code column exists precisely so they are never second-class evidence. Any wording,
anywhere in this repo, that would let a founder feel demo-shame for a week of sales calls is
a reviewer-class defect against the cycle's own coherence health metric. Report it like one.

## The partition

Every other rule in this document pushes a claim toward being checkable by more people. This
one pushes the other way, and it should say so first. okrdev's ledger lives in the repo where
the work happens, and this repo is public. The DRI's other work is not. So every evidence line
here gets written a few keystrokes from things that must never be written, by a coach holding
all of it in one working context. On 2026-08-20 that produced a check-in entry naming another
business's cost unit, its pricing model, and a pull-request number in its private repo. A human
caught it in review, which is the only thing that caught it.

**The rule.** Everything published from this repo — `okrdev/**`, `docs/**`, and the issue and
pull-request text that travels with them — is public prose about okrdev. Everything else the
DRI works in is private state: other businesses, client work, private repos, the machine
itself. The ledger may describe **how okrdev is being used**, anywhere it is being used. It may
not describe **what the business using it is or does**. The partition runs one way: private
state cites this repo freely, and this repo cites nothing on the private side.

**The swap test**, because a rule you cannot apply in the second it takes to write a sentence
is not usable by a human or by an agent. Swap the other business for any other business — does
the sentence survive? *"Held a check-in with both DRIs present and every row carrying measured
evidence"* survives; it is a fact about okrdev, true in the same words of any adopter. *"Raised
its per-seat price and amended the KR that tracks it"* does not: strip the identity and the
sentence means nothing, which is the proof that its content was the business rather than the
method. It is the same cut the retired hours row was retired under — *okrdev's health metrics
monitor okrdev's health, not its DRI's* — applied to prose instead of to metrics.

| Publishable — okrdev's own shape | Withheld — the business |
|---|---|
| That an adopter exists, at what level, on what version | Its name, its people's names, its repos' names |
| Ledger shape: objective and KR counts, DRI count, which rituals were held, whether the revision protocol was used, commits authored to `okrdev/` | Its KR text, its metric names, its targets and baselines |
| Direction and anonymized readings — "moved substantially", "their cadence is coupled to mine" | Any figure of the business: revenue, price, cost or metric units, headcount, customer counts |
| okrdev's own dates: weeks held, when a use-clock started | Customers, deals and counterparties — named, numbered, or described closely enough to identify |
| Decisions, and their consequences for this cycle | Cross-references into private state, below |

**Cross-references are the half that hides.** A bare hash-number in this repo resolves against
this repo, so a number copied out of a private thread either dangles or lands on an unrelated
okrdev issue — either way it is a pointer into private state, written in the open, wearing
local clothes. The same goes for another repo's name or URL, a branch name out of it, and any
absolute or home-relative path outside this repo: a path under a home directory names a machine
and usually names a business with it. The ban is on references that locate private working
state, not on the characters they are made of — the Zoom transcript path in
[live-coached-sessions.md](live-coached-sessions.md) tells a reader where Zoom writes files,
names nobody, and stays.

**Mark the gap.** A claim the partition has trimmed says so where it stands. The house forms
are already in the ledger: `(local read, anonymized)` in an Evidence/note cell, and "details
stay out of this file by the partition rule" in What moved. A withheld detail that is not
marked as withheld reads as a detail that never existed, and the retro cannot replay a citation
whose edges it cannot see. The marker is also the honest accounting of what this rule costs: an
anonymized reading is rung 1 for the person who took it and rung 5 for everybody else, and the
marker is what stops the ledger from quietly claiming otherwise.

**Permission is not a partition.** The 2026-08-20 ruling stands as recorded — the co-owner
would not object to anonymized usage being cited, and the thing he would actually care about is
details of the business being shared. That answered permission, which is the smaller question.
A partition is not a courtesy one person can waive: the sentences it stops are also about that
business's customers, its other DRI and its counterparties, none of whom were asked and none of
whom can waive anything. Consent widens what may be *cited*; it never widens what may be
*written*, and the table above is unchanged by a yes.

**A redaction note names the class, never the string.** The amendment protocol preserves
original text verbatim, because a retro scored against silently-moved goalposts is fiction.
This is the one place that habit inverts: quoting the original would republish the exact string
the redaction removed, into a file with a longer memory than the one it left. So the note names
what class of thing went, and why — *"the location clause redacted under the partition rule;
the definition of 'outside' is unchanged"* is a complete note. The 2026-08-07 pass already
worked this way, anonymizing outside-adopter references while leaving substance, dates and
numbers unchanged — and the numbers that stayed were okrdev's own: levels, versions, week
counts, never the business's.

**A check catches shape, not meaning**, in the same register [testing.md](testing.md) uses for
its coherence greps: they catch byte drift, not meaning drift. A cross-reference has a shape.
A disclosure usually has none — *"their per-seat number moved the wrong way"* holds no token
any grep can catch, and it is a pricing disclosure. So the mechanical half is a floor under the
one failure mode that is both patterned and unfixable after the fact; the swap test is the
rule, and it is held by people. That also settles what the mechanical half may look like:
**structural only, never a list of terms.** A denylist of sensitive words committed to a public
repo is a published list of exactly what somebody thought was worth hiding — the check would
leak the thing the check exists to stop. This repo is also the plugin directory, so it would
ship that list to every adopter's disk as well.

The floor sits **before the push, not at review**, and the reason is arithmetic rather than
nerves. Prevention costs milliseconds. Cure, on a public repo, is not fully available:
rewriting the branch and deleting it from the remote leaves the original commits fetchable by
SHA through the API, and a closed pull request lists them in its Commits tab indefinitely —
both verified here, not assumed. Guaranteed removal takes a support ticket, and the content is
reachable until somebody actions it. Everywhere else in okrdev, a human catching it in review
is a working rail. Here the reviewer has already lost, because by then it is pushed.

**What an adopter takes from this.** If your ledger is private, the rule is dormant and costs
you nothing — a partition needs two sides, and a private ledger already shares an access
boundary with everything it describes. It is still a framework rule rather than this repo's
housekeeping, for three reasons. okrdev puts the ledger in the repo where the work happens and
then tells you to protect main, ship previews, and open what you can; a team that takes that
advice in a public repo is publishing prose about its business every week without ever deciding
to. The exposure is manufactured by okrdev's own mechanics — the coach pre-drafts the whole
check-in from whatever the DRI's week contained, and its homework tells it to take a reading on
every KR it can reach, which is precisely the move that pulls somebody else's detail into the
drafting context. And anyone running more than one thing meets this in week one: an agency with
clients, a consultancy, a founder with a portfolio, a contractor whose day job is not this repo.
It installs at the price this document charges everything else — no new file, no new field, no
new ritual, no word a DRI has to learn — as one line in the coach's never-list, one line in the
check-in skill, and one sentence of adopter-facing prose in [adoption.md](adoption.md).

## Demos over documents, settled

The tension is real, so state it instead of papering over it. A demo answers "is this the
right thing?" A narrative answers "have we thought this through?" A metric answers "did it
work?" Demo culture without follow-through selects for smoke and mirrors; document culture
without artifacts lets you be wrong in private for months.

okrdev doesn't pick one side — it already picks a side *per layer*, and naming the layering
kills the false war in one sentence: **plan in writing** (the cycle file is a reviewed PR —
that's the written-narrative move), **progress in demos** where a screen exists, **verdicts
in numbers** (the scoring formula is the formula). A demo is wrong in public in thirty
seconds — buy the cheaper wrongness.

## Ruled out — recorded so it isn't reinvented

Per house custom, the negative space, so future contributors don't re-litigate:

- **Tactical domain-driven design** (aggregates, entities, value objects, repositories) —
  categorically out. There is no code here to pattern; importing aggregates for markdown
  files would be the parody case. The meta-filter in "Why this document exists" is the
  standing rule.
- **Context mapping and its pattern names** — an inter-team politics toolkit for an org shape
  the manifesto refuses ("cascade theater"). The `KR:` tag grammar already is the one
  published interchange language okrdev needs, unnamed on purpose.
- **Event storming** — a workshop is ceremony. "What moved" already is the event ledger, in
  freeform, and freeform is what keeps the check-in fifteen minutes.
- **The "Big Ball of Mud" term** — its diagnostic is already native in sharper words: "a
  backlog wearing a costume."
- **A demo day, or any demo ritual** — the check-in's Wins slot and rule 10's async demo
  review already exist. Fifteen minutes is load-bearing; new ceremony is refused by doctrine.
- **A mandatory demo per KR or per PR** — see the fence. The PR template's "How to verify"
  section is already the demo slot for code, and non-code work must never be shamed by a slot
  it can't fill.
- **Runnable straw-men for non-code objectives** — a sales motion's straw-man is the pitch
  script, and that's already text.
- **Any new capture field, check-in section or column, or cycle-file field** — energy and
  effort stay the only capture fields; the narrative floor rides the existing Evidence/note
  column and Judgment calls section; anchors already live in `Notes:`. A ten-second park
  stays ten seconds.

## Where this wires

Prose argues; tables settle. Every rule above, the existing behavior it sharpens, and the
place that enforces it:

| Doctrine | Existing behavior it sharpens | Enforced in |
|----------|-------------------------------|-------------|
| Customer's words, not the toolchain's | KR quality pushback at planning | [method.md](method.md) quality rule 6; `/okrdev:plan` gauntlet; [rituals.md](rituals.md) planning step 3 |
| Event-phrased milestone anchors | The anchors-at-planning rule; the retro replay | [method.md](method.md) KR anatomy; `/okrdev:plan` step 5; `/okrdev:retro` step 4 |
| The evidence ladder | The one-line evidence rule; "what's the actual?" | [method.md](method.md) confidence trigger 2; `/okrdev:checkin` steps 8g/11; `/okrdev:retro` step 4; `/okrdev:side-quest` close-out |
| The narrative floor | The confidence walk | [method.md](method.md) confidence trigger 4; `/okrdev:checkin` steps 8a/11; `/okrdev:coach` step 6a |
| Build / box / buy | The three triage verdicts; planning's subtraction step | [parking-lot.md](parking-lot.md) triage; `/okrdev:triage` step 3 |
| The demo review, named | Rule 10's preview hand-off | [ai-coach.md](ai-coach.md) unblocking duties; [dri-onboarding.md](dri-onboarding.md) review routine |
| The partition | The anonymization the 2026-08-07 pass did by hand | [ai-coach.md](ai-coach.md) never-list; `/okrdev:checkin` and `/okrdev:coach` never-lists; [adoption.md](adoption.md) multi-team. The structural half is a check, and lands in its own PR — doctrine first, then the test |
| The fence | The drift check's code-only honesty | [ai-coach.md](ai-coach.md) drift-check mechanics; [rituals.md](rituals.md) retro step 1 |

**Deliberately not wired yet.** An unwired rule is theater by this repo's own doctrine, so
the unwired parts are named instead of smuggled: the throwaway-prototype planning homework,
the roles.md paragraph on the DRI-as-expert inversion, a worked narrative-floor exchange in
the acme-fitness example, and any okr-gate "anything to click?" nudge. Each is captured in
[../okrdev/PARKING_LOT.md](../okrdev/PARKING_LOT.md) and waits for evidence from real use —
this doctrine enters the repo by its own rules.

---

The enforced rules live in [method.md](method.md). Where each one fires is choreographed in
[rituals.md](rituals.md). The runner you'll meet most weeks is `/okrdev:checkin`.
