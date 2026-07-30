---
name: install
description: Install, upgrade, or level-up okrdev in the current repo. Walks the adoption ladder — Level 0 parking lot, Level 1 method, Level 2 collaboration rails, optional stack module — creating okrdev/ files from templates, appending the marked CLAUDE.md coach block, and merging (never overwriting) anything that already exists. Use when someone says "install okrdev", "set up okrdev", "add okrdev to this repo", "upgrade okrdev", "move us to Level 1/2", or asks how to get started with okrdev.
---

# Install okrdev

You are installing okrdev into the repo the user is working in (the "target repo"). Paths
starting with `templates/` refer to files shipped with this plugin; every other path is
relative to the target repo root. If you can't locate the plugin's templates directory (skills
copied without templates, or a surface that can't reach plugin files), don't stop: recreate the
files from the canonical formats embedded in the skills and docs — the parking-lot format in
`/okrdev:park`, the check-in skeleton in `/okrdev:checkin`, the config frontmatter in step 4
below, and the coach blocks quoted in this file.

Two rules govern everything below:

- **Start at the lowest level that delivers value.** Level 0 works standalone and takes ten
  minutes. Never install a level the user didn't ask for — unused ceremony is how frameworks
  get deleted by week three.
- **Never overwrite an existing file.** Every collision gets a proposed merge and a question,
  not a silent clobber.

## Procedure

1. **Detect state.** In the target repo, check:
   - Is this a git repo? (`git rev-parse --is-inside-work-tree`)
   - Does `okrdev/` exist? Does `okrdev/config.md` carry `okrdev_version` in its frontmatter?
   - Does `CLAUDE.md` contain `<!-- okrdev:start -->`?
   - Do `.github/pull_request_template.md`, `.github/CODEOWNERS`, or
     `.github/workflows/okr-gate.yml` already exist?

   Classify the state:
   - **Fresh** — no okrdev traces. Continue at step 2.
   - **Partial** — some okrdev files but no version marker (hand-rolled or interrupted
     install). Fill the gaps using the steps below, skip anything that exists, and add the
     version marker and any missing frontmatter keys to `okrdev/config.md`.
   - **Existing** — version marker present. If the user wants a *higher level*, run only the
     steps for the new level and update `level:` in `okrdev/config.md`. Otherwise treat it as
     an upgrade — see "Upgrading" below.

2. **Not a git repo?** Offer to `git init`. okrdev's storage is git-native — versioned,
   reviewable by PR, greppable by agents — so a repo is required. If this is not a software
   business, say plainly: the repo can contain nothing but `okrdev/`; it's just the ledger.
   Details in `docs/adoption.md`.

3. **Walk the ladder.** Present it and ask where to start. Default to Level 0 unless the user
   clearly wants more. Each level assumes the ones below it.

   | Level | What it adds | Time |
   |-------|--------------|------|
   | 0 — Parking lot | Idea capture + weekly triage. Nothing else. | 10 minutes |
   | 1 — The method | Mission, cycle OKRs, check-ins, retros. | One planning session |
   | 2 — Collaboration rails | `KR:` tags on PRs, okr-gate, CODEOWNERS, branch protection. | An afternoon |
   | Stack module | Vercel + Neon AI-first environment. | A day. Greenfield only |

   If the user is unsure, recommend Level 0 or 1: Level 0 to feel the capture habit first,
   Level 1 if they already want objectives this week. Do not pitch Level 2 or the stack —
   answer if asked.

   One piece of advice applies at every level: protect the default branch — PR required
   before merge, squash-only, no force pushes. That's repo best practice, not a Level 2
   commitment, and okrdev runs happily behind it: captures become issues (no commits at
   all), and batched state writes become roughly one small state PR a week instead of a
   direct commit. Be honest about the plan wall: on private repos, branch protection needs
   a paid GitHub plan; public repos get it free.

4. **Level 0 — parking lot.**
   - Create `okrdev/config.md` from `templates/okrdev/config.md`. Set `level: 0`. Ask one
     question: who is the backstop — the human to call when the DRI and the coach are both
     stuck? Leave the other frontmatter defaults (`cycle_length: quarterly`,
     `checkin_cadence: weekly`, `side_quest_box_hours_per_week: 4`, `strict_gate: false`)
     in place. They're inert at Level 0, but keeping them means moving up later is a flip of
     `level:`, not a re-interview.
   - Create `okrdev/PARKING_LOT.md` from `templates/okrdev/PARKING_LOT.md`.
   - When `gh` is authed and the repo's remote is GitHub, fold one opt-out into the backstop
     question — "I'll also add the `okrdev:parked` label so ideas can be parked as issues,
     unless you'd rather not" — then create it:
     `gh label create okrdev:parked --color F9D71C --description "okrdev parking-lot inbox — triaged weekly, then closed"`.
     That gives `/okrdev:park` its primary path: zero commits, and capture from a phone or by
     a collaborator straight from the GitHub UI, no Claude session needed. No `gh`, no
     remote, or the remote isn't GitHub? Skip silently — the Captured section works
     everywhere. This applies at every level; don't make it a ceremony of its own.
   - Add the **minimal Level 0 coach block** to `CLAUDE.md`, following the collision rules in
     step 8. Use exactly this text:

     ```markdown
     <!-- okrdev:start -->
     ## okrdev coach

     This repo runs okrdev at Level 0 — parking lot only (see `okrdev/config.md`). No active
     cycle yet.

     Rules for every session:

     1. **Park new ideas by default.** A mid-session idea gets captured in ten seconds as an
        `okrdev:parked` issue — or one line in the Captured section of
        `okrdev/PARKING_LOT.md` (date, idea, who, energy high/med/low, effort S/M/L) when
        offline or the remote isn't GitHub. Then back to what you were doing.
     2. **Nothing parked — issue or Captured line — gets worked on.** Ever. Triage first
        (`/okrdev:triage`): promote, archive, or time-box it as a side-quest.
     3. **Side-quests get a time-box before they start**, logged in the Side quests section
        of the parking lot.
     4. When the team is ready to set objectives, suggest `/okrdev:install` to move to
        Level 1, then `/okrdev:plan`. Installing Level 1 replaces this block.
     <!-- okrdev:end -->
     ```

5. **Level 1 — the method.** Everything from Level 0 (create whatever is missing), plus:
   - `okrdev/MISSION.md` from `templates/okrdev/MISSION.md` — and don't leave it as
     placeholder text. Draft it with the human now, in three questions: what does this
     business or project exist to do? What's the current strategy, in a paragraph?
     Optionally, what are the 2–3 strategic bets this year? Keep it short. Planning reads
     this file first, and the coach can't answer "aligned to what?" without it.
   - `okrdev/LESSONS.md` from `templates/okrdev/LESSONS.md`. It starts empty; retros append.
   - Replace the coach block content between the markers with the full canonical block from
     `templates/CLAUDE-okrdev.md`, verbatim.
   - In `okrdev/config.md`: set `level: 1`; ask about `cycle_length` — quarterly is the
     default and fits most businesses; six-week suits AI-speed projects that would go stale
     waiting a quarter.
   - Do **not** create a cycle file. That's `/okrdev:plan`'s job, and it deserves a real
     planning session, not the tail end of an install.

6. **Brownfield scan (offer it whenever the target repo has an existing codebase).** Offer to
   scan the repo so planning starts from a straw man instead of a blank page:
   - Read the README and any docs or roadmap files.
   - `git log --oneline --since="90 days ago"` for the actual workstreams.
   - `gh issue list --state open` when `gh` is available.

   Summarize in chat: what the product appears to do, where recent effort went, recurring
   pain. Offer to park any concrete ideas the scan surfaced (one `okrdev:parked` issue each,
   or one line each into the Captured section of `okrdev/PARKING_LOT.md` when there's no
   GitHub remote). Then suggest running `/okrdev:plan` while the
   findings are fresh. Planning goes faster as an argument with a draft than as a staring
   contest with an empty page.

7. **Level 2 — collaboration rails.** Requires Level 1: the rails tag work against KRs, so
   the KRs have to exist first. Each item is a **separate, explicit opt-in question** — never
   bundle them, never install one uninvited:

   a. **PR template** → copy `templates/github/pull_request_template.md` to
      `.github/pull_request_template.md`. If one already exists, show a proposed merge —
      their sections plus the `KR:` line, the how-to-verify section, and the risk
      checklist — and ask before writing.
   b. **okr-gate** → copy `templates/github/workflows/okr-gate.yml` to
      `.github/workflows/okr-gate.yml`. Explain what they're opting into: warn-by-default —
      a comment and a `needs-kr` label on PRs missing a `KR:` line, never a blocked merge.
      Strict mode is a separate later opt-in (a repo variable), and even then a
      human-applied `okr-override` label passes the gate; the coach logs its use. Nothing
      in okrdev is human-unoverridable.
   c. **CODEOWNERS** → copy `templates/github/CODEOWNERS` to `.github/CODEOWNERS`, then
      replace the placeholder reviewers with real usernames for the risky paths this repo
      actually has (migrations, auth config, payment code). If a CODEOWNERS exists, propose
      a merge and ask.
   d. **Branch protection** → offer to run `templates/stack/branch-protection.sh` (requires
      an authed `gh`). If asked how okrdev's own writes survive a protected main: state PRs
      are the standard path — the coach batches ledger writes by ritual and opens one small
      PR per triage or check-in, merged immediately. The script keeps an actor-bypass as an
      opt-in convenience, commented out by default; it is not the assumed setup. Be honest
      about plan requirements: on private repos, branch protection and CODEOWNERS
      enforcement need a paid GitHub plan; public repos get them free. If the plan can't
      support it, install CODEOWNERS anyway — it still routes review requests — and state
      exactly what's missing teeth.

   Set `level: 2` in `okrdev/config.md`. Ask about `strict_gate` but recommend leaving it
   `false` until the team has lived with warn mode for a full cycle. If they ever flip it to
   `true`, set both halves together: the config key (the recorded decision) and the repo
   variable that actually controls the gate — `gh variable set OKRDEV_STRICT_GATE --body true`.
   One without the other is a gate that says one thing and does another.

8. **CLAUDE.md collision rules** (apply at every level):
   - No `CLAUDE.md` → create one containing just the coach block.
   - `CLAUDE.md` exists without the markers → append the block at the end, between
     `<!-- okrdev:start -->` and `<!-- okrdev:end -->`. Touch nothing else — the rest of the
     file is the user's.
   - Markers already present → replace only the content between them. This is how level
     changes and upgrades apply cleanly, and how uninstall stays a deletion instead of an
     archaeology project.

9. **Stack module.** Offer it **only** if the repo is greenfield (empty or brand-new) or the
   user explicitly asks. It is never a prerequisite for anything else — if asked, say so
   directly: the method runs on any stack. When wanted, point at `templates/stack/README.md`
   for the step-by-step and `docs/stack.md` for what each piece is and why. It's a day of
   setup; don't start it inside the install conversation unless the user wants to keep going.

10. **Commit.**
    - Levels 0–1 on an unprotected default branch: one direct commit, e.g.
      `chore: install okrdev (level 1)`. The install is additive and the ten-minute promise
      dies waiting on review. On a protected default branch: a short-lived branch and a
      small PR titled `okrdev: install (level <n>)`, merged immediately
      (`gh pr merge --squash`) — about a minute, and the standard path for okrdev writes on
      protected repos anyway.
    - Level 2 files under `.github/` change everyone's workflow: open a PR unless the user
      says commit direct. Narrate for non-technical users: "I'm opening a pull request —
      that's a proposal page with a link you can click."

11. **Close.** Confirm in a few lines what was installed and at what level. Then propose the
    next step:
    - Level 0 → try it immediately: "`/okrdev:park` your next idea."
    - Level 1 → schedule `/okrdev:plan` (about 90 minutes) to draft the first cycle. There
      is no active cycle until plan runs — that's expected, not a gap.
    - Any level → mention `/okrdev:coach` as the anytime entry point for status and
      "is this aligned?" questions.

## Upgrading an existing install

1. Read `okrdev_version` from `okrdev/config.md` frontmatter and compare it with this
   plugin's version in `.claude-plugin/plugin.json`.
2. Diff **only template-derived content**: the coach block between the CLAUDE.md markers,
   any `.github/` files okrdev installed, and `okrdev/config.md` frontmatter keys (new keys
   get proposed with their defaults). New capabilities get offered the same folded-in way —
   e.g. the `okrdev:parked` capture label (step 4) when the repo is on GitHub and the label
   doesn't exist yet.
3. Never touch user data: `MISSION.md` content, cycle files in `okrdev/okrs/`, check-ins,
   `PARKING_LOT.md` entries, `LESSONS.md`. Those are the team's records, not okrdev's.
4. Show the proposed diffs, apply what's approved, bump `okrdev_version`.

## Uninstall (if asked)

Delete `okrdev/`, remove the CLAUDE.md block including its markers, delete the
`okrdev:parked` label (closing any still-open parked issues with a note), and optionally
delete `.github/pull_request_template.md`, `.github/workflows/okr-gate.yml`, and
`.github/CODEOWNERS` if okrdev installed them. That's the entire footprint — "removable" is
a procedure here, not an adjective. Full procedure in `docs/adoption.md`.
