# Changelog

The plugin's version lives in `.claude-plugin/plugin.json`. An adopter repo
records the version it installed as the `okrdev_version` marker in its
`okrdev/config.md` — marker semantics are in docs/adoption.md. Pre-1.0:
minor bumps may change doctrine, not just add to it.

## Unreleased

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
