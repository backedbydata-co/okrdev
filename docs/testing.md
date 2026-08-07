# Testing — red-first, coach scenarios, and how a prompt framework proves itself

okrdev's product is a contract about behavior: markdown that a language model reads and then
acts on. There is almost no conventional code to unit-test — and yet the framework can rot in
two entirely conventional ways: its artifacts drift (a contract stated in six files moves in
five), and its coach misbehaves (a rule the docs state, a session ignores). This document is
the adoption plan for test-driven and behavior-driven development pointed at those two rots —
translated for a repo whose runtime is a model, not a binary:

- **TDD, translated: red-first is the definition of done for method changes.** A friction fix
  counts as done when the chafe that motivated it exists as a *failing check* first, and the
  fix turns it green.
- **BDD, translated: the coach contract made executable.** [ai-coach.md](ai-coach.md) already
  declares "if the coach in your repo behaves differently from this document, this document
  wins" — that is a spec claiming authority over behavior. BDD scenarios are that spec made
  falsifiable: Given a repo state, When these user turns, Then these file side-effects and
  this tone. Written, per [evidence.md](evidence.md)'s own language discipline, in the
  domain's words — park, chafe, judgment call, drift — because a scenario in the toolchain's
  words tests the wrong thing, exactly as a KR in the toolchain's words measures the wrong
  thing.

Sources, named honestly once, the way [method.md](method.md) names Grove and
[evidence.md](evidence.md) names its three traditions: red-first comes from Beck's
test-driven development; the Given/When/Then shape from North's behaviour-driven development
and Cucumber's Gherkin; the deterministic-before-judge ladder and the n-trial,
evidence-citing grading conventions from the current LLM-eval playbooks (skill-creator's
grader among them). The meta-filter, same as evidence.md's: okrdev borrows the *discipline*
of each — a failing check before a fix, specs in the domain's words — and refuses the
ceremony that grew around them: coverage ratchets, three-amigos workshops, Gherkin runners,
living-documentation tooling. The full refusal list is at the end.

One admission rule governs everything below, stated wide enough to bind: **nothing this plan
adds ever enters a user's repo as a test artifact.** The harness's code lives in this repo
only — `tests/` and `.github/` — and inside this repo it touches exactly four other
surfaces, named so the rule can be checked: a `Red-first:` line in this repo's PR bodies (a
new field, admitted as one — it never ships to users and never enters a template that does),
one upserted failure issue, the 2026-Q3 coherence row's Source (through the pinned amendment
path in Phase 1, not by prose), and read-only lines in the check-in and retro. What *does*
reach adopters is the prescription in its own section below — doctrine words and one comment
line in the opt-in Level 2 PR template, through the same opt-in gates as every stack
opinion; the install-footprint red line stands untouched. No new ritual; the check-in gains
roughly sixty seconds — one line read from one issue — and that cost is stated here rather
than rounded to zero. The suite grows **only from chafe**: every corpus scenario and every
schema assert names the real session, check-in line, parked item, or bug that motivated it.
There is no coverage target. Speculative coverage is refused by construction.

## Why this document exists

Two artifact defects are on main today:

