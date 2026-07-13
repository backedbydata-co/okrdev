# The stack module

One good path from idea to production, built so anyone on the team — technical or not, human or
AI — can ship safely. Next.js on Vercel. Neon Postgres with a database branch per preview. Drizzle
migrations. Neon Auth. Vitest and Playwright. GitHub Actions. A protected `main` where merging a
PR *is* the deploy.

**You do not need any of this to run okrdev.** The method — parking lot, cycles, check-ins,
retros, the coach — installs on any stack, or on no stack at all. Existing codebase? Keep it;
[adoption.md](adoption.md) covers brownfield installs. The stack module is for greenfield
projects, or for teams making a deliberate migration with eyes open. `/okrdev:install` offers it
only in those two cases, and never as a prerequisite for anything above it on the ladder.

## The loop it buys you

Every change follows the same path, and no change follows any other path:

1. A builder (a human working with AI) opens a pull request.
2. Vercel deploys a **preview** — a private copy of the app at its own URL — and Neon forks a
   **database branch** for it from a parent seeded with synthetic data. Never from production.
3. CI lints, typechecks, and runs unit tests. The PR's committed migrations are applied to the
   preview's database branch, then Playwright smoke tests run against the preview URL with a
   seeded test user.
4. A human clicks the preview link and checks that the change does what it claims. No code
   reading required — [shipping-explained.md](shipping-explained.md) teaches the vocabulary.
5. Review lands. Where the paths are risky (migrations, auth, payments), CODEOWNERS pulls in the
   domain expert automatically. Squash merge.
6. Merge deploys production. A gated Actions job applies the same migration files to the
   production database. The preview and its database branch are deleted.

There is no deploy button, no staging environment to babysit, no "works on my machine." The PR is
the unit of change, the preview is the proof, and `main` is the truth.

## Why one opinionated path

The stack is chosen to be **AI-legible** — the property that matters most when agents do most of
the building:

- **The whole system is text in the repo.** Schema, migrations, tests, CI, deployment behavior —
  all files an agent can read, grep, and modify through the same PR flow as everything else.
  Nothing important lives only in a dashboard.
- **No mid-flight decisions.** One database, one ORM, one test runner, one way to deploy. An
  agent (or a new teammate) never has to ask "which of our three ways do we do this here?"
- **Boring, popular tools on purpose.** Next.js, Postgres, Playwright — these have years of
  documentation and deep training-data coverage. Agents hallucinate less on roads well traveled.
- **Ground truth at every layer.** A preview URL to click, a CI verdict to read, a database
  branch to query. The agent and the non-technical DRI verify with the same tools, which is what
  makes "anyone can own anything" ([roles.md](roles.md)) more than a slogan.
- **Safety is structural.** Untested code can't merge, unreviewed risky paths can't merge,
  production can't be force-pushed. Nobody has to watch. Rails, not vigilance.

## The choices

Each choice states what it is, why it won, and how you would leave. A stack you can't leave is a
stack you can't trust — every exit path below is documented on purpose.

### Hosting: Vercel

**What.** Next.js (App Router, TypeScript) deployed on Vercel. Every PR gets a preview
deployment at its own URL; every merge to `main` deploys production.

**Why.** Previews are the heart of the stack: they give non-technical DRIs a real, clickable
copy of the app for every proposed change, with zero setup. Vercel makes that the default
behavior rather than an infrastructure project.

**Exit.** The app is standard Next.js — `next build` runs on any Node host or in a container.
What you'd rebuild elsewhere is the per-PR preview pipeline, and that's the piece you'll miss
most. Avoid Vercel-only primitives where a portable option exists and the exit stays cheap.

### Database: Neon Postgres, one branch per preview

**What.** Neon Postgres, wired to Vercel through the Neon integration. Each preview deployment
gets its own copy-on-write database branch, forked from a **seeded parent branch containing
synthetic data — never production**. Branches are deleted when the PR closes; a scheduled
workflow ([../templates/github/workflows/neon-cleanup.yml](../templates/github/workflows/neon-cleanup.yml))
sweeps up orphans.

**Why.** A preview with a shared database is a lie — click-testing against data another PR just
mutated proves nothing. Branch-per-preview makes every preview a genuinely isolated app-plus-data
environment. And the seeded-parent rule is a hard privacy line: preview links get pasted into
chat, opened on phones, and shared with people who have no production access. A preview forked
from production is a data leak with a URL. PII never enters a preview, so a leaked preview link
leaks nothing.

