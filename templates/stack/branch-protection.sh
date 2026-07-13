#!/usr/bin/env bash
#
# okrdev branch protection — protects the default branch the okrdev way.
#
# What this script does, in order:
#
#   1. Makes merges squash-only (and turns on delete-branch-on-merge + auto-merge).
#      Why: one PR = one commit on main. The PR's `KR:` line rides in the squash
#      commit message, so the coach's drift check reads alignment straight out of
#      git history, and reverting a bad change is one clean commit. Auto-merge is
#      used by the state-PR fallback described below.
#
#   2. Creates (or updates) a branch ruleset on the default branch:
#        - pull request required: 1 approval + review from Code Owners
#        - required status check: "ci" (override with OKRDEV_REQUIRED_CHECK)
#        - squash the only allowed merge method
#        - no force pushes, no branch deletion
#      Why: CODEOWNERS is toothless and required checks are decoration unless the
#      branch actually enforces them. Code Owners review only bites where a
#      .github/CODEOWNERS file maps paths to reviewers (template:
#      templates/github/CODEOWNERS).
#
#   3. Adds a bypass so okrdev state writes — parking lot captures and check-in
#      files under okrdev/** — can land directly on main. A ten-second capture
#      can't wait on CI.
#
#      Honesty about the mechanics: GitHub cannot scope a ruleset bypass to file
#      paths, so the bypass is ACTOR-scoped — repository admins may push directly —
#      and the PATH scoping to okrdev/** is enforced by the coach's contract: the
#      only direct pushes it ever makes touch okrdev/** ; every other change goes
#      through a PR. If your team refuses direct pushes entirely, delete the
#      bypass_actors entry below and re-run; the coach falls back to auto-merged
#      state PRs (see docs/adoption.md).
#
# Requirements:
#   - gh CLI (https://cli.github.com), authenticated as a repo admin.
#   - Plan: branch rulesets are free on PUBLIC repos on every GitHub plan.
#     PRIVATE repos need GitHub Pro (personal) or GitHub Team / Enterprise (org).
#     If the API answers with an upgrade message, that is the wall you hit.
#
# Usage:
#   ./branch-protection.sh [owner/repo]        # defaults to the repo in the cwd
#   OKRDEV_REQUIRED_CHECK="your-job-name" ./branch-protection.sh owner/repo
#     # the required check must exactly match — case-sensitively — the job name
#     # your CI produces; for templates/github/workflows/ci.yml that's "ci",
#     # which is also the default here. Running okr-gate in
#     # strict mode? Add its check context to the rules below as well.
#
# Idempotent-ish: re-running updates the existing ruleset instead of duplicating it.

set -euo pipefail

RULESET_NAME="okrdev-protect-main"
REQUIRED_CHECK="${OKRDEV_REQUIRED_CHECK:-ci}"

say() { printf '%s\n' "$*"; }
die() { printf 'error: %s\n' "$*" >&2; exit 1; }

# --- Preflight -----------------------------------------------------------------

command -v gh >/dev/null 2>&1 \
  || die "gh CLI not found. Install it from https://cli.github.com and re-run."

gh auth status >/dev/null 2>&1 \
  || die "gh is not authenticated. Run: gh auth login"

REPO="${1:-$(gh repo view --json nameWithOwner --jq .nameWithOwner 2>/dev/null || true)}"
[ -n "$REPO" ] \
  || die "no repo given and none detected in the cwd. Usage: ./branch-protection.sh owner/repo"

repo_info=$(gh api "repos/$REPO" --jq '[.default_branch, .visibility] | @tsv' 2>/dev/null) \
  || die "cannot read repos/$REPO — check the name, and that your token has admin access."