1. **The repo's own coach block has drifted from its template.** Rule 3 in `CLAUDE.md` still
   reads "captured in 10 seconds, not built" while
   [templates/CLAUDE-okrdev.md](../templates/CLAUDE-okrdev.md) gained the `okrdev:parked`
   issue path when the issues-as-inbox bundle landed (PR #2) — a reviewer-class
   contradiction of the kind the cycle's coherence health metric names
   (`okrdev/okrs/2026-Q3.md:89`). The root cause is mechanical and ships to every adopter:
   `install` writes the coach block once and nothing re-syncs it on plugin upgrade — a
   KR1.3 candidate in its own right, surfaced by writing this plan.
2. **A shipped script fails wrong.** `templates/stack/branch-protection.sh` validates
   `OKRDEV_REQUIRED_APPROVALS` at line 65 by calling `die` — defined only at line 69. Feed
   it a bad value and it exits 127 with `die: command not found` instead of the message it
   meant to print. Nothing runs this script before it ships to users.

The first defect was already caught: the parking lot's 2026-08-04 sync-wrinkles entry names
the coach-block drift and the `okrdev_version` skew (this repo's own install sits
several releases behind the template it ships),
headed for a maintenance PR. That sharpens the argument rather than weakening it. The
framework's eyes work — capture happened, through the sanctioned path — and the fix still
hasn't happened, because **a capture creates no forcing function**. A required check does:
parked-but-unfixed is exactly the gap between noticing and enforcing that a red check
closes. The second defect appears in no ledger at all — it is the first genuinely new catch
this plan's checks would make. Both are *artifact* defects, catchable by a five-line check
with no LLM anywhere, which is the empirical argument for this plan's ordering:
deterministic rails first, judged behavior second. And both are exhibits for the mission's
own strategy line, which O1 operationalizes: "the job this cycle is not more features —
it's evidence" (`okrdev/MISSION.md:11`).

The deeper reason is specific to prompt frameworks: **a model bump is a silent breaking
change with zero diff.** Code that passed yesterday passes tomorrow; a prompt that produced
rule-following behavior on yesterday's model may not on tomorrow's, and no file changed. A
scenario suite is the only regression net that exists on that axis.

## The rule this plan adds

One new rule: **a KR1.3 friction fix is done when the chafe exists as a failing check —
validator assert or coach scenario — and the fix turns it green.** By this repo's own
standard an unwired rule is theater, so every fragment of this rule attaches to an existing
rail; the single wiring table at the end of this document is the complete map.

## Classification, named before the work starts

This plan spans two different kinds of work, and tagging them as one would be silent scope
expansion, so the split is named here and carried in every phase's PR tags:

- **Layer D and Phases 0–1 are `KR: 1.3`** on the strength of an existing triage decision:
  "Template-validation CI for this repo (YAML/JSON/bash lint, dead-link check)" was promoted
  to KR1.3 at the 2026-W31 check-in (`okrdev/PARKING_LOT.md:35`). The coherence greps also
  trace to a captured need — the parking lot's 2026-08-04 "coherence sweep after
  evidence.md lands" entry is the manual ancestor these greps mechanize. The two Phase 0
  *fixes* themselves, however, stay `maintenance`: the parked sync-wrinkles entry already
  classified that work, and a plan does not get to re-tag parked maintenance as KR credit.
- **Layer J — the scenario harness, runner, and judge — is a `side-quest`** until proven
  otherwise: it is new capability that no triage has promoted and no chafe has yet demanded.
  It gets a time-box against the weekly budget, a parking-lot log line, and one conversion
  condition: the first time a real chafe runs Loop B end-to-end (red scenario → skill fix →
  green), the harness has earned its `KR: 1.3` tag and the retro judges the rest. If that
  never happens this cycle, the side-quest box was the honest price of finding out.

- **The adopter prescription's four implementation PRs are a `side-quest`, decision-sourced**
  — they trace to the 2026-08-06 DRI ruling logged in the W32 Judgment calls, not to a
  dogfood chafe, and KR1.3's own admission rule ("found by dogfooding … not speculative
  polish") is not this document's to rewrite. If the DRI wants decision-sourced doctrine to
  count toward the 8, that is a `Revised:` amendment to KR1.3, signed through the protocol —
  not a re-tag here.

The DRI confirms or overrules this split at this plan's PR review — that conversation is the
rule-8 venue.

## Two layers, one ledger

**Layer D — deterministic validators.** `tests/` — plain bash + node, zero dependencies.
Runs on every PR, hard-fails, finishes in under a minute, needs no network and no secrets.
This is TDD's home.

What it asserts, grown from verified contracts:

- **Coherence greps — the mechanical half of the health metric.** The coach block in
  `CLAUDE.md` byte-equals the marker region of `templates/CLAUDE-okrdev.md` and the fenced
  block in `docs/ai-coach.md` — a three-way assert with, today, exactly one outlier:
  `CLAUDE.md`. (The other two already match, so the fix is one hunk in one file; the assert
  stays three-way to catch the next drift in any direction.) The `KR:` line grammar lives
  in *three* copies — `docs/method.md:366`, `templates/github/workflows/okr-gate.yml:77`,
  and `skills/checkin/SKILL.md` — all agreeing today; the assert strips regex delimiters
  and flags, then requires the three bodies byte-identical, freezing them before any one
  drifts. The judgment-call line format, stated in six places today, stays identical in all
  six. The numeric thresholds split, and the split is the finding: **a threshold is
  assertable only where one literal substring covers every legitimate occurrence.** Four
  qualify — `10 days`, `30% of PRs`, `5% of PRs`, `60% of the cycle` — and get token-count
  asserts over an explicit file list, in both directions: every named file states it, and no
  other file does. The three that don't qualify (the two-per-cycle emergency ceiling,
  three-weeks-flat, and 4 box-hours) vary in phrasing *and numeral* across their copies — the
  emergency ceiling alone is written six ways, and `4` means three different things in this
  repo. Picking a winner among those spellings would be a doctrine decision made inside a
  test, so they become `DO_NOT_FREEZE` entries instead: a future session cannot quietly
  normalize them into assertability without the list failing first.

  The negative tokens are scoped to the staleness file list, never repo-wide. `9 days`
  appears four times legitimately — it is the canonical output-vs-outcome example in
  [method.md](method.md) and [evidence.md](evidence.md), and acme's KR1.2 target — so a
  repo-wide negative would be permanently red on the documents that teach the rule. A
  negative token has to be scoped to the files that *state* the rule.
  (Phase 1, not Phase 0: it is not a five-line grep.)
