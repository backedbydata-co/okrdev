# The parking lot

Catalog, don't chase. The parking lot is where ideas go so they stop dying *and* stop winning:
captured in ten seconds, triaged once a week, never worked on by impulse. It's the first thing
okrdev installs (Level 0, before you have a mission or a single KR) because it delivers value
before any ceremony exists to support it.

The premise, from the [manifesto](../MANIFESTO.md): distraction isn't a character flaw, it's
what a live mind does. The failure mode isn't having ideas — it's acting on them the moment
they arrive. So capture is made nearly free and action is deliberately gated. The gap between
the impulse and the decision is where focus lives.

## The file

One markdown file, `okrdev/PARKING_LOT.md`, four sections:

```markdown
# Parking Lot
Ideas get captured here in seconds and triaged at the weekly check-in.
Nothing in Captured gets worked on. Ever. Triage first.

## Captured
- [2026-07-13] <one-line idea> — @alex — energy: high — effort: M

## Side quests (time-boxed, logged)
- [2026-07-13] <idea> — @alex — box: 4h — spent: 2h — status: open — notes: —

## Promoted
- [2026-07-13] <idea> → KR2.1 (or: next-cycle candidate)

## Archived
- [2026-07-13] <idea> — reason: <one line>
```

An idea enters at Captured — or, on GitHub-remote repos, through the issue front door (next
section) — and leaves through exactly one of the other three sections. For a
lived-in example — items in all four sections, warts included — see
[examples/acme-fitness/PARKING_LOT.md](../examples/acme-fitness/PARKING_LOT.md).

## Capture: ten seconds, no more

Say "park it" (or invoke `/okrdev:park`). Capture has a front door and a ledger, and they are
not the same thing:

- **The front door — a GitHub issue.** When `gh` is authed and the repo's remote is GitHub, the
  coach runs `gh issue create` with the label `okrdev:parked`: title = the one-line idea,
  verbatim; body = one line, `@<who> — energy: <high|med|low> — effort: <S|M|L>`. Zero commits,
  zero CI, one API call — the ten-second promise, kept on any repo, protected main included.
  (If the label doesn't exist yet, the coach creates it first:
  `gh label create okrdev:parked --color F9D71C --description "okrdev parking-lot inbox — triaged weekly, then closed"`.)
- **The fallback — a file append.** No `gh`, no remote, or a remote that isn't GitHub: the
  coach appends one line to Captured in `okrdev/PARKING_LOT.md`, exactly as it always has.
  Write mechanics below.

Either way the coach confirms in one line — "Parked as #12: referral program for studio
owners" on the issue path, "Parked: referral program for studio owners" on the file path —
and you're back to what you were doing. Issues are an inbox, not a second ledger:
every parked issue gets swept at triage, and its decision lands in this file, which remains
the single canonical, git-versioned record.

The bar for a capture is deliberately low — three fields, all gut calls:

- **One line.** Enough to recognize the idea on Thursday. Not a spec, not a pitch. "Referral
  program for studio owners" is a capture; three paragraphs on referral mechanics is work.
- **`energy` (high / med / low).** How excited the capturer is, right now. A 5-second call.
- **`effort` (S / M / L).** Gut-call size. Also 5 seconds.

Why these two fields and no others: at triage, energy tells you whether the excitement survived
the week — the single best cheap filter for shiny-object ideas — and effort tells you roughly
what saying yes would cost. Neither needs to be *right*. They need to be *fast*, because any
field that takes thought turns capture into work, and capture that costs effort stops
happening.

**Never analysis at capture.** This is a rule for the coach as much as the human: no
feasibility sketch, no "here's how we'd build it", no clarifying questions beyond what fits in
the one line. Analyzing an idea *is* working on it. The moment the coach starts exploring an
implementation, the idea has captured you instead of the other way around.

**How the ledger gets written:** the issue path needs no commit at all — that's the point. The
file writes that remain (the capture fallback, plus the batched ledger write at every triage)
use one of two mechanics, chosen by the state of the default branch:

- **Unprotected** → the coach commits directly: a temporary worktree from `origin/<default>`,
  never switching the branch you're working on, pushed as `HEAD:<default>`.
- **Protected** → a small state PR: branch `okrdev/state-<date>-<slug>`, pushed, opened as
  `okrdev: <what>` with a `KR:` line, and merged immediately (`gh pr merge --squash` — or
  auto-merge when required checks must run first).

