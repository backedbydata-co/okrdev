# Adoption

How okrdev gets into your repo, what each level costs, and how it comes back out. The short
version: start at the bottom of the ladder, move up only when the current level has earned it,
and keep whatever stack you already have.

## Supported surfaces

okrdev runs in a **code session with a git repo**: Claude Code or Codex. That is a rule rather
than a list of products — a surface qualifies when it can read and write a working tree, run
`git`, and invoke the skills.

The distinction that matters is *code session*, not *desktop*. A code session has a shell and
a working copy whether it runs in a desktop app or in a terminal, so **you do not have to open
a terminal.** Claude Code and Codex both ship desktop apps, and the app is the path to
recommend — a non-technical DRI included: download it, open the project folder, and you are in
a code session. The terminal CLIs do the same job for people already living there.

Why the repo is non-negotiable: every skill leans on it. `/okrdev:install` refuses to proceed
without one and offers `git init` instead, and the coach's authority comes from reading what
actually landed — commits, merged PRs, the diff — rather than from what someone typed into a
status box. Take the repo away and okrdev degrades into OKRs in markdown, which is the one
thing it exists not to be (see [MANIFESTO.md](../MANIFESTO.md)).

**Not supported: Cowork** — the desktop app's *other* mode — along with Claude chat, claude.ai
in the browser, and any other session without a working tree. Cowork is the subtle one, because
it is the same application: the two modes share one plugin store, so a plugin installed on your
account can have its skills appear in Cowork whether or not it works there. "The skills loaded"
is not "the install works," and okrdev makes no promise about the gap.

What differs between Claude Code and Codex is one instructions file and one invocation style;
[codex.md](codex.md) has the table.

### The CLI the desktop app already ships

The Claude desktop app installs a `claude` binary and deliberately keeps it off your PATH. That
is why the Quickstart's first step says *find* a binary rather than *install* one: a terminal
user already has `claude` on PATH, and a desktop-app user already has one on disk. Between them
there is no case that needs a download.

**Verified on macOS** — 2026-08-25, against desktop app build 2.1.237. The binary lives at:

```
~/Library/Application Support/Claude/claude-code/<version>/claude.app/Contents/MacOS/claude
```

Take the highest `<version>`: the directory is version-numbered and moves on every app update,
so glob it rather than pinning one. `plugin marketplace add` and `plugin install` were both run
against it and produced a real install — plugin registered, skills resolving, manifest written.

**Windows is deliberately not recorded here.** The app resolves this location through Electron's
per-platform user-data directory rather than a hardcoded path, so the layout is expected to
differ and has not been checked on Windows. An agent told to *find* the binary handles either
platform; a path written down here would be a guess, and this file does not guess.

## Brownfield first

okrdev assumes you have an existing business with an existing codebase, existing habits, and no
appetite for a migration. That's the common case, not the exception.

So the method is fully decoupled from the stack. Nothing in Levels 0–2 cares whether you deploy
to Vercel or a VPS, whether you use Postgres or a spreadsheet, whether you even write code. The
install adds one directory (`okrdev/`), one marked block in your agent's instructions file, and — only if you opt
in at Level 2 — a few files under `.github/`. Your build system, your deploy pipeline, your
framework choices: untouched.

The [stack module](stack.md) exists for the opposite case — a brand-new project with no stack
to keep — and for teams deliberately migrating. It is never a prerequisite for anything else in
this document.

One brownfield advantage worth using: your repo already contains evidence. At install and at
planning, the coach offers to scan your recent commits, open issues, and merged PRs to draft a
straw-man picture of where effort actually goes. First-cycle OKRs argued against real data beat
first-cycle OKRs invented in a vacuum.

## The ladder

Four rungs. `/okrdev:install` walks them explicitly, starts at Level 0, and never installs a
higher level uninvited. Why so cautious? Because frameworks die of over-installation: a team
that gets ceremony before value deletes the whole thing by week three. Each level has to earn
the next.

| Level | What it is | Cost to adopt | Ongoing cost |
|-------|------------|---------------|--------------|
| 0 — Parking lot | Idea capture + triage | 10 minutes | ~0; capture is 10 seconds |
| 1 — The method | Mission, cycle OKRs, check-ins, retros | One planning session (~90 min) | ~15 min/week + ~60 min/cycle |
| 2 — Collaboration rails | `KR:` tags, okr-gate, PR template, CODEOWNERS, branch protection | An afternoon | ~0; the rails run themselves |
| Stack module | The full Vercel + Neon environment | A day | Normal ops |

