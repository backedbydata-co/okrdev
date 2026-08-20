# Changelog

The plugin's version lives in `.claude-plugin/plugin.json`. An adopter repo
records the version it installed as the `okrdev_version` marker in its
`okrdev/config.md` — marker semantics are in docs/adoption.md. Pre-1.0:
minor bumps may change doctrine, not just add to it.

## Unreleased

## 0.8.7 — 2026-08-18

**The Claude Code install instructions did not work in the Claude Code desktop app.**
Reported from a real session: typing the documented `/plugin marketplace add` into the
desktop app answers `/plugin isn't available in this environment`. `/plugin` opens an
interactive panel that exists only in the terminal CLI. The Quickstart had said "In the
desktop app (Mac/Windows), open your project folder and type into the chat" directly above
it — so the one path an adopter was steered to was the one that could not work. The "no
terminal required" promise beside it was never the problem and survives: the fix is a
command that *does* run in a desktop code session, not a retreat to the terminal.

- `README.md` and `site/index.html` now lead Claude Code with **one paste** — a prompt that
  carries the chained plugin-CLI command,
  `claude plugin marketplace add backedbydata-co/okrdev && claude plugin install okrdev@okrdev`,
  and asks the session to run it. Both halves are idempotent and report what is already
  installed rather than failing, so the paste is safe to re-run
- The prompt **carries the literal command rather than describing it.** A pure
  natural-language ask ("install the okrdev plugin") would depend on the agent knowing the
  plugin CLI and the `okrdev@okrdev` marketplace-qualified syntax, and an agent that guesses
  reaches for `/plugin` — the exact path this release exists to fix. One paste, no inference
- **These are shell commands, but they do not require a terminal.** Pasted into a Claude
  Code session — the desktop app included — the agent runs them for you. The docs say so
  explicitly, because "shell command" reads as "open a terminal" to exactly the adopter
  who was promised they would not have to. The real boundary is *code session vs. chat
  session*: a Claude chat session has no shell, a Claude Code session has one wherever it
  runs, and that is the distinction the copy now draws
- **Codex gets the same shape**, `codex plugin marketplace add backedbydata-co/okrdev &&
  codex plugin add okrdev@okrdev`, so the two CLI paths read as one idea rather than two
  dialects. Every install path on the page is now one action: one click, or one paste
- **The `/plugin` explanation is off the landing page and out of the Quickstart.** It was a
  paragraph explaining why we *don't* do something — the most expensive kind of copy on a
  page whose job is to get someone installed. The route and its exact error string stay in
  [docs/adoption.md](docs/adoption.md), which is where someone who hit the error goes
  looking; the README links there. Registering a third-party marketplace is a plugin-CLI
  command however you invoke it — the desktop plugin browser lists plugins from marketplaces
  *already configured* and does not add new ones
- **The Quickstart is now a banner over two cards.** The one-click path runs full width
  across the top; Claude Code and Codex sit below at half width each. The featured path is
  not a card stretched to fit — a card has one content column, and one column at 1048px is a
  thin line of prose beside a lonely button. It is a banner with its own internal grid: a
  headline zone, a rule-separated action rail holding the button and its next step, and a
  full-bleed fact strip along the bottom carrying the claims that used to be the tail of a
  sentence
- **Row 2's alignment is now structural, not lucky.** The old three-column row measured zero
  dead space at 1280px and 62px of it at 1000px: bottom-aligned cards only sit flush when
  their prose happens to wrap to the same line count at that exact width. The two cards now
  ride the parent grid's row tracks via `grid-template-rows: subgrid`, so the code blocks
  start on the same line whatever the prose above them does — including after the next copy
  edit. Verified 0px prose-to-action gap at all of 1440/1280/1200/1100/1060/1041/1040/1000/
  960/930/911/905/901/900/880/768/600/375, with a `@supports` fallback to the old behaviour

**A second claim expired quietly, and nothing noticed.** `docs/adoption.md` and
`install.sh` both stated that marketplace registration "has no shell equivalent — it exists
only inside the `/plugin` dialog." True when written; false as of `claude 2.1.226`, which
ships `claude plugin marketplace add`. Both now say so.

- `install.sh` needed **no behaviour change**: it has always probed for the shell subcommand
  and preferred it over writing state itself, so the day the subcommand shipped it started
  taking the official path. The speculative branch was right. Only its comments were stale
