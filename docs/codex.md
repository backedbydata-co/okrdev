# okrdev on Codex

okrdev runs on OpenAI Codex as well as Claude Code. One repo, one `skills/` tree, one coach
block. The only thing that differs is which file the block is written to.

| | Claude Code | Codex |
|---|---|---|
| Instructions file | `CLAUDE.md` | `AGENTS.md` |
| Skill invocation | `/okrdev:park` | `@` mention, then pick the skill |
| Manifest | `.claude-plugin/plugin.json` | `.codex-plugin/plugin.json` |
| Registration state | `~/.claude/plugins/known_marketplaces.json` | `~/.codex/config.toml` |
| Install cache | `~/.claude/plugins/cache/...` | `~/.codex/plugins/cache/okrdev/okrdev/<version>` |

**Claude Code does not read `AGENTS.md`.** Its docs are explicit — *"Claude Code reads
`CLAUDE.md`, not `AGENTS.md`"* — and `AGENTS.md` appears nowhere in its documented memory load
order. That is why the destination is a parameter rather than a single shared file. If you want
one file feeding both agents, that bridge is yours to build in your own repo: Claude Code
documents an `@AGENTS.md` import line for exactly this. okrdev will not write it for you.

**One install writes one instructions file, never both.** Two coach blocks drift, and this
project has already lived that failure once — its own block sat a revision behind its template
for a month. `/okrdev:install` resolves the destination with existing markers winning over the
host default, so a repo installed from one agent and upgraded from the other moves its block
rather than sprouting a second.

## Installing

okrdev is listed in the OpenAI plugin directory. That is the shortest path and needs no
terminal:

> **[Install okrdev from the plugin directory →](https://chatgpt.com/plugins/plugins_6a7a2f9e3968819187e30eaee8da1435)**

Press **Install plugin**, then start a session and type `@` to reach the skills.

**The two paths do not fetch the same thing.** The listing serves the artifact that was last
uploaded to the portal — a zip snapshot, not a mirror of `main` (see
[codex-submission.md](codex-submission.md)) — so it can sit behind this repo until someone
uploads again. `marketplace add` points at the repository and fetches what is on the branch you
name. If you want the newest okrdev the moment it lands, use the CLI; if you want the reviewed,
published artifact, use the listing.

### From the CLI

```bash
codex plugin marketplace add backedbydata-co/okrdev
codex plugin add okrdev@okrdev
```

`marketplace add` also takes a local path, an HTTPS or SSH Git URL, and `--ref` for a branch or
tag. Then start a new Codex session and type `@` to reach the skills.

## Verified, not assumed

The table above and the CLI install were checked against `codex-cli 0.147.0` on 2026-08-08 by
installing okrdev and reading what landed. The directory listing arrived later and by a
different mechanism, so it is deliberately excluded from this section — what is and is not known
about it is below. Recorded here because these are expensive to re-derive, and because two of
them contradict the published documentation:

- **Registration state is `~/.codex/config.toml`, in TOML** — not the
  `~/.agents/plugins/marketplace.json` the plugin docs describe. It looks like this:

  ```toml
  [marketplaces.okrdev]
  source_type = "local"
  source = "/path/to/repo"

  [plugins."okrdev@okrdev"]
  enabled = true
  ```

- **Codex reads `.claude-plugin/marketplace.json`** — the legacy-compatible path — so okrdev
  needs no second marketplace file. `codex plugin list` prints the path it resolved, which is
  how this was confirmed rather than inferred.
- **`"source": "./"` resolves**, with the repo root as the plugin root.
- **`.codex-plugin/plugin.json` wins over `.claude-plugin/plugin.json`** where both exist.
  Proved by setting the Codex manifest to `9.9.9` and watching the install cache path follow it.
  This is why `check_plugin_manifests` diffs a shared-identity projection across both manifests:
  they are two files describing one product, and nothing else would keep them equal.
- **`.git` is not copied into the plugin cache.** The install payload was 864K — the tracked
  tree, no history.

## What is not yet verified

- The exact `@` mention form for a specific bundled skill. Typing `@` and picking from the list
  works; whether `@okrdev:park` or similar resolves directly has not been tested in a live
  session.
- Whether a `CLAUDE_CONFIG_DIR` analog exists for Codex. Until it does, `tests/check.sh` cannot
  make the Codex half of a headless-install check hermetic the way it does for Claude Code.
- Whether the directory's own installer honours a subdirectory `source`. okrdev does not need
  it — its plugin root is the repo root — so this was left alone rather than guessed at.
- **What a portal install actually writes.** Every row in the table above was read off a
  `codex plugin add`. The listing install was not re-derived, and it has reason to differ: it
  delivers an uploaded zip rather than registering a marketplace pointer, so the
  `~/.codex/config.toml` entry and the versioned cache path may not match. Nothing here should
  be assumed to describe that path until someone installs from the listing and reads what
  landed.