DEFAULT_BRANCH=${repo_info%%$'\t'*}
VISIBILITY=${repo_info##*$'\t'}

say "Repo:            $REPO ($VISIBILITY)"
say "Default branch:  $DEFAULT_BRANCH"
say "Required check:  $REQUIRED_CHECK"
say ""

if [ "$VISIBILITY" != "public" ]; then
  say "note: $REPO is $VISIBILITY. Branch rulesets on private repos require GitHub Pro"
  say "      (personal accounts) or GitHub Team / Enterprise (organizations)."
  say ""
fi

# --- 1. Merge policy: squash-only ------------------------------------------------

say "==> Setting merge policy: squash-only, delete head branches on merge, allow auto-merge"
gh api -X PATCH "repos/$REPO" \
  -F allow_squash_merge=true \
  -F allow_merge_commit=false \
  -F allow_rebase_merge=false \
  -F delete_branch_on_merge=true \
  -F allow_auto_merge=true \
  --silent \
  || die "could not update merge settings — this needs admin permission on $REPO."

# --- 2 + 3. The ruleset -----------------------------------------------------------

# Bypass actors: actor_type RepositoryRole with actor_id 5 = the built-in Admin
# role (2 = Maintain, 4 = Write — don't widen this without a reason). In an
# organization you can grant a team instead:
#   { "actor_id": <gh api orgs/<org>/teams/<slug> --jq .id>, "actor_type": "Team", "bypass_mode": "always" }
# To refuse direct pushes entirely (state-PR fallback), set this to [] .
BYPASS_ACTORS='[{ "actor_id": 5, "actor_type": "RepositoryRole", "bypass_mode": "always" }]'

build_payload() {
  cat <<JSON
{
  "name": "$RULESET_NAME",
  "target": "branch",
  "enforcement": "active",
  "conditions": {
    "ref_name": { "include": ["~DEFAULT_BRANCH"], "exclude": [] }
  },
  "bypass_actors": $BYPASS_ACTORS,
  "rules": [
    { "type": "deletion" },
    { "type": "non_fast_forward" },
    {
      "type": "pull_request",
      "parameters": {
        "required_approving_review_count": 1,
        "require_code_owner_review": true,
        "dismiss_stale_reviews_on_push": true,
        "require_last_push_approval": false,
        "required_review_thread_resolution": false,
        "allowed_merge_methods": ["squash"]
      }
    },
    {
      "type": "required_status_checks",
      "parameters": {
        "strict_required_status_checks_policy": false,
        "required_status_checks": [
          { "context": "$REQUIRED_CHECK" }
        ]
      }
    }
  ]
}
JSON
}

# Idempotency: update the ruleset if one with our name already exists.
existing_id=$(gh api "repos/$REPO/rulesets?includes_parents=false" \
  --jq "map(select(.name == \"$RULESET_NAME\")) | .[0].id // empty" 2>/dev/null || true)

if [ -n "$existing_id" ]; then
  say "==> Updating existing ruleset '$RULESET_NAME' (id $existing_id)"
  method="PUT"; endpoint="repos/$REPO/rulesets/$existing_id"
else
  say "==> Creating ruleset '$RULESET_NAME'"
  method="POST"; endpoint="repos/$REPO/rulesets"
fi

apply_ruleset() {
  build_payload | gh api -X "$method" "$endpoint" --input - --silent 2>&1
}

if ! out=$(apply_ruleset); then
  if grep -qiE 'upgrade|only available|billing|plan' <<<"$out"; then
    die "GitHub refused the ruleset — plan limitation. Rulesets on private repos need
       GitHub Pro (personal) or Team/Enterprise (org). Options: upgrade the plan, make
       the repo public, or apply what your plan allows by hand in Settings -> Rules."
  fi
  if grep -qi 'bypass' <<<"$out"; then
    say "note: this repo refused the role-based bypass actor. Retrying without a bypass —"
    say "      okrdev state writes will use the auto-merged state-PR fallback instead."
    BYPASS_ACTORS='[]'
    out=$(apply_ruleset) || die "ruleset call failed: $out"
  else
    die "ruleset call failed: $out"
  fi
fi

# --- Summary ---------------------------------------------------------------------

say ""
say "Done. What is now true on $REPO:"
say "  - $DEFAULT_BRANCH accepts changes only via pull request: 1 approval + Code Owners review"
say "  - required status check: '$REQUIRED_CHECK' (must match the job name in .github/workflows/ci.yml)"
say "  - squash merges only; no force pushes; no branch deletion"
if [ "$BYPASS_ACTORS" != "[]" ]; then
  say "  - repository admins bypass the ruleset — reserved, by the coach's contract, for"
  say "    okrdev/** state writes only. Everything else still goes through a PR."
else
  say "  - no bypass actors: okrdev state writes will go through auto-merged state PRs."
fi
say ""
say "Verify:"
say "  1. Settings -> Rules -> Rulesets shows '$RULESET_NAME' as Active."
say "  2. A trivial PR is blocked from merging until '$REQUIRED_CHECK' is green and a review lands."
say "  3. Code Owners review bites only where .github/CODEOWNERS maps paths to reviewers."