- `install.sh` is still worth running — one command instead of two, idempotent, re-points a
  local checkout at the canonical repo — but it is no longer the *only* headless route, and
  `docs/adoption.md` no longer implies it is

Verified against `claude 2.1.226`: `claude plugin marketplace add --help` and
`claude plugin install --help` both resolve, and okrdev shows as `okrdev@okrdev`, user scope,
enabled, with its skills live in a desktop session and no `.claude/` in the repo to explain
it — which is the evidence that a shell-side install reaches the desktop app.

## 0.8.6 — 2026-08-18

**The acquisition path leads with the button it now has.** The ChatGPT listing went live
in 0.8.4 and nothing pointed at it. `README.md` and `site/index.html` both opened on
`/plugin marketplace add`, so the shortest install okrdev has ever had — press **Install
plugin**, then `@okrdev` — was reachable only by someone who already knew it existed.

- The landing page's hero CTA is the directory listing, and the install section is three
  paths with the one-click one featured rather than one code block that assumed a terminal
- `README.md`'s Quickstart opens on the listing link, with Claude Code and the Codex CLI
  kept as the two-command paths under "prefer the command line?"
- `docs/codex.md` gains the listing as its lead install path, and states the difference the
  two paths actually have: the listing serves the last uploaded zip and can sit behind `main`,
  while `marketplace add` fetches the branch. Its "verified, not assumed" claim is rescoped to
  the CLI — a portal install was never derived from `codex-cli`, and what it writes to
  `~/.codex/config.toml` is now listed as unverified rather than silently covered by a table
  that describes a different mechanism
- The listing URL is recorded in `docs/codex-submission.md`, next to the status line,
  because two files now hard-code an opaque portal id and a re-listing mints a new one.
  Deliberately not a table row: `check_starter_prompts` reads any row whose first cell is
  a lone backticked span as a starter prompt, so a URL row would have been scanned as one
- Two fixes to what 0.8.4 and 0.8.5 left behind: the README promised "Five" starter
  prompts while listing six — the sixth arrived in 0.8.4 and the prose did not follow —
  and "Neither agent?" no longer reads right in a section that now names three

**No re-submission.** The OpenAI listing is a snapshot of an uploaded zip, not a mirror of
`main`, so it stays at 0.8.4 until someone uploads again. This bump is for the adopter-facing
marker, which is what the every-shipped-change rule is about.

## 0.8.5 — 2026-08-18

**The submission materials, corrected against the portal that rejected them.**
`docs/codex-submission.md` documented a Repository field and a path-within-repository
field that do not exist on the skills-only path. It is a **zip upload**, and the
listing is a snapshot of the artifact you upload rather than a mirror of `main` — so
unlike the Claude directory, every update is a fresh upload rather than a push. The
doc also claimed the portal substitutes its own developer name when the manifest
disagrees with the verified identity. It does not: it ships what the manifest gives
it, which is why a mismatch survives upload and surfaces at human review instead.

- The doc now records what the portal validates at upload — the 30-character
  `shortDescription` ceiling, the required square `logo` and `composerIcon`, the
  strict frontmatter parse — and that validation runs *before* the skill scan and
  names the offending file and line
- It also records that a full skill scan can take **hours**. One skill sat pending
  long enough to look broken across four uploads and three plugin records, and was
  fine. Three controlled probes went looking for a defect that did not exist; the
  note exists so the next submission waits instead of bisecting
- Every date in this release and the last was written as 2026-08-10 and is now
  2026-08-18, the day the work actually happened

## 0.8.4 — 2026-08-18

**Listed on the OpenAI plugin directory.** Submitted and approved — okrdev now has a
second directory listing, and `KR2.2`'s argument for the Codex port is realised. This
is the artifact that shipped.

**0.8.1 through 0.8.3 are deliberately skipped.** Each went to the portal and was
superseded by what the portal taught us on arrival: that the developer name must
match the verified legal identity, that `shortDescription` has a 30-character
ceiling, and that `interface.logo` and `interface.composerIcon` are required and
must be square. Re-issuing *different* bytes under a version the portal had already
ingested is precisely the lie the every-change-bumps rule exists to prevent, so those
three numbers are burned rather than quietly reused. 0.8.4 is the one that shipped,
and the rule is why you can tell which one that is.

