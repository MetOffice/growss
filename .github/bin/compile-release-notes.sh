#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# (c) Crown copyright Met Office. All rights reserved.
# The file LICENCE, distributed with this code, contains details of the terms
# under which the code may be used.
# ------------------------------------------------------------------------------
# Compile categorised release notes from a shared changelog template.
# Helper script for the draft-release GitHub Action workflow.
#
# Usage:
#   compile-release-notes.sh <caller_repo> <template_file> <github_sha> \
#                            <github_ref_name> <template_repo> <template_ref> \
#                            <template_path>
#
# Required environment:
#   GH_TOKEN       - GitHub token for API access
#   GITHUB_OUTPUT  - Set automatically in GitHub Actions

set -euo pipefail

error_exit() {
  echo "::error::$1" >&2
  exit 1
}

[[ $# -lt 7 ]] && error_exit "Usage: $0 <caller_repo> <template_file> <github_sha> <github_ref_name> <template_repo> <template_ref> <template_path>"

CALLER_REPO="$1"
TEMPLATE_FILE="$2"
GITHUB_SHA="$3"
GITHUB_REF_NAME="$4"
TEMPLATE_REPO="$5"
TEMPLATE_REF="$6"
TEMPLATE_PATH="$7"

# Check for required commands and files
command -v gh >/dev/null 2>&1 || error_exit "GitHub CLI (gh) is required but not available."
command -v jq >/dev/null 2>&1 || error_exit "jq is required but not available."
[[ -f "$TEMPLATE_FILE" ]] || error_exit "Template file not found: $TEMPLATE_FILE"

# Determine previous tag from local-code git history
# a. Get the most recent tag reachable from the commit before the current GITHUB_SHA.
PREV_TAG="$(git -C local-code describe --tags --abbrev=0 "${GITHUB_SHA}^" 2>/dev/null || true)"
# b. Not Implemented: Get the latest tag starting with "v", excluding the current branch/tag name.
# Sorts by creation date (newest first), takes the top result, and defaults to empty if none exist.
PREV_TAG0="$(git -C local-code tag --list "v*" --sort=-creatordate | grep -v "^${GITHUB_REF_NAME}$" | head -n 1 || true)"

# -- Debugging output ----------------------------------------------------------
echo "::group::Caller Repository"
echo "Caller repository:           ${CALLER_REPO}"
echo "Current ref name:            ${GITHUB_REF_NAME}"
echo "Current commit SHA:          ${GITHUB_SHA}"
echo "Previous tag (v*):           ${PREV_TAG0:-None}"
echo "Previous tag (git describe): ${PREV_TAG:-None}"
echo "::endgroup::"
echo "::group::Template Repository"
echo "Template repository:         ${TEMPLATE_REPO}"
echo "Template ref:                ${TEMPLATE_REF}"
echo "Template path:               ${TEMPLATE_PATH}"
echo "Template file:               ${TEMPLATE_FILE}"
echo "::endgroup::"
# ------------------------------------------------------------------------------

if [ -n "$PREV_TAG" ]; then
  COMPARE_RANGE="${PREV_TAG}...${GITHUB_SHA}"
  # Single API call to get all commit hashes within the release window
  gh api "repos/${CALLER_REPO}/compare/${COMPARE_RANGE}" --jq '.commits[].sha' >commit-shas.txt
else
  git -C local-code rev-list --max-count=300 "${GITHUB_SHA}" >commit-shas.txt
fi

# If no commits were found, create a release notes file indicating this and exit early
# cat commit-shas.txt  # debugging output
if [ ! -s commit-shas.txt ]; then
  {
    echo "## Changelog"
    echo
    echo "* No commits found for this release window."
  } >release-notes.md
  echo "has_commits=false" >>"${GITHUB_OUTPUT}"
  echo "::warning::No commits found for this release window."
  exit 0
fi

# Extract pull requests directly from the repository's main PR list.
# Pull the 200 most recent merged PRs, then match them against commit-shas.txt
{
  gh api "repos/${CALLER_REPO}/pulls?state=closed&per_page=100&page=1"
  gh api "repos/${CALLER_REPO}/pulls?state=closed&per_page=100&page=2"
} | jq -r '.[] | select(.merged_at != null) |
  "\(.merge_commit_sha) \(.number) \(.title) | \(.user.login) | \([.labels[].name] | join(","))"' >recent-prs.txt

# -- Filter recent-prs down to ONLY those matching a commit SHA from our release range
awk 'NR==FNR { shas[tolower($1)]=1; next } (tolower($1) in shas) { print }' commit-shas.txt recent-prs.txt >pr-data.txt

# cat pr-data.txt  # debugging output
if [ ! -s pr-data.txt ]; then
  {
    echo "## Changelog"
    echo
    echo "* No pull requests found for this release window."
  } >release-notes.md
  echo "has_commits=false" >>"${GITHUB_OUTPUT}"
  echo "::warning::No pull requests found for this release window."
  exit 0
fi

# Parse template YAML (limited parser for current release.yml structure)
declare -a CATEGORY_TITLES=()
declare -a CATEGORY_LABELS=()
declare -a EXCLUDE_LABELS=()

mode=""
in_category_labels=0
current_index=-1

while IFS= read -r raw_line; do
  line="${raw_line%%#*}"
  trimmed="${line#"${line%%[![:space:]]*}"}"
  trimmed="${trimmed%"${trimmed##*[![:space:]]}"}"
  [ -z "$trimmed" ] && continue

  case "$trimmed" in
    changelog:) continue ;;
    categories: | exclude:)
      mode="${trimmed%?}"
      in_category_labels=0
      continue
      ;;
    labels:)
      case "$mode" in
        categories) [ "$current_index" -ge 0 ] && in_category_labels=1 ;;
        exclude) in_category_labels=2 ;;
      esac
      continue
      ;;
  esac

  if [ "$mode" = "categories" ] && [[ "$trimmed" =~ ^-[[:space:]]title:[[:space:]]*\"(.*)\"$ ]]; then
    CATEGORY_TITLES+=("${BASH_REMATCH[1]}")
    CATEGORY_LABELS+=("")
    current_index=$((current_index + 1))
    in_category_labels=0
    continue
  fi

  if [ "$in_category_labels" -eq 1 ] && [[ "$trimmed" =~ ^-[[:space:]]+\"?([A-Za-z0-9._-]+)\"?\;?$ ]]; then
    lbl="${BASH_REMATCH[1],,}"
    if [ -z "${CATEGORY_LABELS[$current_index]}" ]; then
      CATEGORY_LABELS[current_index]="$lbl"
    else
      CATEGORY_LABELS[current_index]+="|$lbl"
    fi
    continue
  fi

  if [ "$in_category_labels" -eq 2 ] && [[ "$trimmed" =~ ^-[[:space:]]+\"?([A-Za-z0-9._-]+)\"?\;?$ ]]; then
    EXCLUDE_LABELS+=("${BASH_REMATCH[1],,}")
    continue
  fi
done <"$TEMPLATE_FILE"

# Store PR lines in temporary files for each category, then concatenate them into the final release notes.
tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

for i in "${!CATEGORY_TITLES[@]}"; do : >"$tmp_dir/cat_${i}.md"; done

# Read the local intersected PR file and map categories
while IFS= read -r row || [ -n "$row" ]; do
  [ -z "$row" ] && continue

  # Row looks like: <merge_sha> <pr_number> <title> | <user> | <labels>
  metadata=$(echo "$row" | cut -d'|' -f1)
  user=$(echo "$row" | cut -d'|' -f2 | xargs)
  labels=$(echo "$row" | cut -d'|' -f3 | xargs)
  pr=$(echo "$metadata" | awk '{print $2}')
  title=$(echo "$metadata" | cut -d' ' -f3-)

  # Convert labels to an array and normalize to lowercase
  IFS=',' read -r -a label_array <<<"${labels,,}"

  # Check exclude labels
  skip=0
  for ex in "${EXCLUDE_LABELS[@]}"; do
    for lbl in "${label_array[@]}"; do
      [ "$lbl" = "$ex" ] && {
        skip=1
        break 2  # Breaks out of both loops
      }
    done
  done
  [ "$skip" -eq 1 ] && continue

  pr_line="1. ${title} (@${user}) in #${pr}"

  # Check which categories this PR matches
  for i in "${!CATEGORY_TITLES[@]}"; do
    IFS='|' read -r -a cat_labels <<<"${CATEGORY_LABELS[$i]}"
    matched_this_category=0

    for cat_lbl in "${cat_labels[@]}"; do
      for lbl in "${label_array[@]}"; do
        if [ "$lbl" = "$cat_lbl" ]; then
          # Only append once per category block, even if multiple labels match
          if [ "$matched_this_category" -eq 0 ]; then
            matched_this_category=1
            echo "$pr_line" >>"$tmp_dir/cat_${i}.md"
          fi
          break  # Break out of PR labels loop; move to next category label
        fi
      done
    done
  done
done <pr-data.txt

{
  echo "## Key Changes"
  echo
  wrote_any=0
  for i in "${!CATEGORY_TITLES[@]}"; do
    if [ -s "$tmp_dir/cat_${i}.md" ]; then
      wrote_any=1
      echo "### ${CATEGORY_TITLES[$i]}"
      cat "$tmp_dir/cat_${i}.md"
      echo
    fi
  done
  [ "$wrote_any" -eq 0 ] && echo "* No pull requests matched release categories."
  if [ -n "$PREV_TAG" ]; then
    echo
    echo "**Full Changelog**: https://github.com/${CALLER_REPO}/compare/${PREV_TAG}...${GITHUB_REF_NAME}"
  fi
} >release-notes.md

echo "has_commits=true" >>"${GITHUB_OUTPUT}"
echo "::notice::Draft release notes generated successfully."
