#!/usr/bin/env bash
#
# okrdev checks itself. The doctrine behind this file is docs/testing.md.
#
# Two rules govern what may live here, both enforced by checks in this file:
#
#   1. Every assert traces to a real chafe. The `# chafe:` line above each
#      check names it; check_chafe_comments fails the run if one is missing.
#      A check nobody needed is speculative coverage, refused by construction.
#
#   2. Some divergence is deliberate. DO_NOT_FREEZE below lists what this
#      suite must never assert away, and each entry is itself a negative test:
#      if the cited divergence disappears, the run fails and somebody decides
#      to graduate the rule through a doctrine PR or drop the entry. The list
#      cannot rot into a stale comment, because it runs.
#
# No frameworks on purpose (docs/testing.md, "Ruled out"): bash, node, jq, diff.
# Runs in under a minute, needs no network and no secrets.

set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.." || exit 1

failures=0
ok()   { printf '  ok    %s\n' "$1"; }
bad()  { printf '  FAIL  %s\n' "$1"; failures=$((failures + 1)); }

# The marked coach block, however it is embedded — a plain file, an installed
# CLAUDE.md, or a fenced quotation inside prose. Anchored so the markers named
# in running text (ai-coach.md explains them) are not mistaken for the block.
coach_block() { sed -n '/^<!-- okrdev:start -->$/,/^<!-- okrdev:end -->$/p' "$1"; }

# The canonical KR-line grammar, stripped of each copy's regex delimiters,
# flags and trailing punctuation so three different embeddings compare equal.
kr_grammar() { grep -h '\^KR:' "$1" | head -1 | sed 's/.*\(\^KR:.*\\s\*\$\).*/\1/'; }

# A check-in is HELD when its KR-confidence table carries at least one KR row.
# The existence of a week file proves nothing: rule 5 tells the coach to create
# one to log a judgment call mid-week, and /okrdev:checkin drafts one before the
# humans arrive. docs/rituals.md § the missed-cadence catch-up is the canonical
# definition of "held"; this is its one executable copy, shared by everything
# below that needs it, because a second copy is a second thing to drift.
#
# The header row is `| KR | DRI | ...`, so the digit is load-bearing: matching
# `^| KR` alone counts an empty table as populated, which is exactly how a
# never-held week silences a staleness rule.
held_checkin_rows() { grep -E '^\|[[:space:]]*KR[0-9]' "$1" 2> /dev/null; }

