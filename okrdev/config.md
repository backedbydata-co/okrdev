---
okrdev_version: 0.8.0         # used by upgrade and uninstall — don't edit by hand
level: 1                      # 0 parking lot | 1 method | 2 collab rails
cycle_length: quarterly       # quarterly | six-week
checkin_cadence: weekly
side_quest_box_hours_per_week: 4
strict_gate: false            # record of the Level 2 strict-mode decision. The gate itself is controlled by the OKRDEV_STRICT_GATE repo variable (gh variable set OKRDEV_STRICT_GATE --body true) — flip both together
backstop: alex                # the human to call when DRI + coach are both stuck
---

# okrdev config

okrdev runs on itself. This repo *is* the okrdev framework, and it uses okrdev to plan its own
development — the first and most honest test of whether the method survives contact with real
work.

- Solo project: Alex is the sole DRI and, being the whole company, his own backstop. When the
  coach and Alex are both stuck, the escalation is "sleep on it, decide tomorrow."
- Level 1 (method only). No Level 2 rails yet — that's itself a candidate for an early KR.
- Check-ins are async/solo: Alex runs `/okrdev:checkin` whenever the week's work is done.

## Stack module — mapped, not installed

`site/` (the okrdev landing page) deploys to Vercel. The stack module was **mapped** onto it in
the mode [issue #1](https://github.com/backedbydata-co/okrdev/issues/1) names: take the stack's
properties where they already hold, install only what is genuinely missing, and log the rest as
named exceptions rather than leaving them as drift.

The deciding question for each row is the one issue #1 proposes — *does the property already
hold?* — not *do we run the same tool?*

| Stack default | Decision here | Why |
|---|---|---|
| Preview deployment per PR | **Installed** | Genuinely missing. This is the property the module exists for. |
| Production on merge to `main` | **Installed** | Comes with the git integration; merge is the deploy, and there is no second path. |
| Next.js app | **Exception, named** | `site/index.html` is one self-contained file — inline CSS, data-URI favicon, no scripts, no relative assets. A framework would add a build step, a lockfile and a dependency surface to publish 28KB of static HTML. |
| Neon Postgres, branch per preview | **N/A — no database** | The site stores nothing. Previews are byte-identical to production, so the isolation the branch-per-preview rule buys is already unconditionally true. Revisit the moment the site gains state. |
| Seeded parent branch, synthetic data | **N/A** | Follows the row above: no data, so no seeding policy and no PII to keep out of previews. |
| Drizzle migrations, `migrate-prod` job | **N/A** | Follows the row above. |
| Neon Auth | **N/A** | No accounts, no sign-in. A public marketing page. |
| Vitest units | **Exception, named** | The property — *units run on every PR* — is not what guards a zero-logic static page. `check.yml` already gates the repo on every PR. |
| Playwright smoke vs. previews | **Exception, named** | Installing pnpm, a lockfile and a browser matrix to assert that one static file renders is the re-tooling migration issue #1 warns adopters away from. The preview URL plus a human click is the verification. Reopen if the site gains behaviour. |
| Required CI check on the default branch | **Already holds** | `check.yml` runs on every PR and every push to `main`. |
| Level 2 rails (`KR:` gate, CODEOWNERS, protected `main`) | **Deferred** | Unrelated to the deploy; this repo is Level 1 by choice and the ladder says do not install a level nobody asked for. |

Two decisions worth their own line, because both look like omissions and are not:

- **No `ignoreCommand`.** A path filter would skip builds on PRs that do not touch `site/`, which
  saves seconds and costs the invariant: `git diff HEAD^ HEAD` sees only the newest commit, so a
  PR that touched `site/` early and `docs/` last would silently get no preview. The preview is
  the proof — it builds every time. Same reasoning the repo already applies to never
  `paths-ignore`-ing a required check.
- **Preview protection stays ON** (Vercel's default), with production public. Previews are
  unreleased copy about pricing and positioning; production is a marketing page that must be
  reachable by anyone, including crawlers.
