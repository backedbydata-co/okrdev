# okrdev

**An OKR-obsessed operating framework for the age of cheap execution.**

okrdev installs into any business or project — existing or brand-new — and makes objectives the
organizing spine of everything you build. An AI coach keeps you (and your team) focused and
accountable: it knows your mission and this cycle's key results, challenges work that serves
neither, pre-drafts your weekly check-ins, and catalogs every shiny idea into a parking lot
instead of letting it eat your week.

The premise: AI made building cheap, which made distraction cheap too. The scarce resource is
no longer the ability to build — it's the discipline to decide what *not* to build.
[MANIFESTO.md](MANIFESTO.md) makes the full argument.

## What you get

- **A git-native OKR system.** Objectives, key results, weekly check-ins, cycle retros — all
  markdown files in your own repo. Versioned, reviewable by PR, greppable by agents, no SaaS.
- **An AI coach with the right amount of teeth.** It classifies work against your KRs, flags
  drift, and pushes back on vanity metrics and sandbagged targets. It can never block you — but
  every override is logged, and you'll see it at the next check-in.
- **A parking lot for distractions.** Capture an idea in ten seconds. Triage weekly: promote it,
  archive it, or sanction it as a time-boxed side-quest. Ideas stop dying and stop winning.
- **Roles built for AI-first teams.** Anyone can be the DRI who owns an objective end-to-end,
  with AI filling skill gaps. Domain experts review where stakes are high — enforced by rails
  (CODEOWNERS, protected branches), not org charts.
- **An optional opinionated stack** for new projects: Vercel + Neon + GitHub with per-PR preview
  environments (each with its own database branch), CI gates, and automated tests — so
  non-technical builders ship safely because unsafe paths are hard, not because someone watches.

## The adoption ladder

You start at the bottom and earn your way up. Nothing above your level gets installed uninvited.

| Level | What it adds | Time to value |
|-------|--------------|---------------|
| **0 — Parking lot** | Idea capture + weekly triage. Nothing else. | 10 minutes |
| **1 — The method** | Mission, cycle OKRs, weekly check-ins, retros. This is okrdev proper. | One planning session |
| **2 — Collaboration rails** | `KR:` tags on PRs, the okr-gate nudge, CODEOWNERS, branch protection. | An afternoon |
| **Stack module** | The full Vercel + Neon AI-first environment. Greenfield projects, or deliberate migrations. | A day |

**Existing codebase? Keep your stack.** The method installs into any repo — even a repo that
contains nothing but the `okrdev/` directory, if your business isn't a software business.
Details in [docs/adoption.md](docs/adoption.md).

## Quickstart

