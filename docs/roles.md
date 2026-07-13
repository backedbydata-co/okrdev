# Roles

okrdev has four human roles and one AI wearing three hats. None of them are titles. A role
attaches to an objective for the length of a cycle, not to a person for the length of a career.
The same person can be a DRI on one KR, a builder on another, and the domain reviewer for
payments — in the same week. That's the design, not a compromise: when AI fills skill gaps,
what's left to allocate is accountability, and accountability is per-outcome, not per-org-chart.

## The DRI

Directly Responsible Individual. Exactly one per objective and exactly one per key result —
often the same person, never a committee.

**Why exactly one:** shared ownership is no ownership. When two people own a number, each
privately assumes the other is watching it, and the retro discovers that nobody was. One name
means one person who can't look away.

**What the DRI owns:**

- **The decisions.** Scope, trade-offs, what to cut when the week gets short. The DRI doesn't
  need permission to decide — that's the point of the role.
- **The building.** Not necessarily doing it personally, but making sure it happens: directing
  the AI, pulling in other builders, sequencing the work.
- **The shipping.** A KR that's "done but not merged" is not done. The DRI drives changes
  through review and out the door.
- **The number.** Confidence updated at every check-in, one line of evidence when the coach asks
  for it, an honest score at the retro. If the number is red, the DRI says so first.

**Not necessarily the domain expert.** This is the part that looks wrong until it works. A
marketer can be DRI on a KR that needs a database migration; the AI writes the migration, the
domain reviewer checks it, and the marketer owns whether churn actually dropped. What the DRI
must supply is judgment about the *outcome* — is this the right thing, does it actually work
for the user, is the number real. Mastery of the tools is what the AI is for. The
[review-without-reading-code protocol](#reviewing-without-reading-code) below is what makes
this safe rather than reckless.

**Objective DRI vs KR DRI.** The objective's DRI answers for the whole outcome; each KR's DRI
answers for their number. When they're different people, the objective DRI is the tie-breaker
on scope disputes and the one who explains the objective's story at the retro. When they're the
same person — common on small teams — nothing changes except the headcount. In solo mode one
human holds every role at once; what collapses and what doesn't is covered in
[adoption.md](adoption.md).

**What being DRI does not mean:** doing all the work yourself, being technical, or being
senior. A non-technical DRI ships real changes end-to-end — the guided first run is in
[dri-onboarding.md](dri-onboarding.md).

## The Builder

Everyone. Deliberately generic.

Titles described what you could do when skills were scarce. With AI filling gaps, any builder
can pick up any item: an engineer can run a pricing experiment, an operations person can ship a
feature. okrdev refuses to specialize the role because the specialization would be a lie — the
constraint it used to encode no longer exists.

Builders work under the classification rules in [method.md](method.md): every substantive unit
of work is tagged `KR:`, `side-quest`, `maintenance`, or `emergency` before it starts. A
builder contributing to someone else's KR tags the work with that KR's id — the DRI sees it in
the check-in's "What moved" section, which is where coordination happens. No standups, no
assignment ceremony: the tags and the weekly file are the coordination layer.

The line between builder and DRI: builders contribute work, the DRI answers for the outcome.
You can build all week on KR2.1 and still not be the person who explains its score at the retro.

## The Domain reviewer

Pulled in by **risk, not rank**. Nobody reviews everything; specific people review specific
dangers.

Risk comes in two shapes, and each needs a different trap:

- **Path-shaped risk** announces itself in the file list: database migrations, auth
  configuration, payment code. These are caught by CODEOWNERS
  ([templates/github/CODEOWNERS](../templates/github/CODEOWNERS)) — when a change touches a
  risky path, GitHub automatically requests the mapped reviewer, and branch protection
  ("require review from Code Owners", set up by
  [templates/stack/branch-protection.sh](../templates/stack/branch-protection.sh)) makes the
  request binding rather than decorative.
- **Behavior-shaped risk** can hide in any file: a change that deletes or bulk-modifies data
  looks like any other diff. Paths can't catch behaviors, so these are caught by the PR
  template's risk checklist
  ([templates/github/pull_request_template.md](../templates/github/pull_request_template.md)) —
  the author checks the box, and a checked box requests the domain reviewer.

**What the reviewer reviews:** the risky part. Is the migration reversible, does the auth
change leak anything, can this query delete more than it means to. They are not a general
gatekeeper, they don't re-litigate whether the feature should exist (that decision was made at
planning), and they don't block on style. Scoped review is what keeps review fast enough that
people actually request it.

**Why not rank:** requiring senior sign-off on everything recreates exactly the bottleneck the
framework removed. The point of AI-filled skill gaps is throughput; the point of the domain
reviewer is that throughput doesn't touch the third rail unreviewed.