Because ledger writes are batched by ritual — one commit or PR per triage and per check-in,
not one per item — the protected path costs about one PR a week. Honestly: the *file fallback*
on a protected repo degrades to ~30 seconds per capture, since each mid-week line is its own
state PR. That's the price of branch protection without a GitHub remote, and it's one more
reason the issue path is primary. The opt-in actor bypass in
[templates/stack/branch-protection.sh](../templates/stack/branch-protection.sh) still exists
for teams that want direct pushes back (admins may push directly; the `okrdev/**`-only
discipline is the coach's contract, not GitHub's), but state PRs are the standard path on
protected repos.

## The iron rule

**Nothing in Captured gets worked on. Ever. Triage first.**

The rule is absolute because the lot only works if capture is *safe*. The moment Captured items
sometimes get built, a capture stops being a note and starts being a soft commitment — and
people respond rationally: they stop capturing things they aren't sure about, which is exactly
the set of ideas the lot exists to hold. The wall between "written down" and "worked on" is
what makes it costless to write things down.

The rule covers both inboxes. **Parked issues are inert by convention**: never assigned, never
milestoned, never worked. The label's own description says what happens to them instead —
triaged weekly, then closed — and the wall lives in the label's lifecycle: open = captured,
closed with a decision comment = triaged.

It also protects you from your best trick: "I'll just take a quick look" is how afternoons
disappear. There is no quick look. There is a side-quest, and side-quests get time-boxes.

The one legal shortcut: you can sanction a side-quest **on the spot** with
`/okrdev:side-quest` — that moves the item out of Captured and into Side quests, with a box,
*before* any work starts. The rule survives intact: work never happens on anything while it
sits in Captured. What the shortcut changes is that you don't have to wait until Thursday to
make a deliberate decision — you just can't skip making one.

## Triage: every item gets a decision

Triage runs weekly, inside the check-in (the "Parking lot triage" section of
`okrdev/checkins/<cycle>/<yyyy-Www>.md`) or standalone via `/okrdev:triage`. It sweeps two
inboxes into one decision list: every open `okrdev:parked` issue
(`gh issue list --label okrdev:parked --state open`) plus every line in Captured. Each item
leaves with exactly one of three outcomes:

- **Promote.** The idea serves the current cycle — it maps to an existing KR (`→ KR2.1`) and
  becomes real, taggable work — or it's strong but out of cycle, in which case it's promoted as
  a `next-cycle candidate` and waits for planning. Promotion is the only path from idea to
  sanctioned KR work.
- **Archive.** With a one-line reason. Archiving is the most common right answer, and it's a
  success, not a failure: the idea got its fair hearing and lost. The reason line matters
  because good ideas recur — when "referral program" shows up again in October, the line
  "archived July: no channel to promote it yet" turns a rerun into a re-evaluation.
- **Side-quest.** Worth doing, serves no KR, small: it gets a time-box and moves to the Side
  quests section.

Issue items get closed with the decision as a comment —
`gh issue close <n> --comment "okrdev triage: promoted → KR1.3"`,
`"okrdev triage: archived — <reason>"`, or `"okrdev triage: side-quest, box: 4h"` — and the
decision *also* lands in this file's Promoted / Archived / Side quests sections, because the
file is the ledger and issues are only an inbox. Both inboxes go to zero every triage. The
ledger write is batched: one commit or state PR per triage, not one per item.

Refusing to decide is legal — the coach never blocks, and a deferral is an override like any
other. But the coach keeps count, and an item that survives its third triage gets asked about
by name: "Energy was high on July 13. You haven't missed it since. Archive it?" Undecided ideas
cost a little attention every single week; letting them silently carry over is how the lot
turns into the guilt-generating backlog it was built to replace.

Why the energy/effort fields earn their keep here: `energy: high` last Tuesday that reads flat
today is the system working — the week filtered the dopamine out. `energy: high, effort: S` two
weeks running is a strong side-quest candidate. `effort: L` means the real decision is "does
this belong in next cycle's planning?", not "should we squeeze it in?"

