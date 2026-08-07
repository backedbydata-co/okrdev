#!/usr/bin/env bash
#
# okrdev headless install — registers the okrdev marketplace and installs the
# plugin without the interactive /plugin dialog.
#
# Why a script: `claude plugin install` is a documented shell command, but
# marketplace registration has no shell equivalent — it exists only inside the
# interactive dialog. This script closes that gap: it writes the same state the
# dialog writes (a clone under plugins/marketplaces/ plus one entry in
# known_marketplaces.json), then hands off to the documented CLI. If a future
# CLI ships a `claude plugin marketplace add` shell command, the script prefers
# it and touches no state files itself.
#
# Everything written is machine-level, under $CLAUDE_CONFIG_DIR (default
# ~/.claude) — never the repo this runs from. The install-footprint red line
# governs what /okrdev:install later writes into a target repo; this script is
# upstream of all that.
#
# Usage:
#   ./install.sh [--marketplace-source <git-url-or-path>]
#
# --marketplace-source overrides where the marketplace clone comes from
# (default: the checkout this script sits in, falling back to the canonical
# GitHub URL). Mainly for forks and for tests, which point it at a fixture.

set -uo pipefail

# A script that runs from a git hook or a CI step inherits that context's
# GIT_DIR, and GIT_DIR beats `git -C` — so `git -C "$clone_dest" remote set-url`
# would quietly reconfigure whatever repo invoked us instead of the clone we
# just made. Nothing here operates on an ambient repository; every git call
# targets an absolute path of its own. Found by this repo's own pre-push hook.
unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY \
  GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_COMMON_DIR

MARKETPLACE_NAME=okrdev
PLUGIN_NAME=okrdev
CANONICAL_REPO=backedbydata-co/okrdev
CANONICAL_URL=https://github.com/backedbydata-co/okrdev.git

say() { printf 'okrdev install: %s\n' "$1"; }
die() { printf 'okrdev install: %s\n' "$1" >&2; exit 1; }

usage() {
  sed -n '2,25p' "${BASH_SOURCE[0]-$0}" | sed 's/^# \{0,1\}//'
}

source_arg=
while [ $# -gt 0 ]; do
  case $1 in
    --marketplace-source)
      [ $# -ge 2 ] || die "--marketplace-source needs a value"
      source_arg=$2
      shift 2
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    *)
      die "unknown argument: $1 (try --help)"
      ;;
  esac
done

command -v git > /dev/null 2>&1 || die "git is required and was not found on PATH"
command -v claude > /dev/null 2>&1 ||
  die "the claude CLI is not on PATH — install Claude Code first (https://claude.com/claude-code), or use okrdev without it: README.md, \"No Claude Code?\""

config_dir=${CLAUDE_CONFIG_DIR:-$HOME/.claude}
plugins_dir=$config_dir/plugins
marketplaces_dir=$plugins_dir/marketplaces
known=$plugins_dir/known_marketplaces.json
clone_dest=$marketplaces_dir/$MARKETPLACE_NAME

# Default clone source: the checkout this script is running from, when it is
# one — the README flow is clone-then-run, and cloning twice is rude to both
# the network and whatever auth the first clone needed. Piped or copied loose,
# fall back to the canonical URL.
script_dir=$(cd "$(dirname "${BASH_SOURCE[0]-$0}")" 2> /dev/null && pwd) || script_dir=
if [ -n "$source_arg" ]; then
  clone_source=$source_arg
elif [ -n "$script_dir" ] && [ -f "$script_dir/.claude-plugin/marketplace.json" ]; then
  clone_source=$script_dir
else
  clone_source=$CANONICAL_URL
fi

# ── Step 1: the official path, the day it exists ───────────────────────────
# Marketplace registration is interactive-only today. Probe for a shell
# subcommand anyway: if Claude Code ever ships one, the official writer beats
# ours. Every claude invocation reads from /dev/null so nothing can sit
# waiting on a prompt.
registered=
if claude plugin marketplace add --help < /dev/null > /dev/null 2>&1; then
  cli_source=$CANONICAL_REPO
  [ -n "$source_arg" ] && cli_source=$source_arg
  if claude plugin marketplace add "$cli_source" < /dev/null; then
    say "marketplace registered via the CLI's own marketplace command"
    registered=cli
  else
    say "the CLI's marketplace command exists but failed — falling back to state files"
  fi
fi

