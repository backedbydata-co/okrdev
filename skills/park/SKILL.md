---
name: park
description: Capture an idea into the okrdev parking lot in ten seconds — one line, energy, effort, done — then get back to work. Use when the user says "park this", "park that idea", "add it to the parking lot", "idea for later", "don't let me forget", or when a mid-session idea is about to turn into mid-session work.
---

# Park

Capture an idea into the okrdev parking lot — a GitHub issue labeled `okrdev:parked` when the
repo lives on GitHub, a line in `okrdev/PARKING_LOT.md` otherwise — and return the human to
what they were doing. Target: ten seconds of their attention. Capture is nearly free so that acting on impulse never
has to be — that's the deal the whole parking lot rests on.

The one rule that matters: **you are recording the idea, not evaluating it.** No feasibility
take, no design sketch, no clarifying questions about scope, no "interesting — you could also…".
The moment analysis starts, the idea has started winning. Building takes days; parking takes
one line. Triage — at the weekly check-in — is where the idea gets its hearing.

## Procedure

1. **Check the install.**
   - No `okrdev/` directory → okrdev isn't installed here. Say so and point at
     `/okrdev:install` — Level 0 is this file plus a config and takes ten minutes. Offer to
     hold the idea in the conversation and park it the moment install finishes.
   - `okrdev/` exists but `okrdev/PARKING_LOT.md` is missing, or has lost its section
     headings → repair it to the format reference below (add what's missing, never delete
     existing lines), then continue.
   - No active cycle → irrelevant. Parking needs no cycle, no mission, no check-in history.
     Capture must never wait on ceremony; that's the point of Level 0.

2. **Get the line.** One sentence, in the capturer's own words. If the human already stated
   the idea, use what they said — don't make them repeat it. Then the two five-second calls,
   asked together in a single question if you can't infer them from how the idea arrived:
   - `energy:` high / med / low — how excited the capturer is, right now.
   - `effort:` S / M / L — gut-call size.

   Accept the first answer. These are instincts, not estimates — do not help the human "think
   it through"; that's analysis wearing a costume. If they wave the question off, make your
   best call from context and name it in your confirmation so they can correct you.

3. **Identify the capturer.** Use the handle this repo's okrdev files already use for this
   person (check-in `attendees`, KR `DRI:` lines, `backstop` in `okrdev/config.md`). Failing
   that, `git config user.name`, lowercased. Ask only if you genuinely can't tell.

4. **Capture it — issue first, file as fallback.** One entry per idea — if the human is
   dumping several at once ("park three things from my phone notes"), capture each with its
   own energy and effort call. Batch the questions; don't run the ritual three times.

   - **Primary — GitHub issue** (when `gh` is authed and the repo's remote is GitHub):

     ```bash
     gh issue create --label okrdev:parked \
       --title "<one-line idea, verbatim>" \
       --body "@<who> — energy: <high|med|low> — effort: <S|M|L>"
     ```

     Zero commits, zero CI, one API call — the ten-second promise, kept on any repo,
     protected or not. If the label doesn't exist yet, create it first:

     ```bash
     gh label create okrdev:parked --color F9D71C \
       --description "okrdev parking-lot inbox — triaged weekly, then closed"
     ```

     Parked issues are inert by convention: never assign, milestone, or work one. Open means
     captured; triage closes it with the decision as a comment. The idea lives in the issue
     until then — don't also write a Captured line. A side benefit worth knowing about: the
     human can park from the GitHub mobile app, and collaborators can park from the GitHub
     UI, no Claude session required.

   - **Fallback — file append** (no `gh`, no remote, or the remote isn't GitHub): add one
     line at the end of the `## Captured` section in `okrdev/PARKING_LOT.md`:

     ```markdown
     - [2026-07-13] <one-line idea> — @alex — energy: high — effort: M
     ```

     Today's date, ISO format.

5. **Commit the fallback append.** (The issue path writes nothing to git — skip this step.)
   - **Unprotected default branch** → commit directly.
     - Already on the default branch: stage only `okrdev/PARKING_LOT.md`, commit
       (`okrdev: park <first few words of the idea>`), push.
     - On a working branch: do not switch branches — the human may have uncommitted work.
       Use a temporary worktree: `git fetch origin`, `git worktree add <tmpdir>
       origin/<default> --detach`, make the same append there, commit, `git push origin
       HEAD:<default>`, remove the worktree. The working branch never notices.
   - **Protected default branch** → a small state PR: branch `okrdev/state-<date>-park`,
     push, then open and merge the PR via the forge's own mechanism — by construction `gh`
     is unavailable on this path (a gh-authed GitHub repo would have taken the issue path),
     so use the forge's CLI (`glab`, etc.) or hand the human the compare URL the push
     printed, with a one-line "open this, then merge" instruction. Title
     `okrdev: park <first few words>` with a `KR:` line. Be honest that this capture cost
     ~30 seconds, not ten — on GitHub repos, the issue path is what keeps the ten-second
     promise.
   - No remote: commit locally and move on.

6. **Confirm in one line and get out.** Issue captures name the number: "Parked as #12:
   <idea>. It gets triaged at the next check-in." File captures: "Parked: <idea>. It gets
   triaged at the next check-in." On a Level 0 install, where there are no check-ins yet:
   "Triage it weekly with `/okrdev:triage`." Then return to whatever was in progress before
   the idea arrived. Do not summarize the idea back, do not rate it, do not suggest next
   steps. The confirmation exists so the human trusts the idea is safe — trust is what lets
   them let go of it.

## If the human wants to work on it now

Parking is for ideas that can wait a week. If this one can't — the human is visibly not going
to let go — don't argue and don't cave silently. That's a side-quest: point at
`/okrdev:side-quest`, which sanctions the distraction with a time-box and logs it. The parking
lot's promise ("nothing in Captured gets worked on — triage first") only holds because the
escape hatch is a real door, not a hole in the fence.

## Format reference

The full file, as `/okrdev:install` creates it. Repair to this shape if sections are missing;
`park`'s file fallback only ever appends to `## Captured` — issue captures don't touch the
file until triage writes their decisions into the ledger sections.

```markdown
# Parking Lot
Ideas get captured here in seconds and triaged at the weekly check-in.
Nothing in Captured gets worked on. Ever. Triage first.

## Captured
- [2026-07-13] <one-line idea> — @alex — energy: high — effort: M

## Side quests (time-boxed, logged)
- [2026-07-13] <idea> — @alex — box: 4h — spent: 2h — status: open — notes: —

## Promoted
- [2026-07-13] <idea> → KR2.1 (or: next-cycle candidate)

## Archived
- [2026-07-13] <idea> — reason: <one line>
```

The full capture/triage protocol, including why nothing in Captured gets worked on, lives in
[../../docs/parking-lot.md](../../docs/parking-lot.md).