Two operational notes, because they bite at the worst time: verify delete-on-close in the
integration settings (don't assume it), and know your branch limit — Neon's free tier allows
around ten branches per project, which is one busy week of PRs. Details sit next to the setup
steps in [../templates/stack/README.md](../templates/stack/README.md).

**Exit.** It's Postgres. `pg_dump`, restore anywhere, done. What you lose is instant
copy-on-write branching — which is the reason to be here in the first place.

### Schema and migrations: Drizzle

**What.** Drizzle ORM with the schema defined in TypeScript and migrations generated as plain
SQL files, committed to the repo.

**Why.** The schema-as-TypeScript is agent-readable and agent-writable. The generated SQL is
human-reviewable: a schema change shows up in the PR diff as the exact DDL that will run, which
is what lets CODEOWNERS put a domain expert in front of every migration.

The runbook, in one table:

| When | Command | Against |
|------|---------|---------|
| Local experimentation | `drizzle-kit push` | your own dev branch only |
| Every schema change | `drizzle-kit generate`, commit the SQL | the repo, in the PR |
| CI, per PR | `drizzle-kit migrate` | the PR's preview database branch, before Playwright |
| Production | `drizzle-kit migrate` in a gated Actions job | production, on merge |

`push` never touches a shared branch — it mutates the database directly with no committed
artifact, which means no review, no replay, no audit trail. Everything shared goes through
generated, committed SQL.

Breaking changes use **expand/contract**, because deploy = merge means old code and new schema
briefly coexist: (1) expand — add the new column or table alongside the old, backward-compatible;
(2) dual-write and backfill; (3) switch reads to the new shape; (4) contract — drop the old in a
later PR once nothing reads it. Each step is its own PR, so every commit on `main` runs against
the schema it finds.

**Exit.** The migrations are plain SQL files — any tool, including `psql`, can replay them. The
only Drizzle-specific artifact is the TypeScript schema in your app code.

### Auth: Neon Auth

**What.** Neon's managed auth, with one property that made the decision: user records sync into
a `neon_auth` schema **in your own Postgres database**. Your users are rows you can join
against, back up, and export.

**Why.** Auth vendors that keep your users in *their* database hold your business hostage at
exit. Here, `pg_dump` gets your user table any day of the week. Managed auth also removes the
single riskiest thing a generic builder could hand-roll — password handling.

**Exit.** User records: already yours, export at will. Password hashes live with the provider,
so leaving means exporting hashes where supported or running a password-reset campaign — plan
for the second and be pleasantly surprised by the first. If a hosted auth dependency is
unacceptable from day one, the sanctioned fallback is Auth.js, self-hosted against the same
Postgres. Nothing else in the stack changes.

### Tests: Vitest and Playwright

**What.** Vitest for unit tests, run in CI on every PR. Playwright for smoke tests, run **against
the real preview deployment** — same build, same database branch, same auth as what would ship —
signed in as a seeded test user, passing the `x-vercel-protection-bypass` header so deployment
protection stays on for everyone else.

**Why.** Unit tests catch logic mistakes cheaply. Smoke tests against the preview catch the
mistakes that matter — the thing you verify is the thing you ship, not a localhost approximation
with mocked data. Keep the smoke suite small and meaningful: it runs on every PR against real
infrastructure, so every test has to earn its seconds.

**Exit.** Both are standard open-source tools. There is nothing to exit from.

### Delivery: GitHub Actions, protected main, squash merges, deploy = merge

**What.** CI on GitHub Actions ([../templates/github/workflows/ci.yml](../templates/github/workflows/ci.yml)).
`main` is protected: required CI check, required review with Code Owners, no force pushes,
squash merges only. Merging is the only way anything reaches production.

**Why each piece:**

- **Actions**: CI lives where the code lives, and workflows are files in the repo — AI-legible,
  reviewable, versioned like everything else.
- **Protected main**: the gates are only real if they can't be walked around. Without branch
  protection, CODEOWNERS is a suggestion and required checks are decoration.
- **Squash-only**: one PR becomes exactly one commit on `main`. The PR's `KR:` line rides in the
  squash commit message, so the coach's drift check ([ai-coach.md](ai-coach.md)) can read
  alignment straight out of git history — and reverting a bad change is one clean commit.
- **Deploy = merge**: a separate deploy button is a second path to production, and second paths
  accumulate snowflake state. When merge is the only deploy, git history *is* deployment
  history.

One deliberate exception: okrdev state writes — parking lot captures, check-in files — go
directly to `main`, because a ten-second capture can't wait on CI. The setup script
([../templates/stack/branch-protection.sh](../templates/stack/branch-protection.sh)) configures
the protection plus that bypass, and is honest about its mechanics: GitHub can't scope a bypass
to file paths, so it's actor-scoped and the coach's contract confines it to `okrdev/**`. Teams
that refuse direct pushes entirely get the fallback — auto-merged state PRs.

The Level 2 rails — PR template, okr-gate, CODEOWNERS — are part of the method, not the stack,
and remain opt-in ([adoption.md](adoption.md)). The stack simply arrives with everything they
need already in place. Note the plan requirements: branch rulesets are free on public repos;
private repos need GitHub Pro (personal) or Team (organization).

## Previews are for humans

The preview link is the one verification tool a non-technical DRI has. If it hits a login wall,
the DRI either rubber-stamps changes or stops merging — both defeat the stack. So preview
accessibility is a **required, verified install step**, not a nice-to-have: deployment
protection stays on, shareable links (or team access) let DRIs open previews without a Vercel
account, and the setup isn't done until someone has opened a preview from a phone or a private
browser window and seen the app, not a login page. The step-by-step is in
[../templates/stack/README.md](../templates/stack/README.md); the review routine a DRI runs
against a preview is in [roles.md](roles.md) and [dri-onboarding.md](dri-onboarding.md).

## Setting it up

Budget a day. The full walkthrough — create-next-app through a verified end-to-end shipping loop
— is [../templates/stack/README.md](../templates/stack/README.md). It installs:

- the app, Vercel project, and Neon integration with branch-per-preview and the seeded parent
- Drizzle and the migration runbook wiring
- Neon Auth and the seeded test user
- Vitest, Playwright-against-previews, and the workflows
  ([ci.yml](../templates/github/workflows/ci.yml),
  [okr-gate.yml](../templates/github/workflows/okr-gate.yml),
  [neon-cleanup.yml](../templates/github/workflows/neon-cleanup.yml))
- branch protection via [branch-protection.sh](../templates/stack/branch-protection.sh)

Greenfield installs reach it through `/okrdev:install`, which offers the stack module last —
after the method is in place, because the method is the product and the stack is a module.
