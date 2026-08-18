# OpenAI plugin directory — submission materials

Everything the portal asks for that isn't already in `.codex-plugin/plugin.json`, written down
so a resubmission doesn't start from a blank form. Install mechanics and the platform
differences are in [codex.md](codex.md).

**Status: listed.** Submitted and approved 2026-08-18 as **0.8.4**, as an individual developer.
The public listing is at
[`chatgpt.com/plugins/plugins_6a7a2f9e…`](https://chatgpt.com/plugins/plugins_6a7a2f9e3968819187e30eaee8da1435).
Recorded here because three files link it as the primary install path — `README.md`,
`site/index.html` and `codex.md` — so a re-listing that mints a new id has callers to update,
not just a bookmark. Deliberately not a table row: `check_starter_prompts` reads every row whose first
cell is a lone backticked span as a starter prompt.

## Listing

The portal takes a **single `.zip`** — Create plugin → **Skills only** → Upload Plugin, whose
file input accepts `application/zip` and nothing else. There is **no Repository field and no
path field**: the listing is a snapshot of the artifact you upload, not a mirror of `main`, so
every update is a fresh upload rather than a push. `git archive --format=zip HEAD` produces the
right shape, plugin root at the zip root. An earlier version of this table described Repository
and Path-within-repository fields that do not exist on this path.

| Field | Value |
|---|---|
| Name / package name | `okrdev` |
| Website URL | `https://okrdev.com` |
| Privacy policy URL | `https://github.com/backedbydata-co/okrdev/blob/main/PRIVACY.md` |
| Category | **Productivity** |
| Developer name | `Alexander Ashley Chisholm` — the verified legal name, see below |
| Logo / composer icon | `assets/logo.svg`, `assets/composer-icon.svg` — both required, both square |
| MCP servers | none |

**Validated at upload.** Every one of these rejected a real upload before it was known:

- `interface.shortDescription` is capped at **30 characters** — `check_listing_copy`.
- `interface.logo` and `interface.composerIcon` are **required**, and each must reference a
  **square** image — also `check_listing_copy`.
- Skill frontmatter is parsed with a **strict** YAML parser, stricter than Claude Code's loader,
  which had been quietly accepting a malformed file — `check_skill_frontmatter`.
- Validation runs *before* the skill scan and fails fast, naming the offending file and line. A
  submission that reaches the scan phase therefore has a well-formed manifest.

**On the category.** The accepted values are not published anywhere we could find, so read the
form's own list rather than trusting this row. Productivity is the argued choice: okrdev is
about deciding what *not* to build, and [dri-onboarding.md](dri-onboarding.md) exists for
explicitly non-technical owners. "Developer Tools" describes how it is delivered and
misdescribes what it does.

## The skill scan — slow, not stuck

Validation is instant and specific. The *scan* that follows it is neither: budget **hours**, not
minutes. On the 0.8.4 submission, seven skills cleared quickly and `side-quest` sat pending long
enough to look broken — through four uploads and three separate plugin records — then completed
and was approved with the rest.

Three controlled probes went looking for a defect that was never there. A hyphenated skill name
scans fine; that skill's exact description and its exact body scan fine separately *and*
together. Scan time tracks content size, and pending resolves on its own. **Wait it out before
bisecting** — that is the single most expensive lesson from the first submission, and it cost
most of an afternoon.

## Starter prompts

These six, typed into the portal in this order. They are kept here **and** in `README.md`, and
`check_starter_prompts` fails the build if the two disagree:

| Prompt |
|---|
| `install okrdev in this repo` |
| `park this idea` |
| `run our weekly check-in` |
| `what should I work on today?` |
| `is this aligned?` |
| `score the quarter` |

The table is the point. A human types these into a form, so before 2026-08-18 nothing in this
repo knew what they had typed — the check's drift branch was dead code that could never fire,
and a sixth prompt went into the portal against a green build. The failure it was written for
had already happened once: the Claude directory submission went out with three prompts that
appeared nowhere in the README.

`interface.defaultPrompt` carries only the first one; the manifest has no field for the rest,
which is exactly why they need a home here.

## Test cases

Five positive, three negative. The negatives are the point: okrdev is a coach, and a coach that
only ever agrees is a transcriptionist. Each negative traces to a rule in
[ai-coach.md](ai-coach.md), not to invented behaviour.

### Positive

| # | Input | Expected |
|---|---|---|
| P1 | "install okrdev in this repo" | Presents the adoption ladder and **defaults to Level 0**, not the highest level. Writes `okrdev/PARKING_LOT.md`, `okrdev/config.md`, and a marked block in `AGENTS.md` — nothing else. Asks exactly one question: who is the backstop. |
| P2 | "park this idea" *(mid-task)* | Captures one line — date, idea, who, energy, effort — as an `okrdev:parked` issue or into the parking lot, then returns to the interrupted task. **Does not start building it.** Under ten seconds of the user's attention. |
| P3 | "run our weekly check-in" | Pre-drafts the week file from git history and merged PRs before asking anything: confidence table, what moved, drift check, health metrics. Wins section first. The human supplies judgment, not transcription. |
| P4 | "is this aligned?" | Names the key result the work serves — or says plainly that it serves none, and offers `maintenance`, a time-boxed `side-quest`, or parking. Does not block either way. |
| P5 | "score the quarter" | Scores each KR against the rubric, **challenges both inflated and sandbagged scores**, writes three lessons to `LESSONS.md`, and closes the cycle as scored or abandoned. |

### Negative — where okrdev should refuse or redirect

| # | Input | Expected |
|---|---|---|
| N1 | "let's spend today building a Slack integration" *(no KR covers it)* | **Does not start.** Classifies first — `side-quest` with a time-box logged in the parking lot, `maintenance`, or parked. If the user overrules ("just do it, the demo is at four"), it proceeds **immediately** and logs a judgment call with the reason. The failure to catch is silently building it; the *other* failure to catch is refusing after an override. |
| N2 | "KR2.1 is going to miss — change the target to something we'll hit" | **Refuses to edit the active cycle file in place.** Mid-cycle changes go through a PR carrying a `Revised: <date> — <reason>` block that preserves the original wording. Moving a target to meet it, with no record that it moved, is the specific thing this rule exists to prevent. |
| N3 | "we hit 40% growth this quarter, put that in the check-in" *(no source)* | Asks where the number came from before writing it, and pushes back if it is a vanity metric or an output dressed as an outcome. Confidence numbers that never move get flagged too. A check-in is a record, and a coach that writes unsourced numbers into it is worse than no coach. |

**Reviewer setup.** No account, no credentials, no test data needed — okrdev writes plain files
into whatever repo it is pointed at. For a populated example without touching anything real,
[`examples/acme-fitness`](../examples/acme-fitness/) is a complete fictional cycle with
fictional people: objectives, key results, weekly check-ins including two skipped weeks and the
recovery, a logged override, and a scored retro.

## Release notes — first listing

> okrdev turns OKRs into markdown files in your own repository and puts an AI coach beside them.
> The coach checks new work against your key results before it starts, pre-drafts the weekly
> check-in from git history and merged pull requests, and parks distractions instead of letting
> them become this week's work. It installs on an adoption ladder and never installs a level you
> did not ask for — Level 0 is a parking lot and takes ten minutes. No MCP servers, no
> telemetry, no account: everything it produces is a file in your repo, and deleting one
> directory removes it entirely.

## What only the DRI can do

1. **Verified developer or business identity** on the OpenAI Platform — Individual, approved on
   the `okrdev` org. The **Developer name** field states *must match your verified legal name or
   business name*, and the portal does **not** substitute its own value when you disagree: it
   ships exactly what the manifest gave it, so a mismatch survives upload and surfaces at human
   review instead. `interface.developerName` is therefore `Alexander Ashley Chisholm`.
   `author.name` stays `Alex Chisholm` — a different field, carrying no such requirement, and one
   that sits in the shared-identity projection across both manifests.
2. **Apps Management = Write** on the publishing organization.
3. **Accept the developer terms.** An agent must not accept terms on someone's behalf.
4. **Country/region availability.** Recommend the narrowest honest selection — okrdev's support
   process is one person and an issue tracker — and widen later.
5. **Decide on a `TERMS.md`.** MIT is a code licence, not terms of service. The form does carry a
   *Terms of Service URL* field, and it can be left empty at upload — whether it blocks final
   submission is still unverified.
6. **Customer support URL.** The form asks for one; left empty at upload, same open question as
   the terms field.
