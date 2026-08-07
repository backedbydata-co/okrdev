# Contributing

okrdev runs on itself. This repo plans its own development with the method it
ships (`okrdev/` holds the live cycle), which shapes how contributions land.

## Ideas: park first, build second

Building takes days; capture takes ten seconds. If you have a feature idea,
file an issue with the `okrdev:parked` label (there's an issue template) —
title is the idea, energy/effort if you have five extra seconds. It gets a
fair hearing at the weekly triage sweep, where it's promoted, archived, or
sanctioned as a time-boxed side-quest.

A large unsolicited feature PR skips that decision, which means the decision
happens *to* it — usually as a slow close. Bugfixes, doc corrections, and
small refactors need no ceremony: open the PR.

## Every PR carries a `KR:` line

The PR template asks for one line classifying the work. For outside
contributions that's almost always `maintenance`. Feature work should trace
to a parked issue that got promoted — if you're not sure, say so in the PR
and the maintainer will classify it with you.

## The local loop

Wire the checks once per clone:

    git config core.hooksPath tests/hooks

Then `./tests/check.sh` runs on every push — seconds, no network, no
secrets. CI (`check`, required) runs the same suite plus shellcheck and
actionlint, so a green local run means CI is confirmation, not discovery.

Pushing a deliberately failing commit is a first-class path here, not a
bypass — docs/testing.md calls it red-first, and `OKRDEV_RED_FIRST=1 git
push` lets the red through so CI records it before your fix lands.

## What the checks defend

Most of `tests/check.sh` guards **cross-file coherence** — the repo's first
health metric. Numbers and rules stated in several files must move together;
if a check says a threshold drifted, the fix is moving every copy, not
rewording one to dodge the grep. Some divergences are deliberate and pinned
in the suite's do-not-freeze list; read the comment there before "fixing"
one.

Style: match the file you're in. The docs are doctrine — plain-spoken,
comment-dense, no filler. Shell must pass shellcheck and avoid GNU-only
flags (most of this project is written on macOS; CI is Linux — the suite
checks both directions).

## License

MIT. By contributing you agree your contributions are licensed the same way.