Three verbs sharpen the reason line — **build, box, or buy** (the full lens is in
[evidence.md](evidence.md)). **Buy**: the idea is a solved problem the market already sells —
archive it with "already solved elsewhere — adopt X" as the epitaph, the sharpest reason line
there is (the triage script's "duplicate of what CRM already does" is the house example).
**Box**: it keeps the lights on but doesn't win anything — box, as in: it gets one, a
bounded budget (a time-box or the maintenance budget), never open-ended investment — and it
never auto-promotes to next-cycle candidacy on its own. **Build**:
work only this team can do that a stakeholder of the mission would recognize as winning — the
only thing promote is for. Why the lens earns a place in a framework premised on cheap
execution: when building is cheap, teams build the already-solved because they can. The
build-the-buyable trap gets worse, not better, in exactly the era this framework is built
for.

## Side quests and the box-hours budget

A side quest is a sanctioned distraction: work everyone agrees serves no KR, done anyway,
inside a time-box. They exist because the lot has to be a rudder, not a straitjacket — a system
with no pressure valve gets taken off the first week it pinches, and some no-KR work (a tool
that scratches an itch, an experiment that might become next cycle's objective) is genuinely
worth hours.

**Time-boxed, always.** An unboxed side quest is just drift with paperwork. The box is set when
the quest is sanctioned — at triage or on the spot via `/okrdev:side-quest` — and logged:

```markdown
- [2026-07-13] CLI for bulk-importing class schedules — @alex — box: 4h — spent: 2h — status: open — notes: —
```

`spent` gets updated as you go or at the check-in; honesty here is cheap and drift here is
visible.

**The budget.** Default: **4 box-hours per person per week**, configurable as
`side_quest_box_hours_per_week` in `okrdev/config.md`. The budget is computed per person by
summing the `box:` fields of side quests opened this ISO week (by the line's date) — no
timesheets, no new tracking. Quests still open from earlier weeks don't hit this week's budget;
their staleness is the triage sweep's job. That's the reason it's
box-hours and not the classic "10% of your time": 10% of time is unmeasurable without
surveillance, while the `box:` fields are already sitting in the file. The budget costs nothing
to enforce because the data is a side effect of the sanctioning ritual.

When a new box would blow the budget, the coach says so. It's still advisory — you can
override, and the override gets logged like any other judgment call — but the number is on the
table before the hours are gone.

**When the box runs out**, the quest gets a decision at the next check-in, like everything
else:

- **Close it** — `status: done`, with a note on what it produced or taught. At the close the
  coach asks once — "anything to show? a link, a screenshot, one line" — and never mid-box:
  the box is sanctioned play, not a deliverable contract. A closed quest that produced
  nothing was still cheap; that's the box doing its job.
- **Extend it** — a new box, set deliberately and logged. Extension is legal; *silent* overrun
  is what the `spent` field exists to catch.
- **Promote it** — it proved itself. It maps to a KR now, or it goes in as a next-cycle
  candidate. Some of the best objectives start as side quests; the box is how you find out
  cheaply.

Work done under a side quest is tagged `KR: side-quest` on PRs and commits, so the drift check
recognizes it as sanctioned rather than orphaned — see [method.md](method.md) for the full
classification taxonomy.

## Cycle boundaries

Promoted items are one of planning's three standing inputs: `/okrdev:plan` reads the Promoted
section alongside `okrdev/MISSION.md` and `okrdev/LESSONS.md` before drafting candidate OKRs.
This closes the loop — capture, triage, promote, plan, build — and it's why archiving at triage
is safe: an idea doesn't need to win *this week* to win. The path from shower thought to next
quarter's KR runs entirely through the lot, without ever interrupting a working day.

After planning, the coach sweeps Promoted: items that landed in the new cycle get their `→ KR`
notation, candidates that didn't make the cut get archived with the reason ("lost to O2 at
planning") or explicitly carried as candidates for the cycle after. Promoted is a waiting room,
not a second backlog.

**At Level 0** — parking lot installed, no cycle yet — everything above still runs, with two
adjustments: promote always means `next-cycle candidate` (there are no KRs to map to), and
triage runs standalone via `/okrdev:triage` on a weekly moment you pick, since there's no
check-in to host it. A few weeks of captures and triage calls make the first
`/okrdev:plan` dramatically better: you arrive with evidence of what you actually keep wanting
to build, not a blank page.

## Capturing away from your desk

The issue path is the fix. The best ideas do not schedule themselves around repo-connected
sessions, and on a GitHub-remote repo they no longer have to:

- **From your phone:** open the GitHub mobile app, file an issue with the `okrdev:parked`
  label. Title = the idea; energy and effort in the body if you have the extra five seconds.
  It lands in the same triage sweep as everything parked from a session.
- **From a collaborator:** anyone with repo access can park from the GitHub UI — no Claude
  session needed. The collaborator files "referral program for studio owners" from his browser, and it
  gets its fair hearing on Thursday like everything else.
- **The low-tech fallback:** note ideas wherever you already do (phone notes, a text to
  yourself), then open your next session with "park three things from my phone notes." The
  coach captures them one line each — original dates if you have them, today's if you don't.