# Newest held check-in in a cycle's directory, or empty. Filenames are
# <yyyy>-W<nn>.md with a zero-padded ISO week, so lexical order is chronological
# order — including across a year boundary, which is why the year leads.
newest_held_checkin() {
  local dir=$1 f newest=
  for f in "$dir"/*.md; do
    [ -f "$f" ] || continue
    held_checkin_rows "$f" > /dev/null || continue
    if [ -z "$newest" ] || [[ "$f" > "$newest" ]]; then newest=$f; fi
  done
  printf '%s' "$newest"
}

# ── Checks ─────────────────────────────────────────────────────────────────

# chafe: the block drifted from its template for a month (PARKING_LOT 2026-08-04,
# "repo-root CLAUDE.md coach block one revision behind") — captured, never fixed.
check_coach_block() {
  local template=templates/CLAUDE-okrdev.md
  local copy status=0
  for copy in CLAUDE.md docs/ai-coach.md; do
    if diff -u <(coach_block "$template") <(coach_block "$copy") > /tmp/okrdev-coach-diff; then
      ok "coach block: $copy matches $template"
    else
      bad "coach block: $copy has drifted from $template"
      sed 's/^/        /' /tmp/okrdev-coach-diff
      status=1
    fi
  done
  rm -f /tmp/okrdev-coach-diff
  return $status
}

# chafe: shipped to adopters unrun. Bad input exits 127 with "die: command not
# found" because die() is defined below its first call — found writing docs/testing.md.
check_branch_protection_bad_input() {
  local out code
  out=$(OKRDEV_REQUIRED_APPROVALS=abc bash templates/stack/branch-protection.sh owner/repo 2>&1)
  code=$?
  # Both halves matter: a nonzero-only assert passes on the broken script,
  # which exits 127 instead of 1 and prints the wrong message.
  if [ "$code" -eq 1 ] && printf '%s' "$out" | grep -q 'OKRDEV_REQUIRED_APPROVALS must be'; then
    ok "branch-protection.sh: invalid approvals count exits 1 with its own message"
  else
    bad "branch-protection.sh: invalid approvals count exited $code saying: ${out:-(nothing)}"
  fi
}

# chafe: none yet — the grammar's three copies agree today. Frozen before one
# drifts, because that is exactly how the coach block got away.
check_kr_grammar() {
  local files=(docs/method.md skills/checkin/SKILL.md templates/github/workflows/okr-gate.yml)
  local f distinct
  for f in "${files[@]}"; do
    if [ -z "$(kr_grammar "$f")" ]; then
      bad "KR grammar: no pattern found in $f"
      return 1
    fi
  done
  distinct=$(for f in "${files[@]}"; do kr_grammar "$f"; done | sort -u | wc -l)
  if [ "$distinct" -eq 1 ]; then
    ok "KR grammar: all ${#files[@]} copies agree"
  else
    bad "KR grammar: ${#files[@]} copies, $distinct distinct patterns"
    for f in "${files[@]}"; do printf '        %s: %s\n' "$f" "$(kr_grammar "$f")"; done
  fi
}

# chafe: none yet — six files state this format and every override log line
# depends on it. Same reasoning as the KR grammar.
check_judgment_call_format() {
  local expected=6 found distinct
  found=$(grep -rc -- '— <who> — <reason>' docs/ skills/ templates/ 2>/dev/null | awk -F: '{n += $2} END {print n + 0}')
  distinct=$(grep -rho -- '- <date> —[^`.]*' docs/ skills/ templates/ 2>/dev/null | sed 's/[[:space:]]*$//' | sort -u | wc -l)
  if [ "$found" -eq "$expected" ] && [ "$distinct" -eq 1 ]; then
    ok "judgment-call line: $expected copies, one format"
  else
    bad "judgment-call line: expected $expected copies of one format, found $found copies in $distinct shapes"
    grep -rn -- '- <date> —' docs/ skills/ templates/ 2>/dev/null | sed 's/^/        /'
  fi
}

# chafe: none yet — the manifests are what a `/plugin install` reads first, and
# nothing has ever checked they parse.
check_plugin_manifests() {
  local plugin=.claude-plugin/plugin.json market=.claude-plugin/marketplace.json
  local f version
  for f in "$plugin" "$market"; do
    if ! jq empty "$f" 2>/dev/null; then
      bad "manifests: $f is not valid JSON"
      return 1
    fi
  done
  version=$(jq -r '.version' "$plugin")
  if ! printf '%s' "$version" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+$'; then
    bad "manifests: plugin.json version '$version' is not semver"
    return 1
  fi
  if [ "$(jq -r '.name' "$plugin")" != "$(jq -r '.plugins[0].name' "$market")" ]; then
    bad "manifests: plugin.json and marketplace.json disagree on the plugin name"
    return 1
  fi
  ok "manifests: both parse, versions are semver, names agree"
}

# chafe: KR2.2 — okrdev itself could not be installed without clicking through
# the /plugin dialog (parked 2026-07-23, promoted into the 2026-Q3 plan). The
# CLI's real gap: `claude plugin install` is a shell command, marketplace
# registration isn't. install.sh bridges it by writing the dialog's own state
# files, so this check pins that behavior against a stub claude in a throwaway
# CLAUDE_CONFIG_DIR — fixture clone from a local path, no network, per doctrine.
check_headless_install() {
  local script=install.sh
  if [ ! -x "$script" ]; then
    bad "headless install: $script missing or not executable"
    return 1
  fi
  local tmp status=0
  tmp=$(mktemp -d) || { bad "headless install: mktemp failed"; return 1; }

  # A fixture marketplace repo: the script's contract is "any git-cloneable
  # source holding .claude-plugin/", not "GitHub specifically".
  mkdir -p "$tmp/market"
  cp -R .claude-plugin "$tmp/market/"
  # GIT_DIR beats `git -C`, and a pre-push hook runs with GIT_DIR set — so the
  # unqualified form built the fixture inside THIS repo and the check failed
  # only when run the way the repo asks you to run it. The suite has to be
  # hermetic in a hook, or the local rail is the one place it doesn't work.
  local fixture_git=(env -u GIT_DIR -u GIT_WORK_TREE -u GIT_INDEX_FILE
                     -u GIT_OBJECT_DIRECTORY -u GIT_ALTERNATE_OBJECT_DIRECTORIES
                     -u GIT_COMMON_DIR git)
  if ! { "${fixture_git[@]}" -C "$tmp/market" init -q -b main &&
         "${fixture_git[@]}" -C "$tmp/market" add -A &&
         "${fixture_git[@]}" -C "$tmp/market" -c user.email=check@okrdev -c user.name=check \
             -c commit.gpgsign=false commit -qm fixture; }; then
    bad "headless install: could not build the fixture marketplace repo"
    rm -rf "$tmp"
    return 1
  fi

  # A stub claude on PATH — the docs/testing.md pattern. It refuses the
  # marketplace subcommand exactly like today's CLI, accepts plugin install,
  # and records argv so the handoff to the documented command is assertable.
  mkdir -p "$tmp/bin" "$tmp/claude-home"
  cat > "$tmp/bin/claude" << 'STUB'
#!/usr/bin/env bash
printf '%s\n' "$*" >> "${CLAUDE_STUB_LOG:?}"
case "${1-} ${2-}" in
  "plugin marketplace") echo "error: unknown command 'marketplace'" >&2; exit 1 ;;
  "plugin install") exit 0 ;;
  *) exit 0 ;;
esac
STUB
  chmod +x "$tmp/bin/claude"

  # Failure path first, both halves (the branch-protection.sh lesson): a PATH
  # with git but no claude must exit 1 with the script's own message, not 127
  # with bash's. /usr/bin:/bin carries git on macOS and Linux; no installer
  # puts claude there.
  local out code
  out=$(env PATH="/usr/bin:/bin" CLAUDE_CONFIG_DIR="$tmp/claude-home" bash "$script" 2>&1)
  code=$?
  if [ "$code" -eq 1 ] && printf '%s' "$out" | grep -q 'the claude CLI is not on PATH'; then
    ok "headless install: missing claude exits 1 with its own message"
  else
    bad "headless install: missing claude exited $code saying: ${out:-(nothing)}"
    status=1
  fi

  # Happy path: stub claude shadows any real one; everything else is real.
  local log="$tmp/stub.log" home="$tmp/claude-home"
  out=$(PATH="$tmp/bin:$PATH" CLAUDE_STUB_LOG="$log" CLAUDE_CONFIG_DIR="$home" \
        bash "$script" --marketplace-source "$tmp/market" 2>&1)
  code=$?
  local knownf="$home/plugins/known_marketplaces.json"
  if [ "$code" -eq 0 ] &&
     [ -f "$home/plugins/marketplaces/okrdev/.claude-plugin/marketplace.json" ] &&
     jq -e '.okrdev.source.source == "git" and .okrdev.installLocation != null' "$knownf" > /dev/null 2>&1 &&
     [ "$(jq -r '.okrdev.source.url' "$knownf")" = "$tmp/market" ] &&
     grep -q '^plugin install okrdev@okrdev$' "$log"; then
    ok "headless install: registers the marketplace and hands off to claude plugin install"
  else
    bad "headless install: happy path failed (exit $code)"
    printf '%s\n' "$out" | sed 's/^/        /'
    status=1
  fi

  # Idempotency: a second run must not clobber, duplicate, or fail.
  out=$(PATH="$tmp/bin:$PATH" CLAUDE_STUB_LOG="$log" CLAUDE_CONFIG_DIR="$home" \
        bash "$script" --marketplace-source "$tmp/market" 2>&1)
  code=$?
  if [ "$code" -eq 0 ] && [ "$(jq -r 'keys | length' "$knownf")" = 1 ]; then
    ok "headless install: second run leaves existing state alone and exits 0"
  else
    bad "headless install: second run exited $code (keys: $(jq -r 'keys | length' "$knownf" 2>/dev/null))"
    printf '%s\n' "$out" | sed 's/^/        /'
    status=1
  fi

  # The default, no-argument path — the one the README actually tells people to
  # run, and the only one that produces the `source: github` entry shape and the
  # origin re-point. Every assert above passes --marketplace-source, so without
  # this the shape a real adopter receives is never executed: a typo in the
  # github branch stays green all the way to their machine. Still no network —
  # script_dir is this checkout, and `remote set-url` never contacts anything.
  local home2="$tmp/claude-home-default" known2 origin
  known2=$home2/plugins/known_marketplaces.json
  out=$(PATH="$tmp/bin:$PATH" CLAUDE_STUB_LOG="$log" CLAUDE_CONFIG_DIR="$home2" \
        bash "$script" 2>&1)
  code=$?
  origin=$("${fixture_git[@]}" -C "$home2/plugins/marketplaces/okrdev" remote get-url origin 2> /dev/null)
  if [ "$code" -eq 0 ] &&
     jq -e '.okrdev.source == {source: "github", repo: "backedbydata-co/okrdev"}' "$known2" > /dev/null 2>&1 &&
     [ "$origin" = "https://github.com/backedbydata-co/okrdev.git" ]; then
    ok "headless install: default path registers the github source and re-points origin upstream"
  else
    bad "headless install: default path failed (exit $code, origin: ${origin:-none})"
    printf '%s\n' "$out" | sed 's/^/        /'
    jq -c '.okrdev.source' "$known2" 2> /dev/null | sed 's/^/        source: /'
    status=1
  fi

  # An existing-but-empty known_marketplaces.json — `touch` instead of the
  # by-hand step's `{}`, or a writer that died mid-write. jq accepts a 0-byte
  # file and its assignment filter then emits nothing, so the first version of
  # this script reported a successful registration over a file it left empty,
  # forever, on every re-run. Both JSON backends must refuse it instead.
  local home3="$tmp/claude-home-empty" known3
  known3=$home3/plugins/known_marketplaces.json
  mkdir -p "$home3/plugins"
  : > "$known3"
  out=$(PATH="$tmp/bin:$PATH" CLAUDE_STUB_LOG="$log" CLAUDE_CONFIG_DIR="$home3" \
        bash "$script" --marketplace-source "$tmp/market" 2>&1)
  code=$?
  if [ "$code" -eq 0 ] && jq -e '.okrdev.installLocation != null' "$known3" > /dev/null 2>&1; then
    ok "headless install: an empty known_marketplaces.json is written, not silently skipped"
  else
    bad "headless install: empty known_marketplaces.json left unregistered (exit $code)"
    printf '%s\n' "$out" | sed 's/^/        /'
    status=1
  fi

  # Debris at the clone destination — a `git clone` killed by a CI timeout
  # leaves a partial dir. Skipping the clone over it registers a marketplace
  # pointing at nothing, and every re-run skips it again.
  local home4="$tmp/claude-home-debris"
  mkdir -p "$home4/plugins/marketplaces/okrdev"
  out=$(PATH="$tmp/bin:$PATH" CLAUDE_STUB_LOG="$log" CLAUDE_CONFIG_DIR="$home4" \
        bash "$script" --marketplace-source "$tmp/market" 2>&1)
  code=$?
  if [ "$code" -eq 1 ] && printf '%s' "$out" | grep -q 'is not a marketplace clone'; then
    ok "headless install: debris at the clone destination exits 1 rather than registering it"
  else
    bad "headless install: debris at the clone destination exited $code saying: ${out:-(nothing)}"
    status=1
  fi

  # KR2.2's 1.0 anchor is "following only the README" — a script the docs
  # never point at is a script that does not exist for adopters.
  local f docs_ok=0
  for f in README.md docs/adoption.md; do
    if ! grep -q 'install\.sh' "$f"; then
      bad "headless install: $f never mentions install.sh"
      docs_ok=1
      status=1
    fi
  done
  # Scoped to its own flag, not the shared one: an assert that reports only
  # when every other assert passed is an assert that goes quiet exactly when
  # the run is worth reading.
  [ $docs_ok -eq 0 ] && ok "headless install: README.md and docs/adoption.md both point at install.sh"

  rm -rf "$tmp"
  return $status
}

# chafe: branch-protection.sh shipped with die() called before its definition
# and nothing caught it (fixed in the Phase 0 PR). shellcheck catches that whole
# class. Skipped, loudly, when the tool is absent — a check that quietly does
# nothing on a laptop is worse than one that says it didn't run.
check_shell_lint() {
  local scripts=(templates/stack/branch-protection.sh tests/check.sh install.sh)
  if ! command -v shellcheck > /dev/null 2>&1; then
    ok "shell lint: SKIPPED — shellcheck not installed (CI installs it)"
    return 0
  fi
  if shellcheck "${scripts[@]}"; then
    ok "shell lint: ${#scripts[@]} scripts clean"
  else
    bad "shell lint: shellcheck found problems (above)"
  fi
}

# chafe: none yet — okrdev ships three workflow templates adopters run in their
# own repos, and until Phase 0 nothing in this repo had ever executed or parsed
# them. actionlint also runs shellcheck over each `run:` block.
check_workflow_lint() {
  local workflows=(.github/workflows/check.yml templates/github/workflows/ci.yml
                   templates/github/workflows/neon-cleanup.yml templates/github/workflows/okr-gate.yml)
  if ! command -v actionlint > /dev/null 2>&1; then
    ok "workflow lint: SKIPPED — actionlint not installed (CI installs it)"
    return 0
  fi
  if actionlint "${workflows[@]}"; then
    ok "workflow lint: ${#workflows[@]} workflows clean"
  else
    bad "workflow lint: actionlint found problems (above)"
  fi
}

# chafe: templates/stack/README.md ships a copy-pasteable e2e-preview workflow
# that interpolates github.event.deployment.ref straight into a run: block, on a
# deployment_status trigger holding NEON_API_KEY. A branch name carrying a quote
# breaks out and runs arbitrary commands with the secrets in scope; git accepts
# such names. actionlint does not flag it. Found in Phase 1 recon.
check_workflow_injection() {
  # GitHub expands ${{ }} textually before bash sees the script, so attacker-
  # controllable context inside a run: body is a command-injection hole. The
  # fix is always the same: bind it to env: and let bash read a variable.
  # shellcheck disable=SC2016  # awk program: $0 and ${{ }} must stay literal
  local scanner='
    function indent(s) { match(s, /^ */); return RLENGTH }
    function flag() { if ($0 ~ /\$\{\{[ ]*github\.(event|head_ref)/) print FILENAME ":" FNR ": " $0 }
    BEGIN { active = (md ? 0 : 1) }
    md && /^```ya?ml$/ { active = 1; in_run = 0; next }
    md && /^```/       { active = 0; in_run = 0; next }
    !active { next }
    /^[ \t]*(- +)?run:/ { run_col = index($0, "run:") - 1; in_run = 1; flag(); next }
    { if (in_run) {
        if ($0 ~ /^[ \t]*$/) next
        if (indent($0) <= run_col) { in_run = 0; next }
        flag()
      } }'
  local hits
  hits=$( { awk -v md=0 "$scanner" .github/workflows/*.yml templates/github/workflows/*.yml
            awk -v md=1 "$scanner" templates/stack/README.md docs/*.md; } 2>/dev/null )
  if [ -z "$hits" ]; then
    ok "workflow injection: no untrusted github context inside a run: body"
  else
    bad "workflow injection: attacker-controllable context expanded into a shell"
    printf '%s\n' "$hits" | sed 's/^/        /'
    printf '        %s\n' "fix: bind it to env: and reference the variable from bash"
  fi
}

# chafe: docs/live-coached-sessions.md ships a coach-monitor.sh using `stat -f%z`,
# which is BSD-only. On Linux it errors, `|| echo 0` swallows it, and the watcher
# loops forever emitting nothing — a rig that looks armed and transmits nothing.
# The linters pass it clean; only running it on Linux finds this. Phase 1 recon.
check_embedded_script_portability() {
  # Scripts pasted out of docs run on whatever laptop the reader has. A
  # platform-only builtin that fails into a fallback is the worst shape of
  # bug: no crash, no warning, just silence.
  local hits
  hits=$(grep -rn -- 'stat -f%' docs/ templates/ skills/ install.sh 2>/dev/null)
  if [ -z "$hits" ]; then
    ok "embedded scripts: no BSD-only stat syntax"
  else
    bad "embedded scripts: BSD-only \`stat -f%\` fails silently on Linux"
    printf '%s\n' "$hits" | sed 's/^/        /'
    printf '        %s\n' 'fix: use wc -c, which is POSIX and needs no stat dialect'
  fi
}

# chafe: the gate states the KR grammar a FOURTH time at okr-gate.yml:252, as an
# id re-parse, and check_kr_grammar cannot see it — it greps `^KR:`. The two are
# coupled by an unguarded `idMatch[2]`, so a one-sided edit throws a TypeError on
# every PR instead of warning. Found in Phase 1 recon.
check_gate_grammar_tests() {
  local passed
  # The reporter is pinned. node picks it from whether stdout is a TTY, and
  # the default for a redirected run changed between node 22 and 24 — so this
  # counted 7 on CI and 0 on a laptop, from the same command. A count that
  # depends on the runtime's version is not a count.
  if node --test --test-reporter=tap tests/gate-grammar.test.js > /tmp/okrdev-gate-test.log 2>&1; then
    passed=$(grep -c '^ok ' /tmp/okrdev-gate-test.log)
    # "Exit 0" and "tests ran" are different claims. node picks its reporter
    # from whether stdout is a TTY, so redirecting the run can change the
    # output format out from under the count and leave it reporting zero
    # passes next to the word "pass" — green, and meaningless.
    if [ "$passed" -lt 1 ]; then
      bad "okr-gate grammar: node --test exited 0 but $passed tests were counted — nothing was verified"
      printf '        %s\n' "the reporter's output format is not what the count expects:"
      head -3 /tmp/okrdev-gate-test.log | sed 's/^/        /'
    else
      ok "okr-gate grammar: $passed unit tests pass"
    fi
  else
    bad "okr-gate grammar: unit tests failed"
    grep -E '^not ok|Error|assert' /tmp/okrdev-gate-test.log | head -12 | sed 's/^/        /'
  fi
  rm -f /tmp/okrdev-gate-test.log
}

# chafe: none yet — the gate is the only real code okrdev ships, and a syntax
# error in it would surface first in an adopter's Actions log.
check_gate_js_syntax() {
  local yml=templates/github/workflows/okr-gate.yml
  local body tmp
  # github-script evaluates the body inside an AsyncFunction, so its top-level
  # `await` and `return` are legal there and nowhere else. Re-wrap to match.
  body=$(sed -n '/^          script: |$/,$p' "$yml" | tail -n +2 | sed 's/^            //')
  # `mktemp -d` plus a fixed name, not `mktemp --suffix` — the latter is
  # GNU-only, and when it failed on macOS $tmp became empty, the redirect below
  # failed, and `node --check ""` exited 0. The check reported "ok" having
  # parsed nothing. check_gnu_only_syntax now guards the whole class.
  local dir
  dir=$(mktemp -d) || { bad "okr-gate: could not create a temp dir"; return 1; }
  tmp=$dir/gate.js
  { printf 'async function gate(github, core, context, process) {\n'
    printf '%s\n' "$body"
    printf '}\n'; } > "$tmp"
  if [ ! -s "$tmp" ]; then
    bad "okr-gate: extracted an empty script body from $yml — the extractor is broken"
    rm -rf "$dir"
    return 1
  fi
  if node --check "$tmp" 2> /dev/null; then
    ok "okr-gate: embedded script parses"
  else
    bad "okr-gate: embedded script has a syntax error"
    node --check "$tmp" 2>&1 | sed 's/^/        /'
  fi
  rm -rf "$dir"
}

# chafe: none yet — /okrdev:uninstall is documented but unimplemented (parked,
# next-cycle candidate), which is the shape of the mistake this catches.
check_skill_references() {
  # Two names resolve to nothing and are correct today. Both are claims about
  # skills that do not exist: one promised, one refused.
  local exempt="uninstall test"   # uninstall: promoted, not yet built. test: refused in docs/testing.md.
  local name missing=()
  while read -r name; do
    case " $exempt " in *" $name "*) continue ;; esac
    [ -f "skills/$name/SKILL.md" ] || missing+=("$name")
  done < <(grep -rhoE '/okrdev:[a-z-]+' docs/ skills/ templates/ README.md 2>/dev/null | sed 's|/okrdev:||' | sort -u)
  if [ ${#missing[@]} -eq 0 ]; then
    ok "skill references: every /okrdev:<skill> resolves (exempt: $exempt)"
  else
    bad "skill references: no SKILL.md for ${missing[*]}"
  fi
}

# chafe: BOTH defects this suite caught in Phase 1 part 2 hid in the gap between
# a laptop and CI — GNU vs BSD `mktemp`, and node 22 vs 24 changing `node --test`'s
# default reporter out from under a count. A local run you cannot trust sends you
# to Actions to find out, which is the slow loop this repo claims to refuse.
check_local_loop() {
  local ci_node local_node hooks notes=()
  ci_node=$(sed -n "s/.*node-version: *'\{0,1\}\([0-9]*\).*/\1/p" .github/workflows/check.yml | head -1)
  local_node=$(node --version 2>/dev/null | sed 's/^v\([0-9]*\).*/\1/')
  if [ -n "$ci_node" ] && [ -n "$local_node" ] && [ "$ci_node" != "$local_node" ]; then
    notes+=("node ${local_node} here vs ${ci_node} on CI — the two disagreed about \`node --test\` output once already")
  fi
  # Not on CI: the hook is a laptop concern, and CI has no laptop.
  if [ -z "${CI:-}" ]; then
    hooks=$(git config --get core.hooksPath 2>/dev/null)
    [ "$hooks" = "tests/hooks" ] || notes+=("pre-push hook not wired — \`git config core.hooksPath tests/hooks\`")
  fi
  command -v shellcheck > /dev/null 2>&1 || notes+=("shellcheck missing — its check is skipping, not passing")
  command -v actionlint > /dev/null 2>&1 || notes+=("actionlint missing — its check is skipping, not passing")
  # Advisory on purpose. A contributor on the wrong node should be told, not
  # blocked — but never left to assume a green run here means a green run there.
  if [ ${#notes[@]} -eq 0 ]; then
    ok "local loop: matches CI — a green run here means a green run there"
  else
    ok "local loop: ADVISORY — this run is weaker than CI will be"
    printf '        - %s\n' "${notes[@]}"
  fi
}

# chafe: this suite's own admission rule, made mechanical — the plan promises
# growth only from chafe, and a promise nothing checks is theater.
check_chafe_comments() {
  local undocumented=() found=0 line
  # Walk the file, remembering whether the comment block sitting directly
  # above each check named a chafe. Anything else — code, a blank line —
  # ends the block, so a chafe line can only vouch for the check it precedes.
  while read -r line; do
    case "$line" in
      TOTAL:*) found=${line#TOTAL:} ;;
      *)       undocumented+=("$line") ;;
    esac
  done < <(awk '
    /^# chafe:/            { chafe = 1; next }
    /^#/                   { next }
    /^check_[a-z_]+\(\) \{/ { total++; name = $1; sub(/\(\)$/, "", name)
                              if (!chafe) print name
                              chafe = 0; next }
                           { chafe = 0 }
    END                    { print "TOTAL:" total + 0 }
  ' "${BASH_SOURCE[0]}")
  # A scan that finds nothing passes vacuously — the exact failure this file
  # exists to catch. Insist it found the other checks before believing it.
  if [ "$found" -lt 2 ]; then
    bad "chafe comments: scanned $found checks — the scan itself is broken"
  elif [ ${#undocumented[@]} -eq 0 ]; then
    ok "all $found checks name the chafe that motivated them"
  else
    bad "checks with no '# chafe:' line: ${undocumented[*]}"
  fi
}

# chafe: the cycle file and the check-ins state each KR's confidence twice, and
# nothing kept them equal. Live near-miss found writing this check: the naive
# "newest check-in by filename" reads 2026-W32 — a file created only to log a
# judgment call, with a header-only confidence table — and passes vacuously
# while the real numbers came from W31. Handoff issue #11, item (a).
check_confidence_mirror() {
  local corpora=(okrdev examples/acme-fitness)
  local root cycle_file cycle checkin report status=0
  for root in "${corpora[@]}"; do
    local active
    active=$(grep -l '^status: active' "$root"/okrs/*.md 2> /dev/null)
    if [ -z "$active" ]; then
      bad "confidence mirror: $root has no cycle file with 'status: active'"
      status=1
      continue
    fi
    # At most one active cycle — docs/testing.md names two-actives as a fixture
    # the suite must reject. Taking the first match would pick a winner and
    # report green, which is how the invariant would get lost.
    if [ "$(printf '%s\n' "$active" | wc -l | tr -d ' ')" -ne 1 ]; then
      bad "confidence mirror: $root has more than one cycle with 'status: active'"
      printf '%s\n' "$active" | sed 's/^/        /'
      status=1
      continue
    fi
    cycle_file=$active
    cycle=$(basename "$cycle_file" .md)
    # "Newest" is a lexical compare, which is only chronological while every
    # filename is fixed-width: 2026-W9.md sorts after 2026-W28.md and would
    # silently select the wrong check-in. `date +%G-W%V` zero-pads, so this can
    # only arrive by hand — which is exactly when a silent wrong answer is
    # worst. Refuse the input instead of mis-sorting it.
    local misnamed
    misnamed=$(find "$root/checkins/$cycle" -name '*.md' 2> /dev/null |
      grep -vE '/[0-9]{4}-W[0-9]{2}\.md$')
    if [ -n "$misnamed" ]; then
      bad "confidence mirror: check-in filenames must be <yyyy>-W<nn>.md or 'newest' is not chronological"
      printf '%s\n' "$misnamed" | sed 's/^/        /'
      status=1
      continue
    fi
    checkin=$(newest_held_checkin "$root/checkins/$cycle")
    if [ -z "$checkin" ]; then
      # Not "no check-ins yet, fine" — a live cycle whose confidences are
      # mirrored nowhere is the state this check exists to notice.
      bad "confidence mirror: $root/checkins/$cycle has no held check-in (no table with KR rows)"
      status=1
      continue
    fi
    report=$(awk -v cyc="$cycle_file" -v chk="$checkin" '
      function trim(s) { gsub(/^[ \t]+|[ \t]+$/, "", s); return s }
      BEGIN {
        while ((getline line < cyc) > 0) {
          if (line ~ /^## KR[0-9]+\.[0-9]+:/) { split(line, a, ":"); id = trim(substr(a[1], 4)); cur = id }
          else if (cur != "" && line ~ /^Status:[ \t]*dropped/) { dropped[cur] = 1 }
          else if (id != "" && line ~ /^Confidence:/) {
            # Strip a trailing comment before trimming: the cycle TEMPLATE
            # ships `Confidence: 0.5  # a good stretch KR is a coin flip`, so a
            # DRI who keeps the hint would otherwise compare the whole line.
            v = line; sub(/^Confidence:/, "", v); sub(/#.*$/, "", v)
            want[id] = trim(v); order[++n] = id; id = ""
          }
        }
        while ((getline line < chk) > 0) {
          if (line ~ /^\|[ \t]*KR[0-9]/) {
            split(line, f, "|"); k = trim(f[2]); got[k] = trim(f[5]); rows++
          }
        }
        # Both sides must have found something. A parser that silently matched
        # nothing would report "all mirrored" over two empty sets.
        if (n == 0)    { print "PARSE|no KR headings with a Confidence: line in " cyc; exit }
        if (rows == 0) { print "PARSE|no KR rows parsed out of " chk; exit }
        for (i = 1; i <= n; i++) {
          id = order[i]
          # A dropped KR is CHECKED whenever it appears — it still carries a
          # confidence and is the one most likely to rot — but it is not
          # REQUIRED to appear, because skills/checkin/SKILL.md tells the coach
          # "one row per KR (skip Status: dropped ones)". Requiring it would go
          # red on a correctly written check-in; requiring nothing would stop
          # checking it at all. Asserting over the intersection decides neither
          # reading, which is the rule for doctrine the docs have not settled.
          # The acme KR1.2 row is dropped and present in W36, so this path has
          # live cover today.
          if (!(id in got)) {
            if (!(id in dropped)) print "MISS|" id " has Confidence: " want[id] " but no row in the check-in"
          }
          else if (got[id] != want[id]) print "DIFF|" id " cycle says " want[id] ", check-in Now says " got[id]
          seen[id] = 1
        }
        for (k in got) if (!(k in seen)) print "EXTRA|" k " has a check-in row but no KR in the cycle file"
        print "COUNT|" n
      }')
    # The count line is always emitted, so "a COUNT line exists" is not the
    # success condition — the absence of problem lines is. Getting this
    # backwards made the check report "5 KRs match" over a deliberately
    # corrupted table; caught by mutation-testing it, which is why the doctrine
    # says to.
    local problems count
    problems=$(printf '%s\n' "$report" | grep -v '^COUNT|')
    count=$(printf '%s\n' "$report" | sed -n 's/^COUNT|//p')
    if [ -n "$count" ] && [ -z "$problems" ]; then
      ok "confidence mirror: $root — $count KRs match $(basename "$checkin")"
    else
      bad "confidence mirror: $root disagrees with $(basename "$checkin")"
      printf '%s\n' "$problems" | sed 's/^[A-Z]*|/        /'
      status=1
    fi
  done
  return $status
}

# chafe: docs/adoption.md listed a cycle file under Level 1's "What installs"
# while skills/install/SKILL.md says in bold not to create one. That
# contradiction sat on main and had to be escalated to the DRI by hand
# (handoff issue #11, decision 1) — a reviewer-class coherence breach of
# exactly the kind the cycle's health metric names, and nothing mechanical
# could see it. The manifest is what a check can read.
check_footprint_manifest() {
  local manifest=tests/install-footprint.md
  local skill=skills/install/SKILL.md
  local t missing=() outside=() unlisted=() phantom=() all copied refs status=0
  [ -f "$manifest" ] || { bad "footprint: $manifest is missing"; return 1; }

  # shellcheck disable=SC2016  # backticks are markdown code spans, not a subshell
  local span='`templates/[A-Za-z0-9._/-]+`'
  all=$(grep -oE "$span" "$manifest" | tr -d '`' | sort -u)
  # Table A only — the per-level install list. Scoping matters: the manifest
  # also carries a table of templates install deliberately does NOT copy, and
  # comparing against the whole document would make the next assert vacuous by
  # construction (every template listed somewhere ⇒ nothing can ever be missing).
  copied=$(sed -n '/^| Level | Destination/,/^$/p' "$manifest" | grep -oE "$span" | tr -d '`' | sort -u)
  refs=$(grep -oE "$span" "$skill" | tr -d '`' | sort -u)
  if [ -z "$all" ] || [ -z "$copied" ] || [ -z "$refs" ]; then
    bad "footprint: scan found nothing (manifest=$(printf '%s' "$all" | grep -c .) copied=$(printf '%s' "$copied" | grep -c .) skill=$(printf '%s' "$refs" | grep -c .)) — the scan itself is broken"
    return 1
  fi

  # Every template the manifest names must exist. A manifest that points at a
  # deleted template is worse than none: it reports green about a broken install.
  while read -r t; do
    [ -n "$t" ] || continue
    [ -e "$t" ] || missing+=("$t")
  done <<< "$all"

  # Every template the install skill reaches for must be accounted for — either
  # as a copy (table A) or as a deliberate non-copy (table B). This is the half
  # that catches install GROWING a write nobody wrote down.
  while read -r t; do
    [ -n "$t" ] || continue
    printf '%s\n' "$all" | grep -qxF "$t" || unlisted+=("$t")
  done <<< "$refs"

  # And the other direction: the manifest may not claim a copy install never
  # makes. Without this the manifest could drift into wishful thinking and
  # still pass everything above.
  while read -r t; do
    [ -n "$t" ] || continue
    printf '%s\n' "$refs" | grep -qxF "$t" || phantom+=("$t")
  done <<< "$copied"

  # The health metric's red line, mechanized: okrdev/, the marked CLAUDE.md
  # block, and .github/ at Level 2. Anything else is a breach by definition.
  while read -r t; do
    [ -n "$t" ] || continue
    case "$t" in okrdev/* | CLAUDE.md | .github/*) ;; *) outside+=("$t") ;; esac
  done < <(sed -n '/^| Level | Destination/,/^$/p' "$manifest" |
    awk -F'|' 'NR > 2 { gsub(/^[ \t]+|[ \t]+$/, "", $3); sub(/ \(marked block only\)$/, "", $3)
                        gsub(/`/, "", $3); if ($3 != "" && $3 != "—") print $3 }' | sort -u)

  if [ ${#missing[@]} -gt 0 ]; then
    bad "footprint: manifest names templates that do not exist: ${missing[*]}"
    status=1
  fi
  if [ ${#unlisted[@]} -gt 0 ]; then
    bad "footprint: $skill uses templates the manifest does not list: ${unlisted[*]}"
    status=1
  fi
  if [ ${#phantom[@]} -gt 0 ]; then
    bad "footprint: the manifest claims installs $skill never makes: ${phantom[*]}"
    status=1
  fi
  if [ ${#outside[@]} -gt 0 ]; then
    bad "footprint: destinations outside the red line (okrdev/, CLAUDE.md, .github/): ${outside[*]}"
    status=1
  fi
  [ $status -eq 0 ] && ok "footprint: $(printf '%s' "$copied" | grep -c .) templates copied by install, $(printf '%s' "$all" | grep -c .) accounted for, every destination inside the red line"
  return $status
}

# chafe: docs/adoption.md's Level 1 "What installs" listed a cycle file and a
# checkins/ directory that install has never written — the contradiction that
# blocked the footprint manifest and had to go to the DRI as a ruling (handoff
# issue #11, decision 1). The manifest alone would not have caught it: nothing
# compared the adopter-facing description to the install skill. This does.
check_adoption_install_list() {
  local doc=docs/adoption.md manifest=tests/install-footprint.md
  local dests claimed p missing=() found=0
  # The manifest's destination column is the source of truth: it is checked
  # against the install skill in both directions by check_footprint_manifest,
  # so agreeing with it means agreeing with what install actually does.
  dests=$(sed -n '/^| Level | Destination/,/^$/p' "$manifest" |
    awk -F'|' 'NR > 2 { gsub(/^[ \t]+|[ \t]+$/, "", $3); sub(/ \(marked block only\)$/, "", $3)
                        gsub(/`/, "", $3); if ($3 != "" && $3 != "—") print $3 }' | sort -u)
  # Every repo path adoption.md promises a level installs. Bounded on purpose:
  # only backticked spans that name a destination inside the red line, only
  # inside a "**What installs:**" block. Not a prose parser — a token scan over
  # one named paragraph, the same shape as the glossary row count.
  # The block ends at the next bolded lead-in or the next heading, NOT at the
  # next blank line: Level 2 states its installs as a bulleted list, and a
  # blank-line terminator would silently read only its first sentence.
  # shellcheck disable=SC2016  # backticks are markdown code spans, not a subshell
  local dest_span='`(okrdev|\.github)/[A-Za-z0-9._<>/-]*`|`CLAUDE\.md`'
  claimed=$(awk '/^\*\*What installs:\*\*/         { inblock = 1; print; next }
                 /^\*\*/ || /^#{2,3} /             { inblock = 0 }
                 inblock' "$doc" |
    grep -oE "$dest_span" | tr -d '`' | sort -u)
  if [ -z "$claimed" ]; then
    bad "adoption list: no installed paths found in $doc — the scan is broken"
    return 1
  fi
  while read -r p; do
    [ -n "$p" ] || continue
    found=$((found + 1))
    printf '%s\n' "$dests" | grep -qxF "$p" || missing+=("$p")
  done <<< "$claimed"
  if [ ${#missing[@]} -eq 0 ]; then
    ok "adoption list: all $found paths $doc promises are ones install actually writes"
  else
    bad "adoption list: $doc promises paths install never writes: ${missing[*]}"
    printf '        %s\n' "either $doc is wrong, or the install skill and $manifest are — one of them has to give"
  fi
}

# chafe: none yet — green on arrival, so it was mutation-tested instead (break
# one number, watch it fail, put it back). Install copies the config template
# verbatim and never sets the version, so a skew here makes every adopter
# record a version they don't have, silently. Handoff issue #11, item (c).
check_version_sync() {
  # Deliberately NOT asserted: okrdev/config.md (0.1.0) and the acme example.
  # Those record what was installed, not what ships — see the versioning policy
  # in docs/adoption.md § Upgrading. Asserting them would freeze a lie.
  local tmpl_version plugin_version
  tmpl_version=$(sed -n 's/^okrdev_version:[[:space:]]*\([0-9.]*\).*/\1/p' templates/okrdev/config.md | head -1)
  plugin_version=$(jq -r '.version' .claude-plugin/plugin.json)
  if [ -z "$tmpl_version" ]; then
    bad "version sync: no okrdev_version found in templates/okrdev/config.md"
  elif [ "$tmpl_version" = "$plugin_version" ]; then
    ok "version sync: template config and plugin.json both say $plugin_version"
  else
    bad "version sync: templates/okrdev/config.md says $tmpl_version, plugin.json says $plugin_version"
    printf '        %s\n' "policy: any file okrdev puts in your repo changes → bump both markers together (docs/adoption.md § Upgrading)"
  fi
}

# chafe: this repo's own install sat at 0.1.0 while it shipped 0.4.0 — three
# releases of its own scaffolding that it had never run. Captured 2026-08-04 in
# the parking lot's sync-wrinkles entry and still unfixed on 2026-08-07, which
# is the parked-but-unfixed gap docs/testing.md says a required check closes.
# The dogfood claim in okrdev/config.md ("okrdev runs on itself") is only true
# if it runs on the version it ships.
check_dogfood_current() {
  # okrdev's OWN install only. examples/acme-fitness is fiction and is
  # deliberately left on an old marker — a worked example of an adopter who
  # has not upgraded is worth more than one that is magically current.
  local live shipped
  live=$(sed -n 's/^okrdev_version:[[:space:]]*\([0-9.]*\).*/\1/p' okrdev/config.md | head -1)
  shipped=$(jq -r '.version' .claude-plugin/plugin.json)
  if [ -z "$live" ]; then
    bad "dogfood: no okrdev_version in okrdev/config.md"
  elif [ "$live" = "$shipped" ]; then
    ok "dogfood: this repo runs the okrdev it ships ($shipped)"
  else
    bad "dogfood: this repo runs okrdev $live but ships $shipped"
    printf '        %s\n' "a release is not done until okrdev has upgraded itself (docs/adoption.md § Upgrading)"
    printf '        %s\n' "run the upgrade — coach block, any okrdev-installed .github/ files, config keys — then move the marker"
  fi
}

# chafe: docs/shipping-explained.md opens by promising "one story, ten words,
# one table" over a glossary that has held eleven rows since the demo row
# landed. Found while specifying the adopter prescription (docs/testing.md).
check_glossary_promise() {
  local doc=docs/shipping-explained.md
  local promise word rows n
  # Unwrapped first: the sentence is hard-wrapped at 95 columns and today the
  # break falls between "one" and "story", so a line-oriented grep sees neither
  # half. A check that can be defeated by a reflow is a check that will be.
  promise=$(tr '\n' ' ' < "$doc" | grep -oE 'one story, [a-z]+ words, one table' | head -1)
  if [ -z "$promise" ]; then
    bad "glossary promise: the 'one story, N words, one table' sentence is gone from $doc"
    return 1
  fi
  word=${promise#one story, }
  word=${word% words, one table}
  case "$word" in
    seven) n=7 ;; eight) n=8 ;; nine) n=9 ;; ten) n=10 ;; eleven) n=11 ;;
    twelve) n=12 ;; thirteen) n=13 ;; fourteen) n=14 ;; fifteen) n=15 ;;
    *) bad "glossary promise: '$word' is not a number word this check knows — add it"; return 1 ;;
  esac
  rows=$(grep -c '^| \*\*' "$doc")
  if [ "$rows" -eq "$n" ]; then
    ok "glossary promise: $doc promises $word words and defines $rows"
  else
    bad "glossary promise: $doc promises $word ($n) words, the glossary defines $rows"
    printf '        %s\n' "fix whichever is wrong — the sentence at the top, or the table"
  fi
}

# chafe: the same number is stated in up to six files and the copies have to
# move together, but only where a single literal covers every legitimate use.
# The three thresholds whose phrasing AND numeral both vary are in
# DO_NOT_FREEZE instead — see the entries below. Handoff issue #11, item (d).
check_threshold_tokens() {
  local staleness="CLAUDE.md templates/CLAUDE-okrdev.md docs/ai-coach.md docs/rituals.md skills/coach/SKILL.md skills/checkin/SKILL.md"
  local share="docs/method.md docs/rituals.md docs/ai-coach.md skills/coach/SKILL.md skills/checkin/SKILL.md"
  local sandbag="docs/method.md docs/ai-coach.md skills/coach/SKILL.md skills/checkin/SKILL.md skills/retro/SKILL.md"
  # docs/testing.md quotes all four while explaining this very check. It states
  # nothing — it describes — so it is exempt from the "and nowhere else" half
  # everywhere, rather than being reworded to dodge its own greps.
  local plan=docs/testing.md
  local specs=(
    "10 days|$staleness|$plan"
    "30% of PRs|$share|$plan"
    "5% of PRs|$share|$plan"
    "60% of the cycle|$sandbag|$plan"
  )
  local spec token files exempt f status=0 msg anchored
  for spec in "${specs[@]}"; do
    IFS='|' read -r token files exempt <<< "$spec"
    # Anchored on a non-digit, because a plain substring match is satisfied by
    # a bigger number: `5% of PRs` is a substring of `15% of PRs`, so someone
    # could change the threshold in one file and this check would still pass.
    # Same shape for `10 days` inside `110 days`.
    anchored="(^|[^0-9])$(printf '%s' "$token" | sed 's/[.[\*^$]/\\&/g')"
    msg=""
    for f in $files; do
      grep -qE -- "$anchored" "$f" || msg+=" states-it-no-longer:$f"
    done
    # The other half: nowhere else may state it. A threshold that grows a
    # seventh home is exactly how the copies start disagreeing, and a
    # positive-only assert never notices.
    while read -r f; do
      case " $files $exempt " in *" $f "*) continue ;; esac
      msg+=" also-states-it:$f"
    done < <(grep -rlE --include='*.md' -- "$anchored" . 2> /dev/null | sed 's|^\./||' | sort)
    if [ -z "$msg" ]; then
      ok "threshold '$token': stated in all $(printf '%s' "$files" | wc -w | tr -d ' ') files, and nowhere else"
    else
      bad "threshold '$token' drifted:$msg"
      status=1
    fi
  done
  # Staleness only: the negative tokens. Scoped to the files that STATE the
  # rule, never repo-wide — "9 days" is the canonical output-vs-outcome example
  # in method.md and evidence.md and acme's KR1.2 target, so a repo-wide
  # negative is permanently red on documents that are correct.
  # The hyphenated spelling is live in the repo (acme's W28 says "9-day
  # median"), so it is a form a future edit can reach for. Both are checked.
  local near
  for near in '9 days' '11 days' '9-day' '11-day'; do
    for f in $staleness; do
      if grep -qE -- "(^|[^0-9])$near" "$f"; then
        bad "threshold: '$near' appears in $f, which states the 10-day rule"
        status=1
      fi
    done
  done
  [ $status -eq 0 ] && ok "threshold: no near-miss staleness numbers in the 6 files that state the rule"
  return $status
}