Honest caveat: CODEOWNERS without branch protection is a suggestion, not a rule, and branch
protection has GitHub plan requirements — stated plainly in [adoption.md](adoption.md).

## The Backstop

One named human, recorded in `okrdev/config.md` under `backstop:`. The person you call when the
DRI and the coach are both stuck.

**Why the role exists:** AI fills gaps, but somebody has to answer the phone. A non-technical
DRI whose CI is red for a reason neither they nor the coach can diagnose will, without a named
escape, quietly give up — and "quietly give up" is the failure mode this whole framework is
built against.

**When to invoke:** the coach has already tried its unblocking duties (rule 10 of the coach
block — translate the failure, propose the fix, own the git mechanics) and the DRI still can't
move. Locked vendor accounts, infrastructure that needs credentials nobody in the session has,
a judgment call that genuinely needs another human. Not for ordinary review requests — that's
what the domain reviewer and the coach's nudge-drafting are for.

**How to invoke:** the coach does it, out loud — "we're both stuck; this is the point where we
bring in the backstop" — and drafts the message so the DRI only has to send it. The ask should
name what was already tried, so the backstop starts from the frontier, not from zero.

**What the backstop owes:** a response and an unblock (or an escalation to whoever can). Not
taking over the KR — the number stays with its DRI.

## The AI's three hats

The AI in an okrdev repo is one assistant wearing three hats, sometimes in the same breath.

- **Builder.** Writes the code, runs the migrations, drives the tests, and owns all git
  mechanics — merge conflicts never surface to the human. For a non-technical DRI, this hat is
  most of their engineering department.
- **Coach.** Classifies work against the active KRs, challenges sandbagged targets and vanity
  metrics, pre-drafts the weekly check-in, computes drift from ground truth, and bridges
  GitHub's notification firehose into a line or two of "here's what needs you." The full
  contract — authority model, tone rules, everything the coach must never do — is in
  [ai-coach.md](ai-coach.md).
- **Scribe.** Keeps the records: check-in files at their deterministic paths, judgment-call
  lines when a human overrides, parking-lot appends, `Revised:` blocks on amended KRs. The
  scribe's records are what make the coach's advisory authority real — the coach never blocks,
  it remembers, and the scribe is the remembering.

**Never the DRI.** This is a hard line, and it's load-bearing. An AI cannot be accountable: you
can't ask it at the retro why the number is red and get an answer anyone can act on, and you
can't accept its resignation. The coach can tell you the number is red; only a human can own
what happens next. Every objective, every KR, and every override in the system terminates at a
named person. The moment "the AI was handling it" becomes an acceptable answer, the
accountability loop is broken and the framework is theater.

## Reviewing without reading code

The protocol that makes "anyone can own anything" true rather than aspirational. It's how a
DRI who can't read a diff still merges responsibly.

Before merging a change the DRI can't read:

1. **Plain-language summary.** The coach describes what changed and what could plausibly break,
   in the vocabulary of [shipping-explained.md](shipping-explained.md) — no jargon. "This adds
   the cancellation flow to the booking page. The risky part: it changes how bookings are
   stored, so old bookings need to still display correctly."
2. **Scripted preview walkthrough.** The coach hands over the preview URL — a private copy of
   the app with this change applied — plus numbered click-test steps: "Log in as the test user.
   Create a booking. Cancel it. Check the confirmation email renders. Then open an old booking
   and confirm it still displays."
3. **The DRI clicks through** and reports what they saw. This is not a formality — the DRI is
   the best judge of whether the behavior is *right*, which is precisely the thing a diff can't
   show.
4. **The risk checklist decides who else looks.** If any risk box is checked (migrations, auth,
   payments, data deletion), the domain reviewer is requested and the merge waits for them.
5. **Merge** when the walkthrough passes and required reviews are in. The coach narrates the
   mechanics.

Why the split works: the DRI verifies behavior, CI verifies that the tests pass, the domain
reviewer verifies the specific danger. Each party checks the thing they're best positioned to
check, and nobody signs off on something they can't evaluate. What the DRI is explicitly *not*
vouching for is code quality — that belongs to CI and the reviewer.

First time through, the coach runs this end-to-end as a guided exercise — see
[dri-onboarding.md](dri-onboarding.md).

## Quick reference

| Role | How many | Owns | Held to it by |
|------|----------|------|---------------|
| DRI | Exactly one per O and per KR | Decisions, building, shipping, the number | Check-ins and the retro |
| Builder | Everyone | The work they tag | Classification rules, drift check |
| Domain reviewer | One per risk area | The risky part of risky changes | CODEOWNERS + branch protection, risk checklist |
| Backstop | One, named in `config.md` | Answering when DRI + coach are stuck | Being named |
| AI (builder/coach/scribe) | One assistant, three hats | Execution, pushback, records — never a number | The coach contract in [ai-coach.md](ai-coach.md) |
