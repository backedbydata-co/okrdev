# Adoption

How okrdev gets into your repo, what each level costs, and how it comes back out. The short
version: start at the bottom of the ladder, move up only when the current level has earned it,
and keep whatever stack you already have.

## Brownfield first

okrdev assumes you have an existing business with an existing codebase, existing habits, and no
appetite for a migration. That's the common case, not the exception.

So the method is fully decoupled from the stack. Nothing in Levels 0–2 cares whether you deploy
to Vercel or a VPS, whether you use Postgres or a spreadsheet, whether you even write code. The
install adds one directory (`okrdev/`), one marked block in `CLAUDE.md`, and — only if you opt
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
coach block in `CLAUDE.md` (between `<!-- okrdev:start -->` / `<!-- okrdev:end -->` markers) —
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

**What installs:** `okrdev/MISSION.md`, `okrdev/okrs/<cycle>.md`, `okrdev/checkins/`,
`okrdev/LESSONS.md`, and the full coach block. This is okrdev proper.

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

## Non-code businesses

The method runs fine in a repo that contains nothing but the `okrdev/` directory. The repo is
just the ledger: versioned, greppable, agent-readable, free.

A consultancy, an agency, a fitness studio, a newsletter — none of them ship PRs, and okrdev
doesn't pretend they do. The check-in's "What moved" section is the canonical ledger for
non-code KR work (sales calls, campaigns shipped, contracts signed); the drift check, which
reads commits and PRs, simply has less to read and leans on the conversation instead. Level 2
is irrelevant to you, and the install will never offer it. Create an empty GitHub repo, connect
it to whatever Claude surface you use (see [dri-onboarding.md](dri-onboarding.md) for the
options), run `/okrdev:install`, and you're operating.

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

## Install collisions

First thing every brownfield adoption hits: the files okrdev wants to touch already exist.
`/okrdev:install` handles each case the same way — never overwrite, always show, always ask:

- **Existing `CLAUDE.md`:** the coach block is appended between `<!-- okrdev:start -->` and
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

## Uninstalling

"Removable" is a procedure, not an adjective. The full teardown:

1. **Delete the `okrdev/` directory.** That's the method gone. Your OKR history survives in git
   history if you ever want it back — one argument for having committed it all along.
2. **Remove the marked block from `CLAUDE.md`** — everything from `<!-- okrdev:start -->`
   through `<!-- okrdev:end -->`, inclusive. The rest of your `CLAUDE.md` is untouched.
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
