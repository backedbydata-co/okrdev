# The okrdev Manifesto

## Building got cheap. Focus didn't.

For most of software history, the bottleneck was making things. Ideas were free; execution was
expensive. Every methodology we inherited — sprints, backlogs, roadmaps — was built to ration
scarce engineering capacity.

That world is gone. An agent can scaffold in an afternoon what a team used to ship in a quarter.
Anyone — technical or not — can now build almost anything.

Which means the bottleneck moved. When execution is cheap, ideas stop being assets and start
being liabilities. Every "what if we just—" now comes with a real risk that somebody builds it
this week. The scarce resource is no longer the ability to build. It's the discipline to decide
what not to build.

okrdev exists for that discipline.

## The inversion

The standard arrangement: humans supervise the AI, keeping it on track, reviewing its work,
correcting its drift.

okrdev adds the mirror image: the AI keeps the humans on track. It knows the mission. It knows
this cycle's objectives and exactly which key results are moving. So when a human shows up with
this week's shiny idea, the coach asks the one question that matters:

**"Which key result does this serve?"**

If there's an answer, build. If there isn't, the idea goes in the parking lot — captured in ten
seconds, triaged at the next check-in, never lost and never chased. Humans stay sovereign: you
can always override the coach. But every override is written down, and you'll see it again at
the next check-in. That's the deal. Freedom, with a memory.

## What we believe

**1. Objectives before code.**
Work that doesn't trace to a key result isn't necessarily bad work — but it should have to say
so out loud. Maintenance is real. Emergencies are real. Side-quests are real, and sanctioned.
What's not allowed is *unexamined* work — effort that nobody decided to spend.

**2. Catalog, don't chase.**
Distraction isn't a character flaw; it's what a live mind does. The failure mode isn't having
ideas — it's acting on them the moment they arrive. So okrdev makes capture nearly free and
action deliberately gated. Park it in ten seconds. Triage it weekly. The good ideas survive
triage. The dopamine doesn't.

**3. The coach never blocks. It remembers.**
Tools that stop humans get uninstalled — usually mid-crisis, usually forever. So the coach has
exactly one power: it writes things down. Judgment calls, overrides, drift, emergencies that
weren't. Accountability without authority. It turns out that's plenty.

**4. Anyone can own anything.**
Titles described what you could do when skills were scarce. With AI filling gaps, a marketer
can ship a database migration and an engineer can run a pricing experiment. okrdev makes
everyone a generic builder and every objective someone's to own end-to-end — one DRI, no
committees. Domain experts still check the work where the stakes are high. That's encoded in
the rails (CODEOWNERS, protected branches), not in an org chart.

**5. Safety is an environment, not a behavior.**
Non-technical people don't ship safely because someone watches them. They ship safely because
the unsafe paths are hard: every change gets a preview to click, a robot that checks it, and a
gate that asks who reviewed it. Vigilance doesn't scale. Rails do.

**6. Numbers you don't act on are theater.**
Confidence scores that trigger nothing, check-ins nobody reads, metrics that only ever get
reported — okrdev refuses all of it. Every number in the system is wired to a behavior: falling
confidence forces a decision, health metrics can pause a KR, missed check-ins trigger a
catch-up, not a guilt trip. If a ritual stops earning its minutes, cut the ritual.

## What we refuse

- **Cascade theater.** No trees of aligned sub-OKRs. One team, one to three objectives, done.
- **Set-and-forget.** OKRs written in week one and rediscovered at the retro are decoration.
- **Metric tyranny.** Every target you push gets a health metric watching what you might break.
- **Ceremony.** The weekly check-in is fifteen minutes because the coach pre-writes it. A
  three-line check-in is valid. A skipped week gets a two-minute catch-up, not an inquisition.
- **Lock-in.** Your OKRs are markdown files in your own repo. Delete one directory and okrdev
  never existed.

## The wager

okrdev bets that in the age of cheap execution, the winning teams won't be the ones that build
the most. They'll be the ones that decide the best — small groups of focused people, each owning
outcomes end-to-end, with AI doing the building and the bookkeeping, and something in the loop
that relentlessly, politely, asks:

*Is this the most important thing you could be doing right now?*

Usually it is. Sometimes it isn't, and the idea gets parked, and Thursday's triage decides.
That gap — between the impulse and the decision — is where focus lives.

That's the whole framework.