# chafe: check_gate_js_syntax used `mktemp --suffix=.js`, which is GNU-only. On
# macOS mktemp errors, $tmp is empty, the redirect fails, and `node --check ""`
# exits 0 — so the check printed "ok" having parsed nothing, on every laptop in
# the project. CI is ubuntu-latest, so CI never saw it. Found running this
# suite locally for handoff issue #11. Sibling of the BSD-only check above:
# same failure shape, opposite platform.
check_gnu_only_syntax() {
  # Both directions matter now. This suite already refuses BSD-only syntax in
  # scripts it ships to readers; it has to refuse GNU-only syntax in the
  # scripts it runs itself, or "the checks passed" means "the checks passed on
  # Linux" and nobody is told which.
  # The pattern list matches itself, so it carries a sentinel and the results
  # are filtered by it. Same shape as check_workflow_injection's awk program:
  # a scanner that flags its own source teaches people to ignore the scanner.
  local pattern='mktemp[^|;&]*--suffix|stat -c|date -[dr] |readlink -f|grep -P|base64 -w|find [^|;&]*-printf|head -n -|xargs -r' # portability-scanner
  local hits
  hits=$(grep -rnE "$pattern" tests/ templates/ docs/ skills/ install.sh 2> /dev/null |
    grep -v 'portability-scanner' |
    grep -vE '^[^:]*:[0-9]+:[[:space:]]*#')   # comments describe these bugs; they don't run
  if [ -z "$hits" ]; then
    ok "portability: no GNU-only syntax in scripts this repo runs or ships"
  else
    bad "portability: GNU-only syntax fails on macOS/BSD — where most of this project is written"
    printf '%s\n' "$hits" | sed 's/^/        /'
    printf '        %s\n' 'fix: use the POSIX form, or one that works on both'
  fi
}

