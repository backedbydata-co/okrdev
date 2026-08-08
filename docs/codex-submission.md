# OpenAI plugin directory — submission materials

Everything the portal asks for that isn't already in `.codex-plugin/plugin.json`, written down
so a resubmission doesn't start from a blank form. Install mechanics and the platform
differences are in [codex.md](codex.md).

## Listing

| Field | Value |
|---|---|
| Name | `okrdev` |
| Repository | `https://github.com/backedbydata-co/okrdev` (public, MIT) |
| Path within repository | *blank* — the plugin root is the repo root |
| Homepage | `https://okrdev.com` |
| Privacy policy | `https://github.com/backedbydata-co/okrdev/blob/main/PRIVACY.md` |
| Category | **Productivity** |
| Logo / composer icon | `assets/logo.svg`, `assets/composer-icon.svg` |
| MCP servers | none |

**On the category.** The accepted values are not published anywhere we could find, so read the
form's own list rather than trusting this row. Productivity is the argued choice: okrdev is
about deciding what *not* to build, and [dri-onboarding.md](dri-onboarding.md) exists for
explicitly non-technical owners. "Developer Tools" describes how it is delivered and
misdescribes what it does.

## Starter prompts

The five in `README.md`, kept verbatim there so the listing and the docs cannot disagree —
`check_starter_prompts` fails the build if they drift, which is not hypothetical: the Claude
directory submission went out with three prompts that appeared nowhere in the README.

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

1. **Verified developer or business identity** on the OpenAI Platform. Submitted 2026-08-08 as
   an individual — so `interface.developerName` is `Alex Chisholm`, and it must keep matching
   the verified identity or the portal substitutes its own value.
2. **Apps Management = Write** on the publishing organization.
3. **Accept the developer terms.** An agent must not accept terms on someone's behalf.
4. **Country/region availability.** Recommend the narrowest honest selection — okrdev's support
   process is one person and an issue tracker — and widen later.
5. **Decide on a `TERMS.md`.** MIT is a code licence, not terms of service. The field appears
   optional for a plugin with no server and no account, but that is unverified; check the form.
