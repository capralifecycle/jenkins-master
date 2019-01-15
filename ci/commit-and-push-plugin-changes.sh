#!/bin/sh
set -e

: ${BRANCH_NAME?"Missing variable"}

git add plugin-history/plugin-list-prod.txt
git add plugin-history/plugin-list-build.txt
git add plugin-history/plugin-list-prod.diff
git add last-version.txt

git status

if ! git diff-index --cached --quiet HEAD; then
  git commit -m "Update plugin log"
  git push origin HEAD:"$BRANCH_NAME"
else
  echo "No changes - nothing to commit/push"
fi