# ── Step 2: write what the dialog writes ───────────────────────────────────
if [ -z "$registered" ]; then
  json_tool=
  if command -v jq > /dev/null 2>&1; then
    json_tool=jq
  elif command -v node > /dev/null 2>&1; then
    json_tool=node
  else
    die "neither jq nor node is on PATH — register the marketplace by hand instead: docs/adoption.md, \"Headless install\""
  fi

  mkdir -p "$marketplaces_dir" || die "cannot create $marketplaces_dir"

  if [ -e "$clone_dest" ]; then
    # "Something is there" is not "the clone is there". A `git clone` killed by
    # a CI timeout or an OOM leaves a partial directory behind (git cleans up
    # after an error or SIGINT, not after SIGKILL), and skipping the clone over
    # that debris would register a marketplace pointing at nothing — a state
    # that never self-heals, because every re-run skips it again.
    [ -f "$clone_dest/.claude-plugin/marketplace.json" ] ||
      die "$clone_dest exists but is not a marketplace clone (no .claude-plugin/marketplace.json) — remove it and re-run"
    say "marketplace clone already present at $clone_dest — leaving it alone"
  else
    git clone --quiet "$clone_source" "$clone_dest" ||
      die "git clone failed: $clone_source -> $clone_dest"
    # A clone of a local checkout inherits that checkout as origin. Point
    # origin at the canonical repo so later marketplace refreshes pull from
    # GitHub, not from wherever this script happened to run. An explicit
    # --marketplace-source (a fork, a fixture) is honored verbatim.
    if [ -z "$source_arg" ] && [ "$clone_source" != "$CANONICAL_URL" ]; then
      git -C "$clone_dest" remote set-url origin "$CANONICAL_URL" ||
        die "could not point the marketplace clone's origin at $CANONICAL_URL"
    fi
    say "marketplace cloned to $clone_dest"
  fi

  # The entry mirrors what /plugin marketplace add records: source,
  # installLocation, lastUpdated. Default installs register the canonical
  # GitHub source; an explicit --marketplace-source registers as a git URL.
  ts=$(date -u +%Y-%m-%dT%H:%M:%S.000Z)
  # An existing-but-empty file is the trap here: `jq empty` accepts a 0-byte
  # file, and jq's assignment filter over zero input values then emits zero
  # output — so a `-f` guard plus a parse check would report a successful
  # registration having written nothing at all. The guard is -s (non-empty)
  # plus an explicit type check, in both JSON backends.
  known_has_state=
  if [ -s "$known" ]; then
    known_has_state=1
    cp "$known" "$known.bak" || die "could not back up $known"
  fi
  entry_written=
  if [ "$json_tool" = jq ]; then
    if [ -n "$known_has_state" ]; then
      jq -e 'type == "object"' "$known" > /dev/null 2>&1 ||
        die "$known exists but does not hold a JSON object — fix or remove it, then re-run"
    fi
    if [ -n "$known_has_state" ] && jq -e --arg n "$MARKETPLACE_NAME" 'has($n)' "$known" > /dev/null; then
      say "marketplace already registered in known_marketplaces.json — leaving it alone"
    else
      if [ -n "$source_arg" ]; then
        src=$(jq -n --arg u "$source_arg" '{source: "git", url: $u}')
      else
        src=$(jq -n --arg r "$CANONICAL_REPO" '{source: "github", repo: $r}')
      fi
      if [ -n "$known_has_state" ]; then
        jq --arg n "$MARKETPLACE_NAME" --argjson src "$src" --arg loc "$clone_dest" --arg ts "$ts" \
          '.[$n] = {source: $src, installLocation: $loc, lastUpdated: $ts}' "$known" > "$known.tmp" ||
          die "jq could not build the marketplace entry in $known — fix or remove the file, then re-run"
      else
        jq -n --arg n "$MARKETPLACE_NAME" --argjson src "$src" --arg loc "$clone_dest" --arg ts "$ts" \
          '{($n): {source: $src, installLocation: $loc, lastUpdated: $ts}}' > "$known.tmp" ||
          die "jq could not build the marketplace entry"
      fi
      mv "$known.tmp" "$known" || die "could not write $known"
      entry_written=1
    fi
  else
    # Same two guards as the jq branch, for the same reason: a shape this
    # script did not expect must stop it, not be silently written past. An
    # array here would swallow the assignment — JSON.stringify drops named
    # keys off an array — and report success having registered nothing.
    out=$(node -e '
      const fs = require("fs");
      const [known, name, mode, ref, loc, ts] = process.argv.slice(1);
      let data = {};
      if (fs.existsSync(known)) {
        const raw = fs.readFileSync(known, "utf8").trim();
        if (raw) {
          try { data = JSON.parse(raw); }
          catch (e) { console.error("does not hold valid JSON"); process.exit(2); }
          if (data === null || typeof data !== "object" || Array.isArray(data)) {
            console.error("does not hold a JSON object"); process.exit(2);
          }
        }
      }
      if (Object.prototype.hasOwnProperty.call(data, name)) { console.log("present"); process.exit(0); }
      const source = mode === "git" ? { source: "git", url: ref } : { source: "github", repo: ref };
      data[name] = { source, installLocation: loc, lastUpdated: ts };
      fs.writeFileSync(known, JSON.stringify(data, null, 2) + "\n");
      console.log("added");
    ' "$known" "$MARKETPLACE_NAME" "${source_arg:+git}" "${source_arg:-$CANONICAL_REPO}" "$clone_dest" "$ts" 2>&1)
    case $? in
      0) ;;
      2) die "$known $out — fix or remove it, then re-run" ;;
      *) die "node could not update $known: $out" ;;
    esac
    if [ "$out" = present ]; then
      say "marketplace already registered in known_marketplaces.json — leaving it alone"
    else
      entry_written=1
    fi
  fi
  [ -n "$entry_written" ] && say "marketplace registered in known_marketplaces.json"
fi

# ── Step 3: the documented CLI does the actual install ─────────────────────
say "installing plugin: $PLUGIN_NAME@$MARKETPLACE_NAME"
claude plugin install "$PLUGIN_NAME@$MARKETPLACE_NAME" < /dev/null ||
  die "claude plugin install failed — fall back to the interactive path: run claude, then /plugin marketplace add $CANONICAL_REPO and /plugin install $PLUGIN_NAME"

say "done. New sessions load the plugin; running sessions need /reload-plugins."
say "next, in the repo where okrdev should live: /okrdev:install — Level 0 takes ten minutes"
