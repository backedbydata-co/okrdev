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

```bash
codex plugin marketplace add backedbydata-co/okrdev
codex plugin add okrdev@okrdev
```

`marketplace add` also takes a local path, an HTTPS or SSH Git URL, and `--ref` for a branch or
tag. Then start a new Codex session and type `@` to reach the skills.

## Verified, not assumed

Everything above was checked against `codex-cli 0.147.0` on 2026-08-08 by installing okrdev and
reading what landed. Recorded here because these are expensive to re-derive, and because two of
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
