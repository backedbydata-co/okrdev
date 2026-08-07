# The install footprint — what `/okrdev:install` writes, enumerated

This is the machine-readable half of the 2026-Q3 cycle's **Install footprint** health metric
(`okrdev/okrs/2026-Q3.md`), whose red line is:

> install writes anything beyond `okrdev/` + the marked CLAUDE.md block (+ opt-in `.github/`
> at L2)

`tests/check.sh`'s `check_footprint_manifest` reads this file. It fails if
`skills/install/SKILL.md` names a template this manifest doesn't list, if this manifest lists
a template that doesn't exist, or if any destination falls outside the red line. The manifest
is the assertion; the prose is for whoever has to change it.

Plugin *acquisition* is outside this manifest by construction: `install.sh` (the headless
path, `docs/adoption.md` "Headless install") writes machine-level state under `~/.claude` and
nothing in any repo. The red line governs what `/okrdev:install` writes into *your* repo,
which begins only after the plugin exists.

The metric's stated Source is `git status` after a fresh install. That is a real limit, not a
formality, and the second table exists because of it: **four of install's writes leave no
trace in a working tree at all.** A manifest that listed only files would let those four grow
unwatched while the metric reported green. They are listed here as explicitly out of scope of
the automated check, so the omission is a recorded decision rather than an oversight.

## Files installed, per level

Every destination below is inside the red line. `templates/` paths are the plugin's; every
other path is relative to the target repo root.

| Level | Destination in the target repo | Source | Notes |
|---|---|---|---|
| 0 | `okrdev/config.md` | `templates/okrdev/config.md` | `level: 0`; backstop asked |
| 0 | `okrdev/PARKING_LOT.md` | `templates/okrdev/PARKING_LOT.md` | |
| 0 | `CLAUDE.md` (marked block only) | text embedded in `skills/install/SKILL.md` | minimal L0 block |
| 1 | `okrdev/MISSION.md` | `templates/okrdev/MISSION.md` | drafted with the human, not left as placeholder |
| 1 | `okrdev/LESSONS.md` | `templates/okrdev/LESSONS.md` | starts empty; retros append |
| 1 | `CLAUDE.md` (marked block only) | `templates/CLAUDE-okrdev.md` | replaces L0's block verbatim |
| 1 | `okrdev/config.md` | — | edited, not created: `level: 1`, `cycle_length` |
| 2 | `.github/pull_request_template.md` | `templates/github/pull_request_template.md` | separate opt-in |
| 2 | `.github/workflows/okr-gate.yml` | `templates/github/workflows/okr-gate.yml` | separate opt-in |
| 2 | `.github/CODEOWNERS` | `templates/github/CODEOWNERS` | separate opt-in; placeholders replaced |
| 2 | `okrdev/config.md` | — | edited, not created: `level: 2`, `strict_gate` |

Eight distinct destination paths. `okrdev/config.md` and `CLAUDE.md` appear more than once
because later levels edit what earlier ones wrote — that is the ladder working, and it is why
uninstall is a deletion rather than an archaeology project.

### Templates that exist but install never copies

Listed so their absence from the table above reads as deliberate:

| Template | Who writes it into a repo |
|---|---|
| `templates/okrdev/okrs/cycle.md` | `/okrdev:plan`, at the first planning session |
| `templates/okrdev/checkins/checkin.md` | `/okrdev:checkin`, at the first check-in |
| `templates/github/workflows/ci.yml` | the stack module, by hand from `templates/stack/README.md` |
| `templates/github/workflows/neon-cleanup.yml` | the stack module, by hand |
| `templates/stack/branch-protection.sh` | nothing — it is *run*, not copied |
| `templates/stack/README.md` | nothing — install points the human at it to read |

The first two are the load-bearing ones. `docs/adoption.md` used to list the cycle file under
Level 1's "What installs", contradicting `skills/install/SKILL.md`'s "Do **not** create a
cycle file. That's `/okrdev:plan`'s job." The DRI ruled adoption.md wrong on 2026-08-06; this
manifest records the ruling in the form a check can read.

## The four writes this check cannot see

Not covered by the automated check, and not coverable by its stated Source — `git status`
cannot see any of them. Recorded here rather than rounded to zero:

| Write | Where | When |
|---|---|---|
| `gh label create okrdev:parked` | the GitHub repo's labels | every level, folded into the backstop question |
| `gh variable set OKRDEV_STRICT_GATE` | the repo's Actions variables | Level 2, only if `strict_gate` is flipped to `true` |
| branch-protection ruleset (`repos/<repo>/rulesets`) | the GitHub repo's rules | Level 2, if the branch-protection script is run |
| merge policy (`PATCH repos/<repo>`) | the repo's merge settings — squash-only, delete-on-merge, auto-merge | Level 2, same script, same run |

The fourth is the one worth naming twice: `templates/stack/branch-protection.sh` changes
repository merge settings as a side effect of protecting the branch. It is documented in the
script and in `docs/adoption.md`, and it is still the write most likely to surprise someone,
because they asked for branch protection and got a merge-strategy opinion in the same
command.

All four are reversible and all four are documented in `docs/adoption.md`'s uninstall
procedure — which is the honest defense here, given that no check watches them.
