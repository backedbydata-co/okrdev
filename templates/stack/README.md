# Stack module — greenfield setup

This is the step-by-step for standing up the okrdev stack on a brand-new project: Next.js on
Vercel, Neon Postgres with a database branch per preview, Drizzle migrations, Neon Auth, Vitest,
Playwright against previews, GitHub Actions, and a protected `main` where merge = deploy.

The stack is optional. The reasoning behind every choice — and the exit path from each — lives in
[../../docs/stack.md](../../docs/stack.md). Greenfield installs normally reach this file through
`/okrdev:install`; a capable agent can execute these steps with you, narrating as it goes.

Budget a day. The order below matters: Drizzle before the seeded parent branch (you can't seed a
schema that doesn't exist), preview accessibility before Playwright (the tests need the bypass
secret), branch protection last (so setup itself isn't fighting the gates).

## 0. Prerequisites

- A GitHub account (organization or personal) and the `gh` CLI, authenticated (`gh auth login`).
- A Vercel account. A Neon account gets created through the Vercel integration if you don't have
  one.
- Node 22+ and pnpm.

Everything here has a free tier. Two limits worth knowing before they bite:

- **Neon branches**: the free tier allows roughly **10 branches per project** (as of writing —
  check Neon's limits page). One branch per open PR plus the parent and production means a busy
  week can hit the cap, and the failure mode is a confusing preview error for exactly the person
  least equipped to debug it. Step 3's lifecycle settings and the cleanup workflow exist for
  this reason. Paid tiers raise the limit into the hundreds.
- **GitHub branch rulesets**: free on public repos; private repos need GitHub Pro (personal) or
  Team (organization). Step 11 will tell you clearly if you hit that wall.

## 1. Create the app

```bash
pnpm create next-app@latest my-app --typescript --app --eslint --tailwind --src-dir --import-alias "@/*"
cd my-app
git init && git add -A && git commit -m "chore: scaffold next app"
gh repo create your-org/my-app --private --source . --push
```

App Router and TypeScript are the stack's defaults — one path, no variants.

## 2. Vercel project

Import the repo at vercel.com/new and deploy. From this moment:

- every PR gets a **preview deployment** at its own URL, and
- every merge to `main` deploys **production**.

There is no deploy button in this stack. Merge is the deploy — a second path to production would
accumulate state the repo doesn't know about.

## 3. Neon integration, branch-per-preview, lifecycle

Install the **Neon Postgres** integration from the Vercel Marketplace onto the project. It
creates the Neon project and sets `DATABASE_URL` per environment. Then, in the integration
settings:

1. **Enable database branching for previews** — each preview deployment gets its own
   copy-on-write Postgres branch.
2. **Verify branch deletion on PR close is ON.** Open the setting and look at it; don't assume.
   Orphaned branches silently eat the branch quota, and the eventual failure ("preview won't
   deploy") lands mid-cycle on a non-technical DRI.
3. Note the **parent branch** setting — you'll point it at a seeded parent in step 5.

Also install the scheduled cleanup workflow now (it catches strays the integration misses —
closed-without-merge PRs, renamed branches):

```bash
mkdir -p .github/workflows
cp <okrdev-repo>/templates/github/workflows/neon-cleanup.yml .github/workflows/
```

It needs `NEON_API_KEY` (step 10's secrets table).

## 4. Drizzle

```bash
pnpm add drizzle-orm @neondatabase/serverless
pnpm add -D drizzle-kit tsx
```

`drizzle.config.ts` at the repo root:

```ts
import { defineConfig } from "drizzle-kit";

export default defineConfig({
  schema: "./src/db/schema.ts",
  out: "./drizzle/migrations",
  dialect: "postgresql",
  dbCredentials: { url: process.env.DATABASE_URL! },
});
```

Define your first table in `src/db/schema.ts`, then generate and commit the first migration:

```bash
pnpm drizzle-kit generate
git add drizzle/ && git commit -m "chore: initial schema migration"
```

**The migration runbook.** Print this on the inside of your eyelids:

| When | Command | Against |
|------|---------|---------|
| Local experimentation | `drizzle-kit push` | your own dev branch only |
| Every schema change | `drizzle-kit generate`, commit the SQL | the repo, in the PR |
| CI, per PR | `drizzle-kit migrate` | the PR's preview branch, before Playwright (step 9) |
| Production | `drizzle-kit migrate` in a gated Actions job | production, on merge (step 10) |

`push` mutates a database directly with no committed artifact — no review, no replay, no audit
trail — so it never touches a shared branch. Breaking changes use **expand/contract** across
separate PRs: expand (add the new shape alongside the old), dual-write and backfill, switch
reads, contract (drop the old once nothing reads it). Why: merge deploys immediately, so every
commit on `main` must run against whatever schema it finds.

## 5. Seed script and the seeded parent branch

**The policy: preview branches fork from a parent seeded with synthetic data. Never from
production.** Preview links get pasted into chat and opened on phones by people with no
production access. A preview forked from production is a data leak with a URL.

Write `scripts/seed.ts`:

```ts
// scripts/seed.ts — synthetic data ONLY. Generate it; never copy production rows here.
import { neon } from "@neondatabase/serverless";
import { drizzle } from "drizzle-orm/neon-http";
import * as schema from "../src/db/schema";

const db = drizzle(neon(process.env.DATABASE_URL!), { schema });

async function main() {
  // Insert enough synthetic rows that previews feel real: a handful of records
  // per table, edge cases included (empty names, long strings, past dates).
  // @faker-js/faker is worth the dev dependency once you need volume.
  //
  // Include rows owned by the Playwright test user (created in step 6) so
  // smoke tests land on a populated screen, not an empty state.
}

main().then(() => process.exit(0));
```

Create the parent branch, migrate it, seed it:

```bash
npx neonctl branches create --project-id <NEON_PROJECT_ID> --name preview-parent
export DATABASE_URL="<preview-parent connection string, from neonctl or the Neon console>"
pnpm drizzle-kit migrate
pnpm tsx scripts/seed.ts
```

Then point the integration's preview branching at `preview-parent` (the parent-branch setting
from step 3). If your version of the integration can only fork the project's default branch,
restructure rather than compromise: keep production data on its own branch and make the seeded
branch the one previews fork from. The invariant is the point — no PII ever enters a preview.

Keep `preview-parent` roughly current as the schema evolves. CI migrates each preview branch
per-PR (step 9), so drift won't break builds, but a badly stale parent makes previews feel fake.

## 6. Neon Auth and the test user

Enable **Neon Auth** in the Neon console and follow its Next.js quickstart (SDK install, env
vars — add them to Vercel and `.env.local`). The property you're buying: user records sync into
a `neon_auth` schema **in your own database**. Your users are rows you can join against, back
up, and take with you — the export/exit story is in
[../../docs/stack.md](../../docs/stack.md).

Create the **seeded test user** Playwright will sign in as: run the app locally against
`preview-parent` and use your own sign-up flow (or the Neon Auth dashboard). Give it an obvious
synthetic identity — `test-user@example.com` — and keep its password out of the repo; it travels
as a secret (step 10). Re-run the seed script afterward if the test user should own data.

Fallback: if a hosted auth dependency is unacceptable, use Auth.js against the same Postgres.
Everything else in this guide is unchanged.

## 7. Preview accessibility — required, and verified

The preview link is the one verification tool a non-technical DRI has. If it hits a login wall,
they either rubber-stamp or stall. Both defeat the stack. In Vercel's project settings, under
Deployment Protection:

1. **Leave protection ON.** Previews are private copies of your app; they should not be public.
2. **Enable Shareable Links** (or add every teammate to the Vercel team) so a DRI without a
   Vercel account can open a preview.
3. **Create a "Protection Bypass for Automation" secret.** Save it as the
   `VERCEL_AUTOMATION_BYPASS_SECRET` repo secret — Playwright sends it as the
   `x-vercel-protection-bypass` header so tests get through while protection stays on for
   everyone else.

**Verify — do not skip:** open the latest preview URL in a private browser window, or send it to
your phone. You should see the app, not a login page. The install isn't done until this passes.

## 8. Vitest

```bash
pnpm add -D vitest @vitejs/plugin-react jsdom @testing-library/react
```

Add `"test": "vitest run"` to `package.json` scripts, write one real test, and confirm
`pnpm test` passes. CI (step 10) runs this on every PR — unit tests are the cheap gate that
catches logic mistakes before anything deploys.

## 9. Playwright against previews

```bash
pnpm create playwright
```

Point it at the preview instead of localhost in `playwright.config.ts`:

```ts
use: {
  baseURL: process.env.PLAYWRIGHT_BASE_URL ?? "http://localhost:3000",
  extraHTTPHeaders: process.env.VERCEL_AUTOMATION_BYPASS_SECRET
    ? {
        "x-vercel-protection-bypass": process.env.VERCEL_AUTOMATION_BYPASS_SECRET,
        "x-vercel-set-bypass-cookie": "true",
      }
    : {},
},
```

Write a small smoke suite: sign in as the test user, walk the one or two paths the business
lives on. Keep it small — these run on every PR against a real deployment, so every test must
earn its seconds. What you're verifying is the thing that ships: same build, same database
branch, same auth.

Create `.github/workflows/e2e-preview.yml` — it waits for the Vercel preview, migrates the PR's
database branch, then runs the smoke tests against the preview URL:

```yaml
name: e2e-preview
on:
  deployment_status:
jobs:
  smoke:
    # Runs when a Vercel preview deployment reports success.
    if: >
      github.event.deployment_status.state == 'success' &&
      startsWith(github.event.deployment_status.environment, 'Preview')
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          ref: ${{ github.event.deployment.ref }}
      - uses: pnpm/action-setup@v4
      - uses: actions/setup-node@v4
        with: { node-version: 22, cache: pnpm }
      - run: pnpm install --frozen-lockfile

      # Apply this PR's committed migrations to its preview database branch,
      # BEFORE the smoke tests. The Neon integration names preview branches
      # after the git branch — check the naming once in the Neon console and
      # adjust the pattern below if yours differs.
      - name: Migrate the preview database branch
        run: |
          DATABASE_URL=$(npx neonctl connection-string "preview/${{ github.event.deployment.ref }}" \
            --project-id "$NEON_PROJECT_ID")
          export DATABASE_URL
          pnpm drizzle-kit migrate
        env:
          NEON_API_KEY: ${{ secrets.NEON_API_KEY }}
          NEON_PROJECT_ID: ${{ vars.NEON_PROJECT_ID }}

      - name: Smoke-test the preview
        run: pnpm exec playwright test
        env:
          PLAYWRIGHT_BASE_URL: ${{ github.event.deployment_status.environment_url }}
          VERCEL_AUTOMATION_BYPASS_SECRET: ${{ secrets.VERCEL_AUTOMATION_BYPASS_SECRET }}
```

## 10. CI, rails, and the production migration job

Copy the remaining templates from the okrdev repo:

| From (okrdev repo) | To (your repo) |
|--------------------|----------------|
| [../github/workflows/ci.yml](../github/workflows/ci.yml) | `.github/workflows/ci.yml` |
| [../github/workflows/okr-gate.yml](../github/workflows/okr-gate.yml) | `.github/workflows/okr-gate.yml` |
| [../github/pull_request_template.md](../github/pull_request_template.md) | `.github/pull_request_template.md` |
| [../github/CODEOWNERS](../github/CODEOWNERS) | `.github/CODEOWNERS` |

`ci.yml` is the required gate: lint, typecheck, unit tests, build. `okr-gate.yml` and the PR
template are Level 2 method rails — opt-in, and independent of the stack. Edit `CODEOWNERS` so
`drizzle/migrations/**` and your auth/payment paths map to real reviewers.

Then create `.github/workflows/migrate-prod.yml` — production migrations, gated with the
production deploy:

```yaml
name: migrate-prod
on:
  push:
    branches: [main]
concurrency: migrate-prod   # never two migration runs at once
jobs:
  migrate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: pnpm/action-setup@v4
      - uses: actions/setup-node@v4
        with: { node-version: 22, cache: pnpm }
      - run: pnpm install --frozen-lockfile
      - run: pnpm drizzle-kit migrate
        env:
          DATABASE_URL: ${{ secrets.PRODUCTION_DATABASE_URL }}
```

This job and Vercel's production build start at the same moment and race. That race is safe
*because* of the expand/contract rule from step 4 — every migration is backward compatible with
the code already running, and every deploy runs against the schema it finds. Skip the rule and
the race stops being safe; the rule is not optional.

**Secrets and variables** (repo Settings → Secrets and variables → Actions):

| Name | Kind | Used by |
|------|------|---------|
| `NEON_API_KEY` | secret | `e2e-preview.yml`, `neon-cleanup.yml` |
| `NEON_PROJECT_ID` | variable | `e2e-preview.yml`, `neon-cleanup.yml` |
| `PRODUCTION_DATABASE_URL` | secret | `migrate-prod.yml` |
| `VERCEL_AUTOMATION_BYPASS_SECRET` | secret | `e2e-preview.yml` (Playwright bypass header) |
| Test user credentials | secret | your Playwright sign-in step |

## 11. Protect main

```bash
./branch-protection.sh your-org/my-app
```

The script ([branch-protection.sh](branch-protection.sh)) makes merges squash-only, then creates
a branch ruleset on the default branch: PR required with one approval and Code Owners review, a
green `ci` check required, no force pushes, no deletions — plus the bypass that lets okrdev
state writes (parking lot captures, check-in files under `okrdev/**`) land directly on `main`,
because a ten-second capture can't wait on CI. The script's comments are honest about the
bypass mechanics and the fallback for teams that refuse direct pushes.

If you renamed the job in `.github/workflows/ci.yml`, match it:

```bash
OKRDEV_REQUIRED_CHECK="your-job-name" ./branch-protection.sh your-org/my-app
```

Plan wall: rulesets on private repos need GitHub Pro or Team. The script says so clearly if the
API refuses.

## 12. Verify the whole loop

Open one deliberately trivial PR — change the homepage headline — and watch the factory run:

- [ ] CI runs and goes green.
- [ ] A preview URL appears on the PR, and a `preview/...` branch appears in the Neon console.
- [ ] `e2e-preview` migrates the branch and the smoke tests pass against the preview.
- [ ] The preview opens from a phone or private browser window — app, not login wall.
- [ ] okr-gate asks for a `KR:` line (add `KR: maintenance` — that's what this is).
- [ ] Merging is blocked until CI is green and a review lands.
- [ ] Squash merge → production deploys, `migrate-prod` runs, the Neon preview branch is
      deleted.

When every box checks, the stack is real. Next: `/okrdev:plan` to draft your first cycle, and
hand any non-technical DRIs [../../docs/dri-onboarding.md](../../docs/dri-onboarding.md) and
[../../docs/shipping-explained.md](../../docs/shipping-explained.md) — the loop you just built
is the one they'll live in.
