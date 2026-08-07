# Security

okrdev has no runtime of its own — it is markdown and shell. The security
surface that matters is the scripts and workflow templates adopters copy into
their own repos and run with their own credentials:

- `install.sh` — runs on a contributor's machine
- `templates/stack/branch-protection.sh` — runs with a GitHub admin token
- `templates/github/workflows/*.yml` — run in adopters' CI with their secrets
- the workflows and scripts embedded in the docs as copy-paste blocks —
  `templates/stack/README.md`'s e2e-preview and migrate-prod examples,
  `docs/live-coached-sessions.md`'s monitor script — which run wherever an
  adopter pastes them; the calibration vulnerability below lived in exactly
  this class

A shell-injection-class bug in any of those is a real vulnerability even
though nothing in this repo "executes". This project has already shipped and
then caught exactly one of these — a branch-name injection in a shipped
workflow template, now a permanent regression check (`check_workflow_injection`
in `tests/check.sh`, with the env-var fix pattern documented in
`templates/stack/README.md`). Treat that as the calibration for what counts.

## Reporting

Use GitHub's private vulnerability reporting: **Security → Report a
vulnerability** on this repository. Please don't open a public issue for
anything you believe is exploitable in an adopter's repo — adopters carry the
copies, so public disclosure before a fix lands in the templates burns them,
not us.

Solo-maintainer project: expect an acknowledgment in days, not hours.
Verified reports get a fix PR, a regression check in `tests/check.sh` where
the class allows one, and a line in CHANGELOG.md.

## Supported versions

The tip of `main` (pre-1.0, the only maintained line). `okrdev_version`
markers in adopter repos record install state — they are not maintained
branches, and fixes reach adopters through the upgrade path in
docs/adoption.md.