Your current level is recorded as `level:` in `okrdev/config.md` frontmatter, so the coach and
every skill know what exists and behave accordingly — a Level 0 install has no cycle, and
`/okrdev:park` and `/okrdev:triage` work fine standalone.

The ladder goes both ways. If a level stops earning its minutes, remove its files (see
[Uninstalling](#uninstalling) for what belongs to what) and drop the `level:` number. No shame
in it. A framework you actually run at Level 1 beats one you resent at Level 2.

### Level 0 — Parking lot

**What installs:** `okrdev/PARKING_LOT.md`, `okrdev/config.md`, and a minimal version of the
coach block in `CLAUDE.md` or `AGENTS.md` (between `<!-- okrdev:start -->` / `<!-- okrdev:end -->` markers) —
just the parking rules: capture ideas in ten seconds, never work on anything in Captured, triage
weekly.

**What you get:** the single highest-value habit in the framework, with none of the ceremony.
Ideas stop dying in your head and stop eating your week. `/okrdev:park` captures; a weekly
`/okrdev:triage` decides. That's the whole level.

**Why it exists as a separate level:** value before ceremony. Ten minutes in, okrdev is already
useful — before you've written a mission statement or argued about a single metric. If you
never climb higher, Level 0 is still worth keeping.

**When to move up:** when triage keeps surfacing the same question — "promote this... to what,
exactly?" Promotion needs something to promote *into*. When you notice you're making
prioritization calls with no stated priorities, you're ready for Level 1. The full protocol is
in [parking-lot.md](parking-lot.md).

### Level 1 — The method

**What installs:** `okrdev/MISSION.md`, `okrdev/LESSONS.md`, `level: 1` in
`okrdev/config.md`, and the full coach block replacing Level 0's minimal one. This is okrdev
proper.

**What install deliberately does not write:** the cycle file. `okrdev/okrs/<cycle>.md` is
`/okrdev:plan`'s to create — it deserves a real planning session, not the tail end of an
install — and `okrdev/checkins/<cycle>/` appears the first time a check-in or a logged
judgment call needs it. So a freshly installed Level 1 repo has no objectives and no check-in
history yet. That's the expected state, not a half-finished install.

**What you get:** a mission the coach can hold you to, 1–3 objectives per cycle with 2–4 key
results each, weekly check-ins the coach pre-drafts so they genuinely take 15 minutes, and a
retro that scores honestly and extracts lessons. The rules live in [method.md](method.md); the
runnable rituals live in [rituals.md](rituals.md).

**What it costs:** one ~90-minute planning session to draft your first cycle (run
`/okrdev:plan`), then ~15 minutes a week and ~an hour per cycle for the retro. The weekly
number is real because the coach writes the file before you show up — if check-ins are taking
45 minutes, something is broken; see [rituals.md](rituals.md).

**When to move up:** when more than one person ships through pull requests. Level 1 alignment
lives in conversation and check-in files; that works until work starts flowing through PRs the
coach didn't see. Solo founders and non-code businesses often never need Level 2 — and that's
correct, not a compromise.

### Level 2 — Collaboration rails

**What installs:** each piece is a separate opt-in question during install — you can take some
and skip others:

- **`KR:` lines on PRs** (and in commit messages for direct-to-main shops) — the ground truth
  the drift check reads.
- **The okr-gate action** (`.github/workflows/okr-gate.yml`) — comments on PRs missing a valid
  `KR:` line and applies a `needs-kr` label. Warn-by-default; strict mode is a deliberate
  second decision, and even then a human-applied `okr-override` label passes the gate. The gate
  is an explicit question during install, never a default — a nudge you didn't ask for reads as
  surveillance, and surveillance gets uninstalled.
- **PR template** — the `KR:` line, a plain-language "what changed", click-test steps, and a
  risk checklist that pulls in a domain reviewer for behavior-shaped risks (data deletion looks
  like any other diff; a checkbox catches what a path pattern can't).
- **CODEOWNERS** — domain review for path-shaped risks: migrations, auth config, payments.
- **Branch protection** — applied via `../templates/stack/branch-protection.sh` or by hand:
  required checks, code-owner review, squash-only. Protecting main is advised at every level,
  not just here (see [Protected main and okrdev](#protected-main-and-okrdev)); Level 2 is
  just where the install applies it for you. Without it, CODEOWNERS is a suggestion; see
  [plan requirements](#github-plan-requirements-stated-honestly) below.

**Why the rails matter:** they're how "domain experts review where stakes are high" becomes
enforcement instead of a hope, and how the coach's drift check gets machine-readable ground
truth. [roles.md](roles.md) covers who reviews what and why.

**A note on state writes:** okrdev's own files move fast — a parked idea can't wait on CI.
The capture path doesn't have to: `/okrdev:park` files captures as `okrdev:parked` issues
(zero commits, zero CI), and the batched ledger writes that remain land as small, immediately
merged state PRs where the branch is protected. Full mechanics — including the opt-in actor
bypass the branch-protection script still ships — in
[Protected main and okrdev](#protected-main-and-okrdev).

### The stack module

Greenfield projects only, or deliberate migrations. It's the one rung that isn't really a rung —
you don't graduate into it; you either start there or consciously move there. An existing
product on Rails and Heroku adopting okrdev should change exactly nothing about Rails and
Heroku.

What it is, why each piece, and the exit path for every choice: [stack.md](stack.md). The
step-by-step setup: `../templates/stack/README.md`.

**If your product is an agent following a contract document** — a support agent with a
policy file, a coach with a rules block, anything whose riskiest surface is a model reading
instructions — the testing shape that fits is the one okrdev uses on itself: scripted user
turns, deterministic file-and-state asserts first, a cheap LLM judge second, and a scenario
corpus that grows only from real misbehavior, never from speculative coverage. The pattern,
the scenario format, and okrdev's own harness as the worked example are in
[testing.md](testing.md). This is advice with a pointer, not part of any install — nothing
here lands in your repo.

## Non-code businesses

The method runs fine in a repo that contains nothing but the `okrdev/` directory. The repo is
just the ledger: versioned, greppable, agent-readable, free.

A consultancy, an agency, a fitness studio, a newsletter — none of them ship PRs, and okrdev
doesn't pretend they do. The check-in's "What moved" section is the canonical ledger for
non-code KR work (sales calls, campaigns shipped, contracts signed); the drift check, which
reads commits and PRs, simply has less to read and leans on the conversation instead. Level 2
is irrelevant to you, and the install will never offer it. Create an empty GitHub repo, open it
in a Claude Code or Codex session (see [Supported surfaces](#supported-surfaces)), run
`/okrdev:install`, and you're operating.

Why a git repo at all, for a business with no code? Because the alternative is a SaaS tool: an
account, a subscription, an export problem. Markdown in a repo you own is the least lock-in a
system of record can have — that's a load-bearing promise (see
[MANIFESTO.md](../MANIFESTO.md), "What we refuse").

## Solo-founder mode

okrdev works for one person; several parts of it collapse gracefully, and one part matters
more, not less.

**What collapses:**

- **The check-in becomes a conversation with the coach.** The solo script in
  [rituals.md](rituals.md): the coach pre-drafts everything, plays the other party, asks for
  your win first, and challenges your confidence numbers. Still 15 minutes. Skipping it because
  "I already know where I am" is the first symptom of not knowing where you are.
- **DRI assignment is trivial** — it's you, on every objective and every KR. The 1–3 objective
  cap tightens in practice: solo founders who plan three objectives usually score one. Plan one
  or two.
- **Domain review mostly disappears.** There's no reviewer to pull in, so the
  review-without-reading-code routine in [roles.md](roles.md) becomes your own habit: read the
  coach's plain-language summary, click the preview, test the flow before merging.
- **Level 2 is mostly not for you.** CODEOWNERS pointing at yourself is theater; a rule
  requiring your own approval just adds clicks. Protect main anyway — PR required, zero
  approvals, squash-only, no force pushes (see
  [Protected main and okrdev](#protected-main-and-okrdev)) — it costs nothing day-to-day and
  it's the advice at every level. The rest of the useful slice: `KR:` trailers in commit
  messages (the drift check reads them in direct-to-main repos) and CI checks if you have
  tests. Stay at Level 1 and take just those.
- **The backstop still gets named.** `okrdev/config.md` wants one human to call when you and
  the coach are both stuck. Solo doesn't exempt you — it's exactly when you need a name written
  down. A technical friend, a former colleague, an advisor. Ask them first.

**What matters more:** every anti-gaming rule in [method.md](method.md) — sandbagging
detection, the confidence-evidence trigger, the emergency audit. With a team, social pressure
does some of that work. Solo, the coach is the only counterparty you have, and the only thing
standing between you and a quarter of comfortable self-deception. Don't soften it.

## Multi-team

v0 is single-team per repo, on purpose — cascading OKR machinery is a swamp and we refuse to
wade in ([MANIFESTO.md](../MANIFESTO.md), "cascade theater"). If you're tempted to improvise,
here is the honest guidance: the format has a seam for it — per-team check-in suffixes
(`2026-W29-growth.md`) and per-team cycle files are permitted and won't break the skills — but
this is undocumented territory and the coach has no multi-team logic. In practice, two or more
teams usually means two or more repos, each running its own okrdev with its own mission,
cycles, and check-ins. Shared context belongs in conversation, not in alignment machinery.

## Protected main and okrdev

Protect your default branch. That's the advice at every level, not just Level 2: require a PR
before merge, squash-only, no force pushes — and add required approvals and required checks
according to your team size and what your CI actually reports. (Solo? Zero required approvals
is fine; the PR requirement alone stops force-pushes and gives every change a reviewable
moment.) On private repos this needs a paid plan — see
[plan requirements](#github-plan-requirements-stated-honestly) below.

Earlier versions of okrdev treated protection as an obstacle to route around, because a
10-second capture can't wait on CI. v0.2.0 removed the conflict by changing the shape of the
writes instead:

- **Captures are issues, not commits.** Where the remote is GitHub and `gh` is authed,
  `/okrdev:park` files an `okrdev:parked` issue — zero commits, zero CI, one API call. Level 0
  on a protected repo is first-class: capture costs nothing, from any device, by any
  collaborator.
- **Ledger writes are batched by ritual.** Triage results, check-in files, side-quest logs —
  one write per triage or check-in, not one per item.
- **Unprotected default branch:** the batched write commits directly, via a temporary
  worktree — your working branch is never switched.
- **Protected default branch:** the batched write becomes a small state PR — branch
  `okrdev/state-<date>-<slug>`, PR titled `okrdev: <what>` with a `KR:` line, merged
  immediately with `gh pr merge --squash` (or auto-merge, where required checks must run
  first). Batching makes this about one PR a week, not one per capture. Mid-week unbatchable
  writes — an override log line, an on-the-spot side-quest — take the same path, and are rare
  enough not to matter.
- **The bypass is optional convenience now, not the default.**
  `../templates/stack/branch-protection.sh` still ships an actor-scoped bypass (admins may
  push directly; the `okrdev/**`-only discipline is the coach's contract, not GitHub's —
  GitHub can't scope a bypass to paths), but it's an opt-in flag; state PRs are the standard
  path on protected repos.

One honest number: without `gh` or a GitHub remote, capture falls back to the file append —
and on a protected repo that fallback degrades from ten seconds to about thirty, because it
rides a state PR. The issue path is what keeps the ten-second promise; the fallback keeps the
method working everywhere else.

### Strict CI and the weekly state PR

If your required checks run a full build-and-test suite, a weekly PR touching only `okrdev/**`
markdown burns a CI run for nothing. The fix is a short-circuit *inside* the required job: its
first step computes the diff, and if the changes touch only `okrdev/**`, the job exits
successfully. `../templates/github/workflows/ci.yml` implements the pattern (the
`okrdev-only` early-exit step).

**Never use workflow-level `paths-ignore` on a required check.** A workflow skipped by
`paths-ignore` never reports its check; GitHub waits on "Expected" forever, and the PR is
unmergeable. The short-circuit must live inside the job, so the check always reports.

## GitHub plan requirements, stated honestly

Level 2's enforcement pieces depend on GitHub features that aren't free everywhere:

- **Branch protection and rulesets** are free on **public** repos. On **private** repos they
  require a paid plan (GitHub Pro for personal accounts, Team or Enterprise for
  organizations).
- **CODEOWNERS enforcement** ("require review from Code Owners") is a branch-protection
  setting, so it has the same requirement. Without it, a CODEOWNERS file still triggers
  automatic review *requests* — it just can't make them blocking.
- **The okr-gate, the PR template, and `KR:` lines** work on every plan, including free private
  repos. They're metadata and workflow files, not protection features.

So on a free private repo, Level 2 degrades from *rails* to *norms*: the gate still comments,
the template still asks, the coach still nudges — but nothing physically stops an unreviewed
merge to main. That's materially weaker, and you should know it before relying on it. Your
options: make the repo public, pay for the plan, or accept advisory-only rails with eyes open.
`../templates/stack/branch-protection.sh` checks for this and exits with a clear message rather
than half-applying protection, because a rail you believe exists but doesn't is worse than no
rail.

## Headless install

The `/plugin` dialog is interactive — fine at a keyboard, a wall for a script, a CI job, or an
agent bootstrapping a machine, and unavailable altogether in the desktop app, which answers
`/plugin isn't available in this environment`.

**This section's premise has partly expired, and that is good news.** It was written when
`claude plugin install okrdev@okrdev` was a real shell command but marketplace registration had
no shell equivalent — it existed only inside the dialog. As of `claude 2.1.226`,
`claude plugin marketplace add <source>` ships, so both halves are scriptable and the Quickstart
leads with them. `install.sh` still earns its place: it is one command instead of two, it is
idempotent, it re-points a local checkout at the canonical repo, and — because it has always
probed for the shell subcommand and preferred it — it needed no change when that subcommand
arrived. What it no longer is, is the *only* headless route.

```bash
dir=$(mktemp -d)
git clone https://github.com/backedbydata-co/okrdev.git "$dir/okrdev"
"$dir/okrdev/install.sh"
rm -rf "$dir"   # optional; see "the checkout is disposable" below
```

**Run it outside the repo you're adopting into.** The script never writes to the repo it runs
from — but `git clone` does, and it lands at `okrdev/`, which is precisely the path the method
reserves for your ledger. Clone it at the target repo's root and `/okrdev:install` will later
find an `okrdev/` directory that is a copy of this project rather than your OKRs, read the repo
as a half-finished install, and start filling gaps around it.

**Why `mktemp -d` and not `~`.** An earlier version of this block cloned to `~/okrdev` and
cleaned up with `rm -rf ~/okrdev`. For most readers that is the same thing. For a reader who
already keeps a repo at `~/okrdev` — not far-fetched, given what this project is called — the
clone fails on a non-empty destination and the cleanup line then deletes their work. Copy-paste
instructions should not name a fixed path in `$HOME` and then `rm -rf` it. `mktemp -d` gives a
directory that is guaranteed new, so the cleanup can only remove what the clone created.

**The checkout is disposable.** Once the script finishes, the marketplace has its own copy
under `~/.claude/plugins/marketplaces/okrdev/` and the clone you ran from has no further job.
Deleting it changes nothing; keeping it costs a stale copy that will quietly fall behind.

What it does, in order:

1. **Prefers the official path the day it exists.** If a future CLI ships a
   `claude plugin marketplace add` shell command, the script uses it and touches no state files
   itself.
2. **Registers the marketplace by writing what the dialog writes:** a clone of this repo under
   `~/.claude/plugins/marketplaces/okrdev/` — taken from the checkout you're running it from,
   so there's no second fetch and no second auth — plus one entry in
   `~/.claude/plugins/known_marketplaces.json`. The file is backed up first; an existing
   `okrdev` entry is left alone, so re-running is safe.
3. **Hands off to the documented command:** `claude plugin install okrdev@okrdev`.

Everything it writes is machine-level, under `~/.claude` (or `$CLAUDE_CONFIG_DIR` when set). It
never touches the repo you run it from — the install-footprint red line governs what
`/okrdev:install` later writes into *your* repo, and this script runs upstream of all that.

Honesty about the seam: step 2 writes files the `/plugin` dialog owns and Claude Code has never
documented. The script is defensive about it — validates before writing, backs up, adds one key
rather than rewriting — but a Claude Code release could change that state's shape underneath
it. If that happens the script fails with instructions rather than guessing; the interactive
path in the Quickstart always works.

**By hand, no script.** The same three moves, if you'd rather own them — or if you're on a
machine with neither `jq` nor `node`, which the script needs for the JSON edit:

```bash
# 1. Put a clone where Claude Code keeps marketplaces:
git clone https://github.com/backedbydata-co/okrdev.git \
  ~/.claude/plugins/marketplaces/okrdev

# 2. Add this entry to ~/.claude/plugins/known_marketplaces.json (create the
#    file as {} first if it doesn't exist), keyed "okrdev", alongside any
#    entries already there:
#      "okrdev": {
#        "source": { "source": "github", "repo": "backedbydata-co/okrdev" },
#        "installLocation": "<home>/.claude/plugins/marketplaces/okrdev",
#        "lastUpdated": "<now, ISO-8601>"
#      }

# 3. Install through the documented CLI:
claude plugin install okrdev@okrdev
```

Either way: new sessions load the plugin, running sessions need `/reload-plugins`, and
`/okrdev:install` in the target repo takes it from there.

## Install collisions

First thing every brownfield adoption hits: the files okrdev wants to touch already exist.
`/okrdev:install` handles each case the same way — never overwrite, always show, always ask:

- **Existing instructions file:** the coach block is appended between `<!-- okrdev:start -->` and
  `<!-- okrdev:end -->` markers. Your content is untouched; the markers make the block
  findable, upgradeable, and removable forever after. If the markers are already present,
  that's an upgrade — the block is replaced in place, between the markers only.
- **Existing PR template, CODEOWNERS, or workflows:** never overwritten. The install shows you
  a proposed merge — your content plus okrdev's additions — and asks. You approve the diff or
  edit it; nothing lands silently. These files often encode hard-won team decisions, and a
  framework that stomps them has announced its priorities.
- **Existing `okrdev/` directory:** treated as an upgrade, not a fresh install. See below.

## Upgrading

`okrdev/config.md` frontmatter carries `okrdev_version`. That marker is what makes upgrades a
procedure instead of an archaeology project.

When a new version of the plugin lands, run `/okrdev:install` in the repo. It reads the
installed version, diffs the templates you installed then against the templates shipped now,
and proposes the changes file by file. Files you've customized get a shown diff and a question,
never a silent overwrite — your `MISSION.md`, your cycle files, and your check-in history are
yours and are never touched by an upgrade at all. Only the scaffolding (coach block, workflow
files, templates) is upgrade material. When you accept, the version marker is bumped.

**What the marker tracks — the versioning policy.** `okrdev_version` records **the plugin
version whose scaffolding this repo currently holds**, not the newest plugin ever released and
not the date of the last edit. Two rules keep that true, and they are the release checklist:

- **A change to anything okrdev puts in your repo bumps `.claude-plugin/plugin.json` and
  `templates/okrdev/config.md`'s `okrdev_version` together, in the same PR** — and, in this
  repo, `okrdev/config.md`'s marker with them, because okrdev runs on itself and a release is
  not done until it has upgraded itself. That third file is not optional and never was:
  `check_dogfood_current` has always failed the build when it disagrees. This checklist named
  two files while CI enforced three, which is the kind of gap that only shows up on release
  day. That means all
  of `skills/` and `templates/` — not only the files `/okrdev:install` copies, but the ones
  the stack module has you copy by hand, because an upgrade diffs every okrdev-provided file
  in your repo and cannot offer you a change it was never told about. Bumping one marker
  without the other ships a version number that lies in one of two directions: a fresh
  install recording a version it doesn't match, or an upgrade that finds nothing to offer.

  The distinction is worth stating because it has already caused one wrong answer. An earlier
  draft of this rule justified itself as "the only changes that alter what an install writes",
  which reads as excluding the stack module's hand-copied `ci.yml` — so a Node version bump in
  it would have shipped with no marker change, and every stack adopter running the upgrade
  would have been told there was nothing to do. The test is not *who copied the file*. It is
  *whether a file okrdev provided is now different*.
- **Every shipped change bumps.** Not only `skills/` and `templates/` — docs too, and the
  acquisition path, and anything else that reaches an adopter. One rule, no exemption list.

  This replaced a narrower rule on 2026-08-08, and the original is worth keeping because its
  reasoning was correct for the world it was written in. It said a docs-only change bumps
  nothing, because `docs/` is read from the plugin and never copied into an adopter's repo, so
  there is no installed copy that could fall behind — and *"bumping for prose would spend every
  adopter's upgrade prompt on a diff with no files in it, and a prompt that's usually empty is a
  prompt people stop reading."* An exemption for `install.sh` followed from the same argument.

  What changed is that the version acquired a second consumer. Once okrdev is listed in a plugin
  directory, `plugin.json`'s `version` is the **distribution cache key** — the installed copy
  lives at a versioned path (`~/.codex/plugins/cache/okrdev/okrdev/<version>`), and the version
  is the only signal that there is anything new to fetch. Measured, not assumed: a docs-only
  change at an unchanged version is still *retrievable* by an explicit re-install, but nothing
  tells anyone to run one. And **seven of the eight skills read `docs/` at runtime**, so a docs
  fix is a behaviour fix. A marker that stays put through those is not being conservative; it is
  withholding a signal.

  The empty-prompt problem the old rule was avoiding is real, and it is solved where it belongs —
  in the upgrade path, which now says a release changed no scaffolding and there is nothing to
  apply, rather than presenting an empty diff. Telling an adopter "0.7.0 is out, nothing to do
  here" is strictly better than never telling them at all.

  One consequence, stated so nobody reads it as drift: `okrdev_version` in an adopter's repo can
  now sit several releases behind the newest plugin while being perfectly correct, because it
  records the last version whose scaffolding they actually applied. That was always true. It is
  just more visible when every release bumps.

Worth stating rather than leaving to be rediscovered: a repo installed at 0.1.0 and never
upgraded correctly still reads `0.1.0`. That is the marker working, not drift, and it is what
makes the upgrade diff computable. Nothing here nags you to upgrade.

**okrdev's own repo is the one exception, and it is held tighter, not looser.** A release is
not done until okrdev has upgraded itself — the marker in this repo's `okrdev/config.md`
tracks the version it ships, and `tests/check.sh` fails if it doesn't. The reason is the
claim at the top of that file: okrdev runs on itself, "the first and most honest test of
whether the method survives contact with real work." A framework three releases behind its
own scaffolding is not testing the upgrade path it sells; it is only testing the install it
happened to get. This is not a special rule for the maintainer's convenience — it is the
stricter one, and it exists because the drift it catches is invisible from the inside. It sat
unnoticed for three releases before a check went looking.

The example under `examples/acme-fitness/` is deliberately left on an older marker. A worked
example of an adopter who hasn't upgraded is worth more than one that is magically current.

## Uninstalling

"Removable" is a procedure, not an adjective. The full teardown:

1. **Delete the `okrdev/` directory.** That's the method gone. Your OKR history survives in git
   history if you ever want it back — one argument for having committed it all along.
2. **Remove the marked block from your instructions file** — everything from
   `<!-- okrdev:start -->` through `<!-- okrdev:end -->`, inclusive. Check both `CLAUDE.md` and
   `AGENTS.md`: whichever agent you are uninstalling from, the install may have been done from
   the other one. The rest of the file is untouched.
3. **Delete the `okrdev:parked` label and close any stragglers** — if you used the issue
   capture path: `gh label delete okrdev:parked`, and triage or close whatever parked issues
   are still open, so the inbox doesn't outlive the method.
4. **Optionally remove the Level 2 files**, if you installed them:
   `.github/workflows/okr-gate.yml`, the `KR:` section of your PR template, the okrdev entries
   in CODEOWNERS, and the branch-protection rules (via repo settings or `gh api`). These are
   listed rather than auto-deleted because by uninstall time they may be entangled with rules
   you added for your own reasons.
5. **The stack module is not okrdev's to remove.** If you adopted it, Vercel, Neon, and your CI
   are now your application's infrastructure. Uninstalling the method doesn't touch them —
   [stack.md](stack.md) documents the exit path for each piece if you're leaving those too.

After steps 1 through 3, okrdev never existed. No accounts to close, no data to export, no SaaS to
cancel. That was the point.