**A colon that a lenient parser forgave.** `skills/triage/SKILL.md` carried
`to a decision: promote` in its unquoted `description` — a colon-space closes a
plain YAML scalar, so a strict parser reads a nested mapping and fails the file.
Claude Code's loader accepted it, so it installed cleanly, ran correctly, and
shipped to the Claude directory without a murmur. OpenAI's submission portal
rejected the upload outright: *Malformed skill frontmatter YAML,
`skills/triage/SKILL.md:3`*. The description is reworded, not quoted — the other
seven are plain scalars and one quoted straggler is the drift this repo keeps
paying for.

- `check_skill_frontmatter` is the 39th check, and the gap it closes is
  embarrassing in the useful way: the suite had **no YAML parser anywhere**, and
  `check_skill_references` only ever asserted that a `SKILL.md` *exists*. Every
  skill's frontmatter is now validated as a flat mapping of single-line scalars —
  unquoted values may not contain `": "`, end in `:`, open with a YAML indicator,
  or hide a ` #` comment; quoted ones must close; `name` must match its directory
- Deliberately stricter than YAML. There is no parser to lean on (this repo runs
  on `jq` and `node`, and taking a dependency to validate two keys is the wrong
  trade), so the validator refuses anything it cannot prove a strict parser will
  accept. A false alarm costs a pair of quotes; a miss costs a rejected submission
- Verified red-first against the shipped defect, and cross-checked against a real
  YAML parser in both directions — it flags exactly the file Psych flags and
  passes exactly the seven it passes
- **A sixth starter prompt, and a home for the list.** "what should I work on
  today?" was typed straight into the portal, where nothing in this repo could see
  it. It is now in the README block, in `skills/coach/SKILL.md`'s triggers so it
  routes somewhere instead of nowhere, and in a table in `docs/codex-submission.md`
  that `check_starter_prompts` diffs against the README
- **`check_starter_prompts` could never have caught the thing it was written for.**
  Its `missing` array was declared, tested, and never appended to — the drift
  branch was unreachable, so the check only ever counted README prompts and
  validated the lone `defaultPrompt`. The manifest has no field for the other five,
  which is why the portal's list needed a repo-side source of truth before the
  branch could mean anything
- `check_listing_copy` is new: `shortDescription` must be non-empty and ≤30
  characters, the ceiling the portal enforces and rejected a 39-character subtitle
  against — mid-submission, by hand, after the manifest had passed every check here
  and been uploaded twice. Only the limit we have actually observed is encoded;
  inventing ceilings we have not seen fail is how a check starts lying
- The same check now requires `logo` and `composerIcon` to be **present** and
  square. `check_plugin_manifests` validated only assets that were *referenced* —
  its `// empty` emits nothing for an absent field, so a manifest that dropped one
  entirely passed green, which is how the field turned out to be mandatory only
  after an upload was rejected for it
- Squareness reads the root `<svg>` element, not the file. A line-oriented scan
  finds the inner `<rect>` first — 512×512 in `assets/logo.svg`, the right answer
  by coincidence and a wrong one the moment that rect is resized. The root carries
  no width/height at all (*"the directory scales this"*), so `viewBox` is the real
  source, and XML comments are stripped before parsing because this file has
  already broken once on comment handling and says so in its own comment
- `interface.developerName` is now the verified legal name, "Alexander Ashley
  Chisholm". The portal's field is explicit — *must match your verified legal name
  or business name* — and it does **not** substitute its own value when you
  disagree with it, so a mismatch survives upload and surfaces at human review
  instead. `author.name` stays "Alex Chisholm": that is the npm-style package
  author, it sits in the shared-identity projection across both manifests, and the
  directory's legal-identity requirement has no claim on it

## 0.8.0 — 2026-08-09

**The stack module gains its feature-flags row.** `docs/stack.md` prescribes
flags as code: every flag a typed function in `flags.ts` (Vercel's open-source,
provider-agnostic Flags SDK) with its default committed beside it, created,
changed, and deleted only by PR — plus one opt-in, dormant, kill-only brake (a
Vercel Global Config kill list) for blast-radius paths, held to a same-day
reconcile-by-PR discipline. Split testing is deliberately not wired below a
printed traffic floor; the row names the buy-the-stats-engine upgrade (a Flags
SDK provider adapter) instead of hand-rolling verdict arithmetic. Shipped in
#15 one commit after 0.7.0 cut the every-change-bumps rule; this release is
that rule applied to its first straggler.

