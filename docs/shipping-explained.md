# Shipping, explained

How a change gets from "someone had an idea" to "it's live" — told in plain language, no code
required. If you're a DRI who doesn't program, this is the entire vocabulary you need: one
story, ten words, one table.

Read it once. Then [dri-onboarding.md](dri-onboarding.md) walks you through doing it for real.

## Why this document exists

okrdev bets that anyone can own anything ([../MANIFESTO.md](../MANIFESTO.md)). That bet only
pays if the machinery of shipping can be explained in plain words — otherwise "anyone can own
anything" quietly becomes "anyone who already speaks git."

So this is the official dictionary. Every okrdev skill is required to use these plain words
when talking to non-technical humans. When your coach says "I'm opening a pull request —
that's a proposal page with a link you can click," it's following this document. If it ever
slips into jargon, ask it to translate. It has to.

## The story of one change

Follow a single change — say, new wording on the pricing page — from idea to live.

### The repo is the project's memory

Everything the project is made of lives in one shared place called a **repository** — the
repo. Think of it as a folder with a perfect memory: every version of every file, ever, with a
record of who changed what and why. Nothing is ever truly deleted; there is only "the current
version" and "every version before it."

This matters more than it sounds. Because the repo remembers everything, no change is truly
dangerous. The worst case is never "we lost it" — it's "we went back to yesterday's version."

### A branch is a scratch copy

Nobody edits the live version directly. To draft a change, you (or the assistant working for
you) make a **branch** — a scratch copy of the whole project. You edit the copy. The live
version doesn't know or care.

It's the same instinct as duplicating a document before rewriting a paragraph: draft on the
copy, keep the original safe until the draft is ready to be judged.

### A PR is a proposal page with a link

When the draft is ready, it becomes a **pull request** — a PR. Ignore the odd name. A PR is a
proposal page with a link you can click. On it you'll find:

- what changed, described in words;
- the exact edits, for anyone who wants that level of detail;
- a comment thread where people discuss, question, and request changes;
- in an okrdev repo, a `KR:` line naming which key result the work serves — or declaring it
  `maintenance`, `side-quest`, or `emergency` (see [method.md](method.md));
- and, in a moment, a robot's verdict and a preview link.

Nothing on a proposal page is live. You can read it, argue with it, reject it outright — the
real product never notices. That's the whole point: the proposal stage is where scrutiny is
cheap.

### CI is a robot that checks the proposal

The moment a proposal opens, **CI** wakes up — a robot that checks it. It runs every automated
test the team has ever written, tries to build the whole app with the change in place, and
reports back: a green check means everything passed; a red X means something failed.

Two things to know about the red X. First, it fired *before* the change could reach anyone
real — red is bad news arriving at the cheapest possible moment, which makes it good news.
Second, decoding it is not your job. Your coach translates red CI into plain language and
proposes the fix ([ai-coach.md](ai-coach.md)). You decide; it types.

### A preview is a private copy of the app at a URL you can click

For every proposal, the machinery builds the entire app *as if the proposal were accepted* and
puts it at a private link — the **preview**. Open it on your laptop or your phone. Click the
thing that changed. Click the things near it.

On the okrdev stack ([stack.md](stack.md)), each preview even gets its own disposable copy of
the database, filled with made-up data — never real customer data. So you can poke anything,
break anything, submit nonsense into every form, and nothing real is touched. When the
proposal closes, the preview and its database evaporate.

The preview is the non-technical reviewer's superpower. You don't judge a change by reading
code. You judge it by using it. When your coach says **demo**, this is what it means: the
preview plus the exact clicks to try — the change shown to you instead of described to you.

One rule that follows from this: preview links must open without any special account — no
login wall. That's a required, verified step of the okrdev stack install. If a preview link
ever asks you to sign in to something you've never heard of, that's a setup bug, not a you
problem. Report it.

### CODEOWNERS means "this kind of change needs sign-off from this person"

Some changes carry more risk than others. A wording tweak is one thing; a change to the
database, the login system, or payment code is another. **CODEOWNERS** is a file that lists
the risky areas of the project and names the human who must sign off on each. Touch a risky
area, and GitHub automatically asks that person to review — no one has to remember.

This is how okrdev pulls expertise in by risk, not rank ([roles.md](roles.md)). A marketer can
own and ship a database change; the database expert just has to approve it first. The rule
lives in the rails, not in an org chart.

A word that shows up on that risky list: **migration**. A migration is a change to the *shape*
of the database — adding a column, renaming a table. Most changes only touch code; a migration
touches the structure holding real customer data, and a bad one can lose data in ways a revert
can't fully undo. That's why migrations always get a domain reviewer and extra ceremony.

### Merge means it goes live

When CI is green, the preview checks out, and the required people have signed off, someone
presses **merge**. Merge is the accept button: the proposal stops being a proposal and becomes
part of the live version.

On okrdev-stack repos, merge *is* the release. The accepted change deploys automatically —
there is no separate "push it to production" step that someone can forget, fumble, or do
half-asleep at 2am. All the scrutiny happens before the button. That's what makes pressing it
boring. Boring is the goal.

### And if it's wrong anyway

Sometimes a change survives every check and is still wrong — the wording tests fine and reads
terribly, the feature works and confuses everyone. Fine. The repo remembers every version, so
undo is always on the table: a **revert** is just a new proposal that removes the old change,
and it goes through the same story — proposal page, robot, preview, merge.

Mistakes in this system cost minutes, not weekends. Which is exactly why okrdev lets
non-technical people ship: safety is an environment, not a behavior.

## Where the okrdev words fit in

Three more words, and you're fluent.

A **DRI** — directly responsible individual — is the one human who owns an objective or key
result end-to-end. Not a committee, not a rotation. One name ([roles.md](roles.md)).

A **KR** — key result — is a measurable outcome the cycle commits to. Every substantive piece
of work names the KR it serves on its proposal page, or says out loud what it is instead
(maintenance, side-quest, emergency).

**Drift** is work that traces to no KR and hasn't said so. It's not a crime — it's a question.
The coach computes it from the actual record of merged proposals and raises it with you
privately before it appears anywhere shared ([ai-coach.md](ai-coach.md)).

## The glossary

| Term | In plain words |
|------|----------------|
| **PR** (pull request) | A proposal page with a link: what's changing, why, and a place to discuss it. Nothing on it is live. |
| **branch** | A scratch copy of the project where a change is drafted without touching the live version. |
| **merge** | The accept button. The proposal joins the live version — and on the okrdev stack, goes live automatically. |
| **CI** | A robot that checks every proposal: runs the tests, tries the build. Green means it passed; red means a problem was caught before anyone real saw it. |
| **preview** | A private, disposable copy of the app at a URL you can click, showing the proposal as if it had been accepted. |
| **demo** | The preview plus the exact clicks to try: the change shown to you instead of described to you. |
| **CODEOWNERS** | A file that means "this kind of change needs sign-off from this person." GitHub asks them automatically. |
| **migration** | A change to the shape of the database — the structure holding real customer data. Always treated as risky, always reviewed by the domain expert. |
| **drift** | Work that doesn't trace to any key result and hasn't declared what it is instead. The coach notices and asks — privately, first. |
| **DRI** | Directly responsible individual: the one human who owns an objective or key result end-to-end. |
| **KR** | Key result: a measurable outcome the cycle commits to. Substantive work names the KR it serves. |

That's the whole language. When you're ready to use it,
[dri-onboarding.md](dri-onboarding.md) takes you from zero to your first shipped change.
