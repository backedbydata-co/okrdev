# DRI onboarding: zero to your first shipped change

You've been made the DRI for an objective or a key result, and you don't program. This guide
takes you from nothing — no GitHub account, no tools installed — to having shipped a real
change to the real product, previewed, reviewed, and merged by you.

Budget about an hour. Most of it is waiting for email invitations and one tool install, not
learning.

Unfamiliar words are on purpose kept to ten, and all ten are defined in plain language in
[shipping-explained.md](shipping-explained.md). Read it first — it's short — or just ask your
coach to explain any word as it comes up. It's required to.

## Note to the coach

This document is written to be run by you, conversationally. When a new or non-technical human
shows up (or `/okrdev:coach` detects one), offer this walkthrough and then:

- Run one step at a time. Stop at each "You're done when" checkpoint and confirm before moving
  on. Don't summarize the whole document up front.
- Use the plain words from [shipping-explained.md](shipping-explained.md), and narrate every
  git or GitHub action as you perform it ("I'm opening a pull request — that's a proposal page
  with a link you can click").
- Do all the plumbing yourself. The human never types a git command, resolves a conflict, or
  reads a stack trace. That's your rule 10 ([ai-coach.md](ai-coach.md)).
- Never handle their credentials. Accounts, passwords, and payment details belong to the human
  alone. Step 1 is theirs; guide, don't drive.
- If okrdev isn't installed in the repo, say so plainly and point at `/okrdev:install` — but
  that's a team decision, so loop in whoever runs the repo. If there's no active cycle, the
  exercise in step 4 still works: it's a `maintenance` change, and Level 0 handles those fine.

## What you need before starting

- A computer you're allowed to install software on. Step 2 puts Claude Code or Codex on it;
  a locked-down work laptop may need IT's blessing first, and that's worth finding out now
  rather than in twenty minutes.
- An email address.
- One teammate with admin access to the project's repo — or the backstop named in
  `okrdev/config.md` — who can invite you. If you're a solo founder, you *are* the admin and
  step 1 is shorter.

## Step 1 — Get a GitHub account

GitHub is where the project lives: every file, every version, every proposal. You need an
account because your sign-offs have to carry your name. When you approve a change or press
merge, the record should say *you* did — that's what being a DRI means on paper.

This is the one step you do entirely yourself. Creating accounts and choosing passwords is
yours alone; your coach will talk you through it but never touch it.

1. Go to github.com and sign up. The free tier is fine.
2. Ask your teammate (or the backstop) to invite you to the project's repo, with "write"
   access.
3. Accept the invitation from the email GitHub sends you.

**You're done when** you can open the repo's page in your browser and see a list of files
instead of a "404" page.

## Step 2 — Pick where you'll talk to Claude

The coach, the builder, and the scribe are all the same assistant ([roles.md](roles.md)); what
varies is the surface you talk to it through. The hard requirement: the assistant must be able
to read and write the repo as a working tree. That narrows the list to two — see
[Supported surfaces](adoption.md#supported-surfaces) for why.

- **Claude Code.** The terminal tool developers use. The most capable surface, and the one
  every okrdev skill is verified against. This is the default; pick it unless you have a
  reason not to.
- **Codex.** OpenAI's equivalent, and equally supported. Same skills, same repo. What differs
  is one instructions file and one invocation style — [codex.md](codex.md) has the table.

Neither one is a browser tab, and that is this guide's honest cost: **you install a tool before
you start.** It's the step most likely to want a teammate for ten minutes, so ask for that help
rather than grinding at it alone. Everything after it is conversation.

Switching between the two later costs nothing — the state all lives in the repo, not in the
tool.

**You're done when** you can send Claude a message and it confirms it can see the repo.

## Step 3 — Let the assistant do the plumbing

Developers "clone" repos, manage "remotes," and juggle branches. You don't. The assistant
handles every bit of that, invisibly, forever — connecting to the repo, making scratch copies,
keeping things in sync. Merge conflicts are not a thing that happens to you; they're a thing
the coach resolves before you hear about them.

Run one verification test. Ask:

> "Read `okrdev/config.md` and tell me what level this repo runs okrdev at, and who the
> backstop is."

If the answer clearly comes from the actual file — a level number, a real name — you're wired
up. This test works at every install level. If the coach says there's no mission or cycle yet,
the repo is at Level 0 or hasn't run `/okrdev:plan` — that's fine for this walkthrough; the
step-4 exercise is a `maintenance` change and needs neither. If the coach says okrdev isn't
installed at all, that's a separate conversation: point whoever runs the repo at
[adoption.md](adoption.md) and `/okrdev:install`.

**You're done when** the assistant answers questions from the repo's real contents.

## Step 4 — Ship one tiny change, end to end

Now the actual exercise: take one change through the full lifecycle from
[shipping-explained.md](shipping-explained.md) — propose, build, preview, click-test, merge.

Pick something tiny and boring **on purpose**: a typo, a wording improvement, your name added
to a team page. The goal is to learn the pipeline while the stakes are as close to zero as
possible. Do not pick anything you actually care about — caring interferes with learning the
mechanics. Your coach will classify a change like this as `maintenance` in one line and move
on; that's normal ([method.md](method.md)).

The five beats:

1. **Propose.** Tell the coach what you want changed, in plain language: "On the pricing page,
   change 'per seat' to 'per person'." No file names, no code. Describing *what a user should
   see differently* is a complete specification.
2. **Build.** The coach makes the change on a scratch copy and opens the proposal page — the
   PR. It will narrate as it goes and hand you the link. Open it. Read the description; it
   should say in words what changed and why, and carry a `KR:` line (here: `maintenance`).
3. **Preview.** Within a few minutes the proposal gets a preview — a private copy of the whole
   app with your change in it, at a URL. The coach hands you the link in chat along with
   click-test steps: exactly what to click and what you should see. If the preview link asks
   you to log in to something you've never heard of, stop — that's a setup bug (previews are
   required to open without any special account, see [stack.md](stack.md)). Tell the backstop.
4. **Click-test.** Open the preview and actually do the clicks. Find your change. Then poke
   around near it — the page it's on, the flow it sits in. You're checking that the change is
   right *and* that nothing nearby got weird. Try it on your phone too; previews are just URLs.
5. **Merge.** Back on the proposal page: is the robot's check green? Is any box in the risk
   checklist checked (it shouldn't be, for a wording change)? Then press merge. Your change is
   now live. Go look at the real product and find it. That feeling is the point of this whole
   exercise.

   If the proposal page has no risk checklist, your repo hasn't installed the Level 2 PR
   template yet — that's fine. Ask the coach the same questions out loud instead: "does this
   touch the database, login, payments, or delete any data?"

If CI comes back red at any point: don't decode it, don't apologize for it. Ask the coach
"what does this mean and what do we do?" It will translate the failure into plain language and
propose the fix. You decide; it types. Red CI is the system working — the problem was caught
before it reached anyone.

**You're done when** your change is live in the real product and the merged proposal has your
name on it.

## Step 5 — Learn your standing routine: reviewing without reading code

The exercise you just did is a one-off. What follows you forever as a DRI is *reviewing* —
other people (and the assistant itself) will ship changes to things you own, and your sign-off
has to mean something. Here's how to review a proposal without reading a line of code. Run it
every time:

1. **Ask for the plain-language summary.** "Summarize this proposal for me. What changes for a
   user? Why now, and which KR does it serve?" The coach gives you the diff in words. If the
   `KR:` line says `side-quest` or `emergency`, ask about the time-box or what the emergency
   protected.
2. **Ask what could break.** "What's the riskiest part of this change?" Insist on a concrete
   answer. Check whether any box on the risk checklist is checked — database shape, login,
   payments, deleting data. (No checklist on the page? The repo runs without the Level 2 PR
   template — ask the coach those four questions directly instead.)
3. **Open the preview and follow the click-test steps** written in the proposal. Actually do
   the clicks. A summary you read is a claim; a preview you clicked is evidence.
4. **Check who else must sign off.** If the change touches a risky area, the named domain
   reviewer's approval is required before yours matters — the rails enforce this
   automatically, so mostly you just wait for their green check. Never merge around it.
5. **Decide.** Merge, or send it back with plain-language feedback: "the new button overlaps
   the menu on my phone." You don't propose the code fix — the coach turns your feedback into
   one.

One rule of thumb covers most failure modes: **never merge anything you haven't clicked.** If
there's no preview to click, ask why, and get shown evidence some other way before you merge.

You also never need to watch GitHub notifications. The coach is your notification bridge: at
the start of a session it tells you, in a line or two, if anything of yours needs attention —
a preview ready to test, a review going stale, a red check. If a session starts quiet, things
are quiet.

## If your repo doesn't have previews

The routine above assumes the full rails. Not every repo has them yet, and okrdev works there
too — honestly, just with a weaker step 3:

- **Brownfield code repo, no previews.** The coach demonstrates the change another way —
  screenshots of before and after, a recorded walkthrough, or running the app locally and
  describing it. These fallbacks are the demo rung of the evidence ladder in
  [evidence.md](evidence.md), in another medium — "a summary you read is a claim; a preview
  you clicked is evidence" now has a named ladder behind it. That works, but it's the coach
  showing you evidence rather than you gathering it. This gap is the single best argument for
  adopting the Level 2 rails or the stack module ([adoption.md](adoption.md)).
- **Non-code business, repo as ledger.** Your first shipped change is an edit to a shared
  document — the mission, a checklist, a price list — through the exact same proposal-and-merge
  flow. Same proposal page, same review, same merge button; there's simply no app to preview.
  The reviewing routine still applies, minus step 3.

## What you own now

The full role definitions live in [roles.md](roles.md); the short version:

- **You own the number, the decisions, and the shipping — not the typing.** The assistant
  builds, translates, and keeps the books. You decide what gets built and whether it's good
  enough to merge. Confidence updates and the KR's score at retro are yours to defend.
- **The AI is never the DRI.** It wears three hats — builder, coach, scribe — and
  accountability stays with a human in every one of them. When the coach challenges a plan of
  yours, it's doing its job; when you override it, that works immediately and gets logged as a
  judgment call, not a demerit ([ai-coach.md](ai-coach.md)).
- **You're not the last line of defense.** If you and the coach are both stuck — a broken
  install, a preview that won't load, a review nobody answers — invoke the backstop named in
  `okrdev/config.md`. That's a designed part of the system, not an admission of failure. Ask
  early.

From here: `/okrdev:coach` any time you want status or an "is this aligned?" answer,
`/okrdev:park` the moment an idea tries to eat your afternoon, and
[../examples/acme-fitness/](../examples/acme-fitness/) when you want to see what a full cycle
looks like, warts included.