## 0.7.0 — 2026-08-08

**Every shipped change now bumps the version.** The old rule exempted docs-only
changes and `install.sh`, on the correct reasoning that neither has an installed
copy in an adopter's repo that could fall behind. What changed is that the
version acquired a second consumer: listed in a plugin directory, it is the
distribution cache key, and the only signal that there is anything new to fetch.
Seven of the eight skills read `docs/` at runtime, so a docs fix is a behaviour
fix. Measured rather than assumed — a docs-only change at an unchanged version
is still retrievable by an explicit re-install, but nothing tells anyone to run
one.

- The empty-upgrade-prompt problem the old rule avoided is now solved in the
  upgrade path instead of in the version: `/okrdev:install` reports "this
  release changed no scaffolding, nothing to apply" rather than presenting an
  empty diff
- `docs/adoption.md` keeps the original rule and its reasoning verbatim, so the
  next reader sees what changed and why rather than only the conclusion

## 0.6.0 — 2026-08-08

**okrdev runs on Codex as well as Claude Code.** The coach block now installs
into whichever file the host agent reads — `CLAUDE.md` or `AGENTS.md` — and
nothing else about the install forks. `templates/CLAUDE-okrdev.md` carries no
platform tokens, so the block itself is unchanged; only its destination is a
parameter. Verified end-to-end against the real `codex` CLI, not against docs:
`codex plugin marketplace add` + `codex plugin add` installs and enables all
eight skills. Notes in `docs/codex.md`.

- The install skill resolves the instructions file, with existing markers
  winning over the host default, and refuses to write both files
- The install-footprint health metric names its destination by role rather than
  by filename (`okrdev/okrs/2026-Q3.md`, amended with a `Revised:` block)
- `.codex-plugin/plugin.json` — the Codex/OpenAI directory manifest, sharing
  the `skills/` tree and identity with the Claude manifest
- `assets/logo.svg` and `assets/composer-icon.svg`; the cursor underscore is
  dropped from the brand
- Directory-listing metadata on the Claude manifest: license, repository,
  homepage, keywords (the plugin was submitted to the Claude plugin directory
  on 2026-08-08)
- The plugin payload no longer ships a 6 MB generated PDF: 6.5 MB → 0.64 MB
- `PRIVACY.md`; the quickstart clones to `mktemp -d` rather than a fixed path
  in `$HOME` it then `rm -rf`s
- Headless install path: `install.sh` registers the marketplace and installs
  the plugin with no `/plugin` dialog (#18)
- The adopter prescription's fifth item: run the checks locally, with its
  local/CI parity warning (#21, #22)
- Open-source readiness: `.gitignore`, community health files, this
  changelog; outside-adopter references anonymized in the dogfood ledger

## 0.5.0 — 2026-08-06

- The adopter prescription (Phase 1.5), wired into the four surfaces
  adopters already meet: stack.md's Tests section, ai-coach.md's conduct
  line, the PR-template comment, adoption.md's pointer (#17)

## 0.4.0 — 2026-08-06

- Local test loop: opt-in pre-push hook (`tests/hooks/pre-push`) plus the
  local/CI parity advisory (#14)
- okrdev's own deterministic check suite, red-first on live defects — among
  them a shell injection in a shipped workflow template and a silently-dead
  script: Phase 0 (#9), Phase 1 (#10, #12), behind the required `check` job
- Testing doctrine: docs/testing.md (#7)

## 0.3.0 — 2026-08-05

- Evidence doctrine: docs/evidence.md — demos, domain words, and what counts
  as proof (#6)
- Live-coached sessions playbook: docs/live-coached-sessions.md (#3, #4, #5)

## 0.2.0 — 2026-07-30

- State writes redesigned for a protected main: issues as the capture inbox,
  batched ledger writes, protect-main as shipped best practice (#2)

## 0.1.0 — 2026-07-13

- Initial release: the method (docs/), eight coach skills, the install
  templates, the optional stack module, MANIFESTO.md
