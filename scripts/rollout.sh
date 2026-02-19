#!/bin/bash
#
# rollout.sh — Deploy caller workflows to multiple repositories.
#
# Prerequisites:
#   - gh CLI installed and authenticated
#   - Caller workflow files in ./caller-workflows/
#
# Usage:
#   ./scripts/rollout.sh                    # deploy to all repos listed below
#   ./scripts/rollout.sh my-repo            # deploy to a single repo
#   DRY_RUN=1 ./scripts/rollout.sh          # preview without making changes

set -euo pipefail

ORG="forestadmin"
BRANCH="main"

# ── List of target repositories ──
# Add or remove repos as needed.
ALL_REPOS=(
  "forestadmin"
  "forestadmin-server"
  "agent-nodejs"
  "forest-express-sequelize"
  "forest-express-mongoose"
  # Add more repos here
)

# Allow deploying to a single repo via argument
if [ $# -ge 1 ]; then
  REPOS=("$@")
else
  REPOS=("${ALL_REPOS[@]}")
fi

CALLER_DIR="$(dirname "$0")/../caller-workflows"
WORKFLOWS=(
  "security-auto-fix.yml"
  "security-retry-upstream.yml"
  "security-notify-downstream.yml"
)

echo "🔒 Security workflow rollout"
echo "   Org: $ORG"
echo "   Repos: ${REPOS[*]}"
echo "   Workflows: ${WORKFLOWS[*]}"
echo ""

for repo in "${REPOS[@]}"; do
  echo "── $ORG/$repo ──"

  for workflow in "${WORKFLOWS[@]}"; do
    FILE_PATH=".github/workflows/$workflow"
    LOCAL_FILE="$CALLER_DIR/$workflow"

    if [ ! -f "$LOCAL_FILE" ]; then
      echo "   ❌ $workflow not found in $CALLER_DIR"
      continue
    fi

    CONTENT=$(base64 -w0 "$LOCAL_FILE" 2>/dev/null || base64 -i "$LOCAL_FILE")

    if [ "${DRY_RUN:-0}" = "1" ]; then
      echo "   🔍 Would deploy $workflow"
      continue
    fi

    # Check if file already exists (to get its SHA for update)
    EXISTING_SHA=$(gh api "repos/$ORG/$repo/contents/$FILE_PATH" \
      --jq '.sha' 2>/dev/null || true)

    if [ -n "$EXISTING_SHA" ]; then
      gh api "repos/$ORG/$repo/contents/$FILE_PATH" \
        --method PUT \
        --field message="chore: update $workflow" \
        --field content="$CONTENT" \
        --field branch="$BRANCH" \
        --field sha="$EXISTING_SHA" \
        --silent
      echo "   ✅ Updated $workflow"
    else
      gh api "repos/$ORG/$repo/contents/$FILE_PATH" \
        --method PUT \
        --field message="chore: add $workflow" \
        --field content="$CONTENT" \
        --field branch="$BRANCH" \
        --silent
      echo "   ✅ Created $workflow"
    fi
  done

  echo ""
done

echo "🎉 Rollout complete."
echo ""
echo "Next steps:"
echo "  1. Set ANTHROPIC_API_KEY as an org-level secret (if not already done):"
echo "     gh secret set ANTHROPIC_API_KEY --org $ORG --visibility selected --repos $(IFS=,; echo "${REPOS[*]}")"
echo "  2. Add a CLAUDE.md to each repo (use CLAUDE.md.template as a starting point)"
echo "  3. Ensure the 'security' and 'blocked-upstream' labels exist in each repo"