# DO_NOT_FREEZE — "<what this suite must never assert>|<file>|<the divergent text>"
# Each entry asserts its divergence still EXISTS. When one stops being true,
# check_do_not_freeze fails and the entry is either promoted to a real rule
# through a doctrine PR, or deleted. The list cannot rot into a stale comment.
DO_NOT_FREEZE=(
  "check-in health rows paraphrase the cycle's red lines|okrdev/checkins/2026-Q3/2026-W31.md|reviewer-class contradiction on main >1 week"
  "thresholds share their number, never their phrasing|docs/ai-coach.md|more than 10 days old"
  # The acme example ships a SAMPLED cycle — W28, W29, W36 standing in for ten
  # weeks — so its Prev column deliberately does not chain. The anchor is the
  # proof: W36 reads Prev 0.9 for KR2.1 while W29 left it at Now 0.75, because
  # the weeks that moved it are not in the repo (W36 itself cites a W33 that
  # does not exist). Backfilling check-ins to satisfy a chaining assert would
  # be inventing evidence in the one directory that exists to teach people what
  # evidence looks like. Handoff issue #11, item (f).
  "the acme example's check-ins chain week to week|examples/acme-fitness/checkins/2026-Q3/2026-W36.md|| KR2.1 | jordan | 0.9 | 1.0 |"
  # Three thresholds vary in phrasing AND numeral across their copies, so a
  # token assert cannot cover them without picking a winner — which would be a
  # doctrine decision made inside a test. Each entry pins one phrasing that
  # must keep existing, so a future session cannot quietly normalize them into
  # assertability without this list failing first. Handoff issue #11, item (d).
  "the emergency ceiling's numeral: 'two' and '2' both live|docs/method.md|more than two a cycle"
  "the flat-confidence window's numeral: 'three' and '3' both live|docs/method.md|three check-ins"
  "4 box-hours means three different things|okrdev/config.md|side_quest_box_hours_per_week"
)

