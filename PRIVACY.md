# Privacy

**okrdev collects nothing.** There is no telemetry, no analytics, and no account. This document
exists because the Claude plugin directory asks every listed plugin for one, and because "we
collect nothing" is worth being able to point at rather than assert.

Last updated: 2026-08-08.

## The plugin

okrdev is a set of skills — markdown instructions that Claude Code reads — plus templates and
docs. It ships **no MCP servers**, opens no network connections of its own, and has no server
side for data to reach.

Everything okrdev produces is a file in **your** repository: `okrdev/` holds your mission, cycle
OKRs, check-ins, lessons, and parking lot. Those files live wherever your repo lives, under your
git history and your access control. Deleting the `okrdev/` directory and the marked block in
your `CLAUDE.md` removes okrdev entirely — the uninstall procedure is in
[docs/adoption.md](docs/adoption.md).

Two things worth naming plainly, because they are the only places anything leaves your machine:

- **Claude Code sends your prompts and the files it reads to Anthropic**, exactly as it does
  without okrdev installed. okrdev changes what Claude reads in your repo; it does not change
  where that goes. Anthropic's handling of it is covered by the
  [Anthropic Privacy Policy](https://www.anthropic.com/legal/privacy).
- **`install.sh` clones this repository from GitHub** and writes Claude Code's own marketplace
  state under `~/.claude`. That is a git clone and two local files. It sends nothing anywhere.

Where a skill uses `gh` to read or open issues and pull requests, it is acting on the repo you
pointed it at, with your own credentials, and GitHub's terms govern that.

## The website

[okrdev.com](https://okrdev.com) is a single static HTML page. It runs **no JavaScript** — the
Content-Security-Policy served with it sets `script-src 'none'`, which you can verify with
`curl -sIL https://okrdev.com`. The `-L` matters: the apex 308-redirects to `www`, and the
redirect itself carries no headers worth reading. It sets no cookies and includes no analytics, no tag manager,
and no third-party embeds.

The host (Vercel) writes standard server access logs, as any web host does.

The page links out to Calendly for booking a call. **If you follow that link and book,** Calendly
receives whatever you type into it — typically your name, email, and any notes — and its own
privacy policy applies from that point. Nothing on okrdev.com collects those details; the link
simply hands you to a different site.

## Email

If you email the maintainer, or open a GitHub issue, the maintainer holds what you sent for as
long as it is useful to hold. Security reports should go through GitHub's private vulnerability
reporting — see [SECURITY.md](SECURITY.md).

## Changes

Material changes to this document will be noted in [CHANGELOG.md](CHANGELOG.md) like any other
change to the project. Questions belong in a
[GitHub issue](https://github.com/backedbydata-co/okrdev/issues).