okrdev is a plugin for [ChatGPT and Codex](https://developers.openai.com/codex) and for
[Claude Code](https://claude.com/claude-code), plus a set of documents. One install, either
agent — see [docs/codex.md](docs/codex.md) for what differs.

**The shortest path is a button.** okrdev is listed in the ChatGPT plugin directory, so there is
no marketplace command to run and nothing to copy:

> **[Install okrdev from the plugin directory →](https://chatgpt.com/plugins/plugins_6a7a2f9e3968819187e30eaee8da1435)**

Press **Install plugin**, then in your project type `@okrdev` and ask it to
`install okrdev in this repo`. That is the whole install — okrdev ships as skills only, so there
is no MCP server to authorize, no account, and no keys.

In **Claude Code**, it's one paste. Drop this into any Claude Code session — the desktop app
(Mac/Windows) included — and Claude runs it for you:

> Install the okrdev plugin for me:
> `claude plugin marketplace add backedbydata-co/okrdev && claude plugin install okrdev@okrdev`

**You do not have to open a terminal.** The line inside is an ordinary shell command, so a
terminal works too — same result either way, and it is safe to re-run: both halves are
idempotent and say so rather than erroring if okrdev is already there.

The distinction that matters is *code session*, not *desktop*: a Claude **chat** session has no
shell and cannot run this. A Claude **Code** session can, wherever it runs.

Then **`/reload-plugins`** — or just open a new session, which loads it automatically — and
okrdev is available in every Claude Code session on that machine.

The **Codex CLI** takes the same shape — hand it to a Codex session, or run it in a shell:

> Install the okrdev plugin for me:
> `codex plugin marketplace add backedbydata-co/okrdev && codex plugin add okrdev@okrdev`

<details>
<summary>Both pastes, unchained</summary>

Each paste is exactly its two commands joined with `&&`:

```bash
claude plugin marketplace add backedbydata-co/okrdev
claude plugin install okrdev@okrdev
```

```bash
codex plugin marketplace add backedbydata-co/okrdev
codex plugin add okrdev@okrdev
```

`install.sh` does the Claude Code pair in one shot for scripts and CI, where there is no agent
to hand a prompt to. See [docs/adoption.md](docs/adoption.md#headless-install), which also
covers the older interactive `/plugin` route and where it does and does not work.

</details>

Then, in the repo where you want okrdev to live:

```bash
/okrdev:install     # walks the adoption ladder, starts at Level 0
/okrdev:plan        # when you're ready for Level 1: draft your first cycle's OKRs
```

Skills are written `/okrdev:<name>` throughout these docs, which is how Claude Code invokes
them. **On Codex, type `@` and pick the skill** — same skills, same files, different keystroke.

Prefer no dialogs? The Claude Code steps also work headlessly — from a script, a CI job, or an
agent bootstrapping a machine. The checkout goes to a temp directory, never a path you might
already own, and never the repo you're adopting into — a clone landing at `okrdev/` would sit
exactly where the method reserves space for your ledger:

```bash
dir=$(mktemp -d)
git clone https://github.com/backedbydata-co/okrdev.git "$dir/okrdev"
"$dir/okrdev/install.sh"   # registers the marketplace + installs the plugin, no TUI
rm -rf "$dir"              # optional: the marketplace keeps its own copy under ~/.claude
```

Details and the by-hand equivalent in [docs/adoption.md](docs/adoption.md#headless-install).

Then live in it:

```bash
/okrdev:park        # "park this idea" — 10-second capture, back to work
/okrdev:triage      # weekly at Level 0; from Level 1 it runs inside /okrdev:checkin
/okrdev:checkin     # weekly: pre-drafted, wins first, 15 minutes for real
/okrdev:coach       # anytime: confidence trends, drift, "is this aligned?"
/okrdev:side-quest  # sanction a distraction, with a time-box
/okrdev:retro       # end of cycle: score honestly, extract lessons
```

You can also just say what you want — the skills trigger on plain language. Six to start with:

- "install okrdev in this repo"
- "park this idea"
- "run our weekly check-in"
- "what should I work on today?"
- "is this aligned?"
- "score the quarter"

These are the starter prompts listed in the plugin directories, kept here verbatim so the
listing and the repo can't disagree — `check_starter_prompts` fails the build if they drift.

Some other agent? The skills are plain markdown — copy `skills/*` into wherever your agent looks
for skills, along with `templates/*` (the skills create files from them; they resolve
`templates/` relative to where you copied it), or hand any capable agent the docs. The format
is the framework.

## What it looks like installed

```
your-repo/
├── okrdev/
│   ├── MISSION.md                    # what you're building and why — planning reads this first
│   ├── config.md                     # cadence, budgets, your human backstop
│   ├── PARKING_LOT.md                # captured / side-quests / promoted / archived
│   ├── LESSONS.md                    # what each retro taught you
│   ├── okrs/2026-Q3.md               # this cycle: objectives, KRs, health metrics
│   └── checkins/2026-Q3/2026-W29.md  # one file per week, mostly written by the coach
├── CLAUDE.md                         # + the coach block (marked, removable)
│                                     #   AGENTS.md instead, on Codex — one or the other
└── .github/                          # Level 2: PR template, okr-gate, CODEOWNERS
```

See a full worked cycle — including a sanctioned side-quest, a logged override, two skipped
weeks and the recovery — in [examples/acme-fitness](examples/acme-fitness/).

## Repo map

| Path | What's there |
|------|--------------|
| [MANIFESTO.md](MANIFESTO.md) | Why okrdev exists |
| [docs/method.md](docs/method.md) | The OKR system: cycles, KR rules, scoring, confidence, health metrics |
| [docs/evidence.md](docs/evidence.md) | What counts as proof: the evidence ladder, the demo review, and the customer's-words rule |
| [docs/testing.md](docs/testing.md) | How okrdev tests itself: red-first fixes, deterministic rails, coach-behavior scenarios |
| [docs/rituals.md](docs/rituals.md) | Runnable scripts: planning, check-in, triage, retro |
| [docs/roles.md](docs/roles.md) | DRI, builder, domain reviewer, backstop — and the AI's three hats |
| [docs/parking-lot.md](docs/parking-lot.md) | The catalog-don't-chase protocol |
| [docs/ai-coach.md](docs/ai-coach.md) | The coach contract: authority, tone, drift mechanics |
| [docs/adoption.md](docs/adoption.md) | The ladder, brownfield installs, solo mode, uninstall |
| [docs/dri-onboarding.md](docs/dri-onboarding.md) | Zero to first shipped change, for non-technical DRIs |
| [docs/shipping-explained.md](docs/shipping-explained.md) | PRs, CI, previews — in plain language, with a glossary |
| [docs/stack.md](docs/stack.md) | The optional stack module and why each piece |
| [docs/codex.md](docs/codex.md) | Running okrdev on Codex: what differs from Claude Code, and what was verified |
| [docs/codex-submission.md](docs/codex-submission.md) | Directory-listing materials: test cases, starter prompts, release notes |
| [install.sh](install.sh) | Headless plugin install for scripts and CI — the Quickstart without an agent |
| [skills/](skills/) | The eight coach skills (install, plan, checkin, park, triage, side-quest, retro, coach) |
| [templates/](templates/) | Everything `install` copies: okrdev/ files, coach block, GitHub rails, stack setup |
| [examples/acme-fitness/](examples/acme-fitness/) | A full fictional cycle, warts included |

## Principles, in one breath

Objectives before code. Catalog, don't chase. The coach never blocks — it remembers. Anyone can
own anything. Safety is an environment, not a behavior. Numbers you don't act on are theater.

## License

MIT. okrdev collects nothing — no telemetry, no analytics, no account, no MCP servers; your
OKRs are files in your own repo. The specifics, including the one place a link hands you to a
third party, are in [PRIVACY.md](PRIVACY.md).