# chafe: this suite's other admission rule. A do-not-freeze list written as a
# comment is inert; written as negative tests it forces graduate-or-delete.
check_do_not_freeze() {
  local entry what file text stale=()
  for entry in "${DO_NOT_FREEZE[@]}"; do
    IFS='|' read -r what file text <<< "$entry"
    grep -qF -- "$text" "$file" || stale+=("$what ($file)")
  done
  if [ ${#stale[@]} -eq 0 ]; then
    ok "do-not-freeze: ${#DO_NOT_FREEZE[@]} deliberate divergences still present"
  else
    bad "do-not-freeze entries no longer apply — graduate them or delete them:"
    printf '        %s\n' "${stale[@]}"
  fi
}

# ── Run ────────────────────────────────────────────────────────────────────

printf 'okrdev checks\n\n'
check_coach_block
check_branch_protection_bad_input
check_kr_grammar
check_judgment_call_format
check_plugin_manifests
check_headless_install
check_shell_lint
check_workflow_lint
check_workflow_injection
check_embedded_script_portability
check_gnu_only_syntax
check_gate_js_syntax
check_gate_grammar_tests
check_skill_references
check_confidence_mirror
check_footprint_manifest
check_adoption_install_list
check_version_sync
check_dogfood_current
check_glossary_promise
check_threshold_tokens
check_local_loop
check_chafe_comments
check_do_not_freeze

printf '\n'
if [ "$failures" -eq 0 ]; then
  printf 'all checks passed\n'
  exit 0
fi
printf '%d check(s) failed\n' "$failures"
exit 1