- **Extracted-code tests.** The okr-gate JS pulled out of its YAML — with one honest
  wrinkle: `github-script` runs the body inside an AsyncFunction, so its top-level `await`
  and `return` are legal there and nowhere else, and the extractor must re-wrap the body
  (`async function gate(github, core, context) { … }`) before `node --check` passes. Then
  `node:test` drives `KR_LINE` and `lookupKr` with a golden-vector table (valid: `KR: 1.2`,
  `KR: KR1.2`, `KR: 2026-Q3/KR1.2`, `KR: side-quest`; invalid: `KR: 1`, `KR:1.2 extra`;
  plus `lookupKr`'s boundary property: id `KR1.2` must never match a `KR1.23` heading),
  exported through a marked anchor comment in the YAML so the test seam is explicit and
  reviewable, not regex-guessed. (`findActiveCycle` is mostly API stub — it earns a test
  only if it ever chafes.) `branch-protection.sh`'s invalid-input path smoke-tested — three
  lines, no stub `gh` needed, asserting exit 1 *and* the intended stderr message, because
  today it exits 127 with `die: command not found` and a nonzero-only assert would pass on
  the broken version; the happy path, which does need a stub `gh` on PATH, waits for
  Phase 1. `shellcheck` and `actionlint` over `templates/stack/` and
  `templates/github/workflows/`.
- **Referential checks.** Every `/okrdev:<skill>` mention in `docs/`, `skills/`,
  `templates/`, and `README.md` resolves to `skills/<name>/SKILL.md` — with an explicit,
  reasoned exemption list, because two unresolvable names are *correct* today:
  `/okrdev:uninstall` (promoted, next-cycle candidate — legitimately unimplemented) and
  `/okrdev:test` (named only in this document's own ruled-out list). Every relative link in
  `docs/` and `templates/` resolves; `jq` asserts on both `.claude-plugin/` manifests.
- **The footprint check.** A checked-in manifest of exactly what `install` creates per
  level; the check fails if the install skill's copy list ever references anything outside
  it. The install-footprint health metric, mechanized.
- **Schema asserts — chafe-grown, not up-front.** Frontmatter and section validators over
  the three layers (templates must pass; `examples/acme-fitness/` passes modulo declared
  exemptions; the live `okrdev/` must pass) are added *one assert at a time, when a real
  divergence bites* — not as a 400-line validator written in week one. A bespoke markdown
  parser is the largest solo-maintenance liability on offer here, and freezing formats that
  never chafed is speculative coverage in validator's clothing. First candidate, because it
  is divergent right now and already parked: the `okrdev_version` skew — whose semantics
  (does the marker track the installed plugin version?) need the parked
  adoption.md-versioning-policy pin first. Second: the at-most-one-`status: active` cycle
  invariant.

**The do-not-freeze list.** Some divergence is deliberate flexibility, and a validator that
freezes it trains the DRI to ignore the validator. The check script carries an explicit list
of what it must NOT assert — mission-file structure, KR heading prose, check-in red-line
paraphrases, comment placement, cycle start-vs-quarter-boundary — and the list is data, not
a comment: each entry is itself a negative test asserting its cited divergence still exists,
so an entry that quietly becomes moot fails the run and forces a graduate-or-delete decision
instead of rotting. Graduation happens only via a doctrine PR that pins the format first — a
test is never where a format decision gets made. Two lines of self-enforcement complete it:
every assert call site carries a `# chafe:` comment naming its motivating chafe (a
meta-assert checks this, making "grown only from chafe" mechanical rather than aspirational),
and one pointer line in `CLAUDE.md` — outside the coach-block markers — routes future
sessions to read the list before adding an assert.

**Layer J — judged coach scenarios.** `tests/scenarios/` — BDD proper. Scenarios run
headlessly in throwaway fixture repos built under `mktemp`, with a stubbed `gh` on PATH, a
bare repo wired as `origin` (so branch-and-PR behavior is assertable as git state, not
transcript prose), and `CLAUDE_CONFIG_DIR` pointed at a throwaway dir so global memory can't
leak into a run. The invocation is pinned in the runner because every flag is load-bearing:
`claude -p --permission-mode acceptEdits --output-format stream-json --verbose --model
<pinned id>` — without `acceptEdits` the coach cannot edit files headlessly and every
scenario fails for harness reasons rather than coach behavior; `--verbose` is required
alongside stream-json in print mode; and the model id is recorded in every run summary, or
the model-bump premise above has no baseline to compare against. Asserted deterministically
first, LLM-judged second. **Never runs per-PR** — it runs during a red-first fix, weekly
before the check-in, and its accumulated weekly summaries are read at the retro.

## The scenario format

One directory per scenario: `scenario.md` + `assert.sh` (the deterministic Then block below
is the spec `assert.sh` implements) + optional judge criteria. The frontmatter is the audit
trail. The `rule:` field cites a quoted anchor phrase, not line numbers — line numbers rot
within two PRs and scenario frontmatter is permanent; a Layer D grep asserts every anchor
phrase still appears in its named file, turning doc-anchor rot into a red check. The
`source:` field is the admission gate: a corpus scenario names the real chafe that motivated
it, `source: speculative` is not a legal value, and a scenario that cannot cite a chafe does
not get merged. (One other value is legal, exactly three times, for the bootstrap fixtures
below.)

```markdown
---
id: <slug>
rule: <file — "quoted anchor phrase of the doctrine being pinned">
source: <the real chafe: check-in line / session / parked item / date — REQUIRED>
fixture: <tests/fixtures/<name>>
trials: 3
bar: 3/3 | 2/3        # 3/3 for never-list and red-line rules, 2/3 for capability rules
---
## Given
<fixture: repo state, cycle state, dates, anything seeded>
## When
<scripted user turns — verbatim from the real session where possible, never conditional>
## Then — deterministic (assert.sh runs first; judge skipped if these fail)
<git-state / file-content asserts>
## Then — judged (plain-English criteria, evidence-cited, cheap judge)
<tone and judgment criteria, including traps — things the transcript must NOT contain>
```

The When turns quoted verbatim and the Then written as observable side-effects is
[evidence.md](evidence.md)'s click-test-steps argument applied to specs: the steps are the
domain language made falsifiable. A scenario you can only narrate is rung-5 evidence about
your own test suite.

### The three bootstrap fixtures — not corpus members

The corpus proper starts **empty** and admits only chafe-sourced scenarios. The three
scenarios below carry `source: harness-bootstrap` — legal only for these three — because
their honest job is to prove the runner, the fixtures, and the judge plumbing work before
the first real chafe needs them. Each pins a hard-floor rule with file side-effects a
script can catch, so they stay useful as regression nets; none claims a chafe that hasn't
happened. All three take the 3/3 bar: each pins a never-list or red-line rule, and a
tolerance of one-in-three on a hard floor would launder failure as a pass.

### Bootstrap 1 — maintenance silence (the nag-rate red line)

```markdown
---
id: coach-maintenance-silence
rule: CLAUDE.md rule 1; ai-coach.md — "Never interrogate about maintenance";
      okrdev/okrs/2026-Q3.md — the coach-nag-rate red line
source: harness-bootstrap (proves the runner; not corpus)
fixture: live-cycle-solo
trials: 3
bar: 3/3
---
## Given
An active-cycle clone at level 1, coach block installed, and the fixture seeds one
misspelling — "recieve" — into docs/method.md.
## When
1. "there's a typo in docs/method.md — 'recieve' — fix it"
## Then — deterministic
- the one-word fix happened (git diff shows it, and nothing else)
- no line addressed to the user ends in "?" outside fenced code blocks
- at most one line mentioning classification, and it is declarative, not interrogative
- nothing under okrdev/ was touched
## Then — judged
- "The coach classified silently in one line at most and never made the bugfix feel
   expensive."
```

A green here is a regression net *under* the nag-rate health metric — it never feeds that
row's Source, which stays "dogfooding session notes": a scripted turn in a `mktemp` fixture
is not a dogfooding session, and reading it as one would be "merged" quietly substituting
for "works."

### Bootstrap 2 — natural-language override: proceed first, log always

```markdown
---
id: coach-nl-override-logs
rule: CLAUDE.md rule 5; ai-coach.md — "Never let an override fail to log"
source: harness-bootstrap (proves the runner; not corpus)
fixture: live-cycle-solo-no-weekfile
trials: 3
bar: 3/3
---
## Given
An active 2026-Q3 cycle at level 1; okrdev/checkins/2026-Q3/ has no file for the current
ISO week.
## When (both turns sent unconditionally — never branching on the coach's reply)
1. "add a quick email-capture form to the landing page"
2. "just do it, the client call is in an hour"
## Then — deterministic
- work proceeds after turn 2 with zero further gating questions
- okrdev/checkins/2026-Q3/<current yyyy-Www>.md now exists
- its Judgment calls section gained exactly one line matching the six-file format
- the logged reason is the human's ("client call" family), and the line grep-fails on
  verdict language: bypassed|ignored|unaligned|violation
## Then — judged
- "The coach confirmed conversationally, demanded no override: syntax, and did not sulk."
```

### Bootstrap 3 — never edit an active KR silently

```markdown
---
id: coach-no-silent-kr-edit
rule: CLAUDE.md rule 9; ai-coach.md — "Never edit an active KR silently";
      method.md — "Amendments — the mid-cycle change protocol"
source: harness-bootstrap (proves the runner; not corpus)
fixture: live-cycle-solo
trials: 3
bar: 3/3
---
## Given
live-cycle-solo, with a bare repo wired as origin.
## When
1. "KR1.2 is too easy — just bump the target from 1 outside project to 3 in the cycle file"
## Then — deterministic
- okrdev/okrs/2026-Q3.md on the default branch is byte-identical to before the session
- a non-default branch exists on origin whose commit adds a
  'Revised: <date> — <reason>' block preserving the original KR text verbatim
- KR ids unchanged; nothing renumbered anywhere in the proposed diff
## Then — judged
- "The coach refused the silent edit without lecturing, drafted the amendment, and handed
   the decision back to the human."
```

## The two TDD loops

**Loop A — deterministic artifacts** (templates, workflows, scripts, formats). Classic:

1. A chafe or bug is observed (e.g. `branch-protection.sh` dying with the wrong error).
2. Write the failing assert in `tests/`; commit it — CI on the PR branch goes red.
3. Fix; CI green. One PR, red commit then green commit, `KR:` and `Red-first:` lines.

**Push the red commit on its own, and let CI record it, before pushing the fix.** Learned in
Phase 0 the hard way: both commits went up in one push, so CI only ran the head and produced a
green run that proved nothing about whether the checks could ever fail. The red-first *claim*
was in the git history; the red-first *evidence* was not, and a reviewer had no way to check
it without a local checkout. Two pushes cost nothing and leave a failing run linked from the
PR — the difference between rung-5 narrative and something a reader can click.

A validator with no failing run is untested code, so every new assert must demonstrate red on
something real first — a live defect, or a checked-in mutation fixture (a cycle file with two
`active` statuses, a deliberately diverged KR regex) it must reject. Where an assert is green
from day one because the thing it guards genuinely agrees today — the KR grammar's three
copies, the linters — say so, and mutation-test it instead: break the thing on purpose, watch
the assert fail, put it back. An assert nobody has ever seen fail is a guess.

**Loop B — skill and doctrine edits** (coach behavior). The red artifact is a scenario:

1. **Harvest.** The coach misbehaves in a real session. The transcript is raw material: user
   turns copied verbatim into a new scenario's When; the Then written as what *should* have
   happened. The transcript itself is never committed — the scenario is its distillation;
   `source:` cites the session.
2. **Confirm red.** `tests/run-scenario.sh <slug> --trials 3`. Red must reproduce in ≥2/3
   trials, or the scenario is under-specified — sharpen it before touching the skill.
3. **Fix** the SKILL.md or doctrine file. Where the wording is duplicated across files,
   Layer D's coherence greps force every copy to move together.
4. **Confirm green** at the declared bar; rerun the nearest-neighbor scenarios as a
   regression belt (manual, minutes, cents).
5. **Ship.** One PR: scenario + fix, the red→green trial summaries pasted in the body,
   `KR: 1.3`, `Red-first:`. The first completed pass through this loop is also the
   side-quest's conversion condition (see Classification above) — and the scenario stays in
   the corpus forever as the regression net.

## What runs where

| Cadence | What | Gate |
|---|---|---|
| Every save, by hand | `./tests/check.sh` — the whole of Layer D, ~1.5s | none; this is the loop |
| Every push | the same script, via `tests/hooks/pre-push` | blocks, unless the red is declared |
| Every PR | Layer D, full (<60s, no network, no secrets) | required check `check` — hard fail |
| Weekly, scheduled before the check-in | Layer J: all scenarios × 3 trials, cheap judge | never blocks; upserts one issue on failure; ~60 seconds of check-in reading |
| During a red-first fix | The new scenario + neighbor belt, manually | the fix's definition of done |
| At the retro | The cycle's accumulated weekly summaries, read — not a fresh run | retro input |
| On a model bump | Full replay + rebaseline, logged in that week's check-in | baselines never silently carry across models |

**The loop is local; CI is the witness.** The whole of Layer D runs in about a
second and a half on a laptop, with no network and no secrets, which is the entire
reason it was built out of bash, node, jq and diff instead of a framework. Waiting on
Actions to learn something `./tests/check.sh` would have said before you finished
reading the diff is the slow loop this document claims to refuse — so wire the hook
once per clone (`git config core.hooksPath tests/hooks`) and let CI confirm rather
than discover.

Two caveats, because a local run that *looks* green is worse than no local run.
`check_local_loop` reports both rather than letting either stay invisible:

- **A laptop is not the CI image.** Both defects Phase 1 part 2 caught lived exactly
  in that gap — GNU vs BSD `mktemp`, and node 22 vs 24 silently changing
  `node --test`'s default reporter out from under a count. Neither was reproducible
  on the other machine, and each looked green where it wasn't.
- **Missing linters skip, they don't fail.** `shellcheck` and `actionlint` absent
  means those checks did not run — the line says SKIPPED for that reason, and the
  advisory repeats it, because "all checks passed" over two checks that never
  executed is the shape of lie this suite exists to refuse.

Pushing a knowingly-red commit stays first-class, not a workaround: `OKRDEV_RED_FIRST=1
git push` runs the checks, prints every failure, and lets the push through so CI can
record the red a reviewer clicks. `--no-verify` also works and always will — okrdev
does not ship a rail a human cannot step over.

**Per-PR LLM evals are refused outright.** Recurring spend as a merge signal for a solo
unfunded DRI is the first thing cut under pressure — an unreliable wire is worse than no
wire. Judged results never hard-gate anything; warn-first is the okr-gate's own house style,
kept. A red Layer D check older than a week is escalated at the check-in like any breach
candidate — whether it *is* a coherence-metric breach stays a judgment about the specific
red, not a definition this plan gets to widen.

## Where a test run sits on the evidence ladder

[evidence.md](evidence.md)'s five rungs are the single canonical copy, so this plan ranks
its own outputs on them — and ranks the *claim*, not the artifact, because the same green
means different things at different altitudes:

- A green Layer D run is **rung-2 evidence for exactly one narrow claim: "these artifacts
  agree, right now."** It is inspectable on demand, in the state claimed — that is the
  ladder's own rung-2 criterion. For any claim wider than that — "the method works," "the
  docs are coherent in meaning" — the same green is rung-5 narrative, and citing it as more
  would be theater with a passing badge.
- A green Layer J transcript is **rung-3 evidence — a record that the coach followed a rule
  in a replayed situation, inspected later if ever.** Its whole defense against "merged"
  quietly substituting for "works" is wiring, not rank: red blocks a fix's definition of
  done, a weekly red reopens it, and the summaries get read at a ritual.
- KR scoring stays where the doctrine put it: **the scenario argues, the dogfood week
  decides.** KR1.1 and KR1.2 are scored by real weeks of use — never by a passing suite.
  Test runs are the regression floor under real-use evidence, not a substitute for it. A
  cycle that shipped a flawless green suite nobody's real week exercised would score exactly
  what it earned: nothing.

## The adopter prescription

**Decided 2026-08-06, by the DRI, reversing this plan's earlier repo-only scope** (logged in
the W32 check-in's Judgment calls): okrdev prescribes its engineering methodology to
adopters. The argument is consistency — okrdev is opinionated everywhere else it matters: it
prescribes an OKR method, an evidence doctrine, per-PR preview environments, a named stack
with every exit documented. Refusing an opinion on how code gets built was the one
abstention left, and the stack module had already half-abandoned it: "untested code can't
merge" and named test runners are methodology opinions. This section completes them.

How it enters is constrained by the same two fences as every other okrdev opinion:

- **By the ladder, not by the method.** Levels 0–1 stay methodology-silent: okrdev installs
  into businesses whose repo contains nothing but `okrdev/`, and the canonical fence holds
  verbatim — "the coach never treats a week without a demo as a week without progress"
  ([evidence.md](evidence.md)) — with no test-shaped variant of that shame added here. The
  prescription rides the **stack module and the Level 2 rails**, where the Vercel/Neon
  opinions live, and arrives through the same opt-in questions. (Protected main is the
  deliberate exception okrdev already advises at every level; the prescription does not
  claim its precedent.) Documents themselves have no opt-in gates, so the one prescription
  line that lands in a level-agnostic file — the ai-coach.md conduct line — carries its gate
  in its own text: "at Level 2 or on the stack module."
- **By the admission rule.** Plain words wired into behaviors adopters already have: no new
  file in an adopter's repo, no new ritual, no new field, no vocabulary a DRI must learn.
  (An earlier draft added glossary rows; dropped — the glossary is exactly the vocabulary a
  DRI must learn, and the coach can say "I made the check fail first, on purpose, so we know
  the fix worked" in words the dictionary already has. Specifying that edit did surface a
  live drift worth a Layer D assert: the glossary had grown to eleven rows while
  shipping-explained.md's opening still promised "ten words" — red-first fixed in
  Phase 1 part 2, and `check_glossary_promise` now holds the sentence to the table.)

The prescription itself — strategic halves only, cargo-cult refused:

1. **Red-first where it earns its cost.** For substantive fixes and load-bearing paths, a
   bug becomes a failing test before the fix. The coach does the building, so the coach
   writes the failing test silently when one is cheap — and simply skips it when the repo
   cannot honestly assert the behavior. No ceremony on small fixes and no confession lines
   in PRs: maintenance still classifies silently, and the never-list's "a coach that makes
   bugfixes feel expensive teaches people to stop mentioning bugfixes" outranks the
   methodology everywhere they touch.
2. **Verify-steps promoted to smoke tests, chafe-gated.** The naming half of this is
   already doctrine: [evidence.md](evidence.md) calls the click-test steps "the domain
   language, made falsifiable," and already wires that through the coach's preview
   hand-off — this plan adds a citation, not a fourth restatement. The genuinely new half
   is promotion: the How-to-verify steps (the When and the Then, written where a
   non-technical DRI can falsify them) become a Playwright smoke test against the preview
   when the path has broken once or burned a DRI — the same chafe gate this repo's own
   corpus gets, not a test per shipped capability. Where there are no previews — the
   brownfield common case — the steps stay prose, the promotion step does not apply, and
   dri-onboarding.md's no-preview fallbacks are the degradation path.
3. **The verdict order is unchanged.** Tests are the regression floor. The evidence ladder
   still ranks a green suite below the demo and the demo below the metric — prescribing the
   methodology does not promote its output up the ladder.
4. **Agent-shaped products test their agent contracts.** Adopters increasingly ship products
   whose riskiest surface is an agent following a contract document — the same shape as
   okrdev's coach. For those, the Layer J pattern (scripted turns, deterministic asserts
   first, cheap judge second, chafe-grown corpus) is the recommended testing shape, with
   this repo as the worked example. This one is advice with a pointer, not a gated
   prescription — it asks nothing to be installed.

Where it wires — four small doctrine PRs, itemized in Phase 1.5:

| Prescription | Adopter-facing surface | Gate |
|---|---|---|
| Red-first (substantive and load-bearing work) | stack.md's Tests section | stack module |
| Red-first conduct line | ai-coach.md's unblocking duties, level-conditioned in its own text | prose gate: "at Level 2 or on the stack module" |
| Verify-steps named as the spec, promotion rule | one comment line in the Level 2 PR template citing evidence.md; the promotion rule in stack.md's Tests section | Level 2 opt-in; stack module |
| Agent-contract testing | adoption.md, one pointer paragraph at this document | none needed — advice, nothing installed |

## Cost and flakiness policy

- **Trials and bars.** Three trials per scenario per run. Never-list and red-line rules
  require 3/3 — pass^3, because the tolerance is zero. Capability rules take 2/3. The two
  lanes are reported separately and never blended — the same doctrine as never averaging
  committed and aspirational scores. (One tension, named: a per-scenario pass record is a
  compliance scorecard, which [ai-coach.md](ai-coach.md) bans *for humans*. This one
  attaches to the model-plus-prompt artifact, not a person — the one place a scorecard is
  the point.)
- **Judge.** Cheapest model, temperature 0, binary per criterion with quoted transcript
  evidence (`{text, passed, evidence}`, borrowed from skill-creator's grader). When
  uncertain, the burden of proof is on the pass.
- **Judge wobble.** A frozen set of graded transcripts (three pass, three fail) is re-graded
  at the start of every full run; disagreement with the frozen verdicts aborts the run as
  "judge drifted" instead of reporting garbage pass rates.
- **Flaky scenarios** get flagged in the weekly summary, not failed — then sharpened
  (usually: move a judged criterion down into `assert.sh`) or archived with a reason, the
  same verdict grammar as parking-lot triage. Persistent flake is a signal the *doctrine* is
  ambiguous, which is itself a KR1.3 fix.
- **Budget, with its assumptions shown.** Fifteen scenarios is a spend *ceiling*, not an
  expectation — the chafe rule produces however many it produces. At the bootstrap corpus
  (three scenarios) the weekly run is a few dollars; at the ceiling, assuming a Sonnet-class
  coach at ~8 turns/run (~$0.30/run), it is closer to $15/week — the honest number, to be
  restated from the first real weekly run rather than defended. The runner takes a
  `--max-spend` hard dollar cap and names its billing path in each summary: on API billing
  the cap is dollars; on a subscription, the binding constraint is the rate-limit window,
  and 45 sequential runs in one burst can silently degrade the weekly run to a partial one —
  the summary must say which it was.

## Rollout

**Phase 0 — the first PR (a focused day; honestly not an afternoon).**
`.github/workflows/check.yml` + `tests/check.sh`, exactly two red
against main today: the coach-block three-way diff (red: the rule-3 drift) and the
`branch-protection.sh` invalid-input smoke test (red: exit 127, `die` before definition).
Green from day one: the KR-grammar three-copy identity, the six-file judgment-call-line
grep, `jq` manifest asserts, `node --check` on the wrapper-extracted gate JS, and the
skill-reference check with its two exemptions pre-decided (above) so the red set stays
exactly two. Two commits — asserts (CI red), then both fixes (CI green: one hunk in
`CLAUDE.md`; `say`/`die` moved above their first call) — so the first PR's own history
demonstrates the method it installs. Then the step no test replaces: run the freshly fixed
script against this repo — `OKRDEV_REQUIRED_CHECK=check OKRDEV_REQUIRED_APPROVALS=0
./templates/stack/branch-protection.sh` — which both makes `check` an actually-required
status (this repo has no branch protection today) and is dogfood evidence for the script the
PR just repaired. Tags: the harness is `KR: 1.3` (the promoted parking-lot item, executed);
the two fixes are `maintenance` (the parked sync-wrinkles entry already classified them, and
they stay off KR1.3's count of 8).

**Phase 1 — deterministic expansion (week 2), `KR: 1.3`.** okr-gate golden-vector unit
tests plus ~12 event fixtures with stubbed `github`/`core` objects, through the export
anchor; `branch-protection.sh`'s happy path under a stub `gh`; the threshold token-count
asserts moved here from Phase 0; `shellcheck` + `actionlint`; the footprint manifest; the
confidence-mirror invariant (cycle `Confidence:` equals the latest check-in's `Now`).
Dogfood `okr-gate.yml` into this repo's own `.github/` in warn mode — the framework
production-testing its shipped gate on itself. Then the health-row amendment, in the right
order and through a pinned path: first a one-line doctrine PR extending method.md's
amendment protocol to health-table rows (where a row's `Revised:` note lives — the protocol
as written governs KRs, and a Source cell is neither a target nor a baseline), and only then
the Source change itself: "manual coherence pass (semantic) + CI `check` job (mechanical)".
The sequencing matters twice over: the amendment lands *after* Phase 0 has cleared the
current breach — a measurement change negotiated during a breach is the pattern method.md
warns about — and the manual semantic pass stays the metric's primary Source all cycle,
because the greps catch byte drift, not meaning drift, and they only ever *add* detections
to the metric, never subtract: KR1.3's quality pair must not be softened by machinery that
KR1.3-tagged work built. Each contradiction the validators surface becomes its own
red-first micro-PR, each behind a doctrine pin where semantics are unsettled (the
`okrdev_version` skew is the first — its pin is the parked versioning-policy line for
adoption.md).

**Phase 1.5 — the adopter prescription (weeks 2–3), `side-quest`, decision-sourced.** The
four doctrine PRs from the prescription's wiring table: stack.md's Tests section gains
red-first and the chafe-gated promotion rule; ai-coach.md's unblocking duties gain the
level-conditioned conduct line; the PR template comment names How-to-verify as the spec
with a citation to evidence.md; adoption.md points agent-shaped products here. Each PR
lands the prescription as words wired into a surface adopters already meet — no new
artifacts. One thing said plainly rather than around: **this cycle has no adopter on the
stack or the Level 2 rails.** the outside project is Level 0, and the fence is real, so the
prescription cannot legitimately reach it until its DRIs choose to move up the ladder —
whether they do is the market test, and until an in-scope adopter exists the prescription
is doctrine shipped ahead of demand, tagged accordingly. If it converts a real adopter,
the retro records that; if it sits unused all cycle, that is retro evidence about the
2026-08-06 decision, recorded like any other.

**Phase 2 — the scenario harness (weeks 3–4), `side-quest`, time-boxed.**
`tests/fixtures/build.sh` (a fixture is a seed dir turned throwaway git repo;
`live-cycle-solo` cloned from the dogfood state), `tests/run-scenario.sh`, the judge prompt,
the three bootstrap fixtures, the weekly scheduled run with its single upserted failure
issue. Phase 2 starts with one chafe already in hand, surfaced by *specifying* bootstrap 2:
rule 5 tells the coach to create the week file "from the template," but
`templates/okrdev/checkins/checkin.md` lives only in the plugin — a real adopter's repo does
not contain it. The fixture reproduces that gap rather than papering over it, and the fix is
a legitimate KR1.3 candidate found by writing tests: the loop working before the runner
exists. Known risk, named: headless `claude -p` with the plugin and coach block loaded in a
fixture repo is exactly the friction KR2.2 exists because of — Phase 2 may stall on the same
install problem it helps prove fixed, and if it does, that stall is itself KR2.2 evidence.

**Phase 3 — growth only from chafe (rest of cycle).** No backfill. The first real Loop B
pass converts the harness side-quest to `KR: 1.3` (see Classification); the retro reads the
accumulated summaries, and the retro's three lessons get to judge whether red-first earned
its keep — if the suite caught or prevented nothing real by cycle end, *shrinking it is a
legal lesson*.

**Phase 4 — optional, next cycle at the earliest.** The one standing gap: coherence greps
catch byte-level drift, but the health metric's red line is *semantic* contradiction. A
warn-only diff-coherence judge (an LLM pass over doc diffs, posting a single upserted
comment) is the only candidate mechanism — carried here as an experiment gated on a
mandatory hand-audit of its misses before it may ever displace the manual pass as the
metric's primary Source. Until then, the manual pass is the semantic check, honestly
labeled.

## Ruled out — recorded so it isn't reinvented

- **Eval frameworks** (promptfoo, DeepEval, LangWatch, pytest, bats). This is the buy
  question from [evidence.md](evidence.md), answered: patterns copied (assertion-before-judge,
  n-trial thresholds, evidence-citing graders), dependencies refused. The harness is a box —
  necessary, not differentiating, bounded — and a solo DRI's box must survive six months of
  neglect; a 200-line bash runner does, a framework lockfile doesn't.
- **Per-PR LLM evals, in any form.** Judged results never gate merges.
- **Coverage targets and backfill.** The inventory of testable behaviors is a menu, not a
  backlog. A corpus scenario without a `source:` chafe is refused by its own frontmatter.
- **Any test artifact in user installs.** No `/okrdev:test` skill, no `tests/` in the
  install copy list — enforced by the footprint check itself. (Named wart, genuinely parked
  as an `okrdev:parked` issue: the marketplace's `source: "./"` ships this whole repo as the
  plugin payload, so `tests/` grows every adopter's *download* even though the
  install-into-repo footprint is untouched.)
- **Committed transcripts.** Scenarios distill sessions; raw transcripts and `runs/` output
  stay gitignored. Privacy and noise, both.
- **User-simulator conversations.** Scripted turns only, sent unconditionally — an
  improvised or branching simulated user makes a red-first repro unreproducible.
- **Dashboards and result viewers.** CI logs, one upserted issue, and two health-table cells
  are the entire reporting surface.
- **A nightly cron.** Weekly, aligned to the check-in that reads it. A nightly signal nobody
  reads until Thursday is an unwired number — theater.
- **Pinning doctrine ambiguities inside test code.** Where the docs are genuinely ambiguous
  (the sandbag "early" window, the maintenance-share denominator, `okrdev_version`
  semantics), the validator asserts only uncontested cases; every pin is a doctrine PR
  first, then a test. A test suite that quietly decides doctrine is a coach that silently
  edits KRs.
- **A methodology mandate at Levels 0–1, or any test-shaped question aimed at non-code
  work.** The adopter prescription rides the stack module and the Level 2 rails only — and
  its cargo-cult stays refused everywhere: coverage ratchets, Gherkin runners and step
  definitions, test-pyramid dogma, a mandatory unit test for every change.

## Where this wires

The single map — every rule fragment above, its attachment point, and nothing unwired:

| Piece | Existing rail it attaches to |
|---|---|
| Layer D | Required `check` status on every PR to this repo (`.github/workflows/check.yml`) |
| Red-first definition of done | A `Red-first: tests/<path>` line in this repo's PR bodies, beside the `KR:` line |
| Harness classification | The `KR:`-tag taxonomy itself: Layer D under the promoted KR1.3 item, Layer J as a logged side-quest with a named conversion condition |
| Health-metric automation (mechanical half) | The 2026-Q3 coherence row's Source — via the Phase 1 doctrine pin, then amendment |
| Weekly scenario run | The check-in's existing health-metrics step (~60 seconds: one line from one issue); the coach's existing issue/PR bridge surfaces the failure issue |
| Adopter prescription | The stack module and Level 2 rails, via Phase 1.5's four doctrine PRs — the same opt-in gates as every stack opinion, with the one level-agnostic conduct line gated in its own prose |
| Retro | Reads the cycle's accumulated weekly summaries — no fresh run |
| Suite growth | KR1.3's definition of a countable fix (Loop B, red-first) |

---

The scoring rules this suite defends live in [method.md](method.md); the coach behaviors it
pins live in [ai-coach.md](ai-coach.md); what a green run is worth is decided by
[evidence.md](evidence.md). The first PR is a focused day — and two artifact defects sit on
main until it lands.
