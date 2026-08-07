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

# chafe: branch-protection.sh shipped with die() called before its definition
# and nothing caught it (fixed in the Phase 0 PR). shellcheck catches that whole
# class. Skipped, loudly, when the tool is absent — a check that quietly does
# nothing on a laptop is worse than one that says it didn't run.
check_shell_lint() {
  local scripts=(templates/stack/branch-protection.sh tests/check.sh)
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
  hits=$(grep -rn -- 'stat -f%' docs/ templates/ skills/ 2>/dev/null)
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
  if node --test tests/gate-grammar.test.js > /tmp/okrdev-gate-test.log 2>&1; then
    ok "okr-gate grammar: $(grep -c '^ok ' /tmp/okrdev-gate-test.log) unit tests pass"
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
  tmp=$(mktemp --suffix=.js)
  { printf 'async function gate(github, core, context, process) {\n'
    printf '%s\n' "$body"
    printf '}\n'; } > "$tmp"
  if node --check "$tmp" 2>/dev/null; then
    ok "okr-gate: embedded script parses"
  else
    bad "okr-gate: embedded script has a syntax error"
    node --check "$tmp" 2>&1 | sed 's/^/        /'
  fi
  rm -f "$tmp"
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

# DO_NOT_FREEZE — "<what this suite must never assert>|<file>|<the divergent text>"
# Each entry asserts its divergence still EXISTS. When one stops being true,
# check_do_not_freeze fails and the entry is either promoted to a real rule
# through a doctrine PR, or deleted. The list cannot rot into a stale comment.
DO_NOT_FREEZE=(
  "check-in health rows paraphrase the cycle's red lines|okrdev/checkins/2026-Q3/2026-W31.md|reviewer-class contradiction on main >1 week"
  "thresholds share their number, never their phrasing|docs/ai-coach.md|more than 10 days old"
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
check_shell_lint
check_workflow_lint
check_workflow_injection
check_embedded_script_portability
check_gate_js_syntax
check_gate_grammar_tests
check_skill_references
check_chafe_comments
check_do_not_freeze

printf '\n'
if [ "$failures" -eq 0 ]; then
  printf 'all checks passed\n'
  exit 0
fi
printf '%d check(s) failed\n' "$failures"
exit 1
