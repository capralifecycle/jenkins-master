#!/bin/sh
set -e

: ${BRANCH_NAME?"Missing variable"}

git add plugin-history/plugin-list.txt
git add plugin-history/plugin-list-clean-build.txt

git status

if ! git diff-index --cached --quiet HEAD; then
  git commit -m "Update plugin log"

  # We push directly to the remote which will also use the SSH agent
  # we provide in Jenkinsfile.
  git push git@github.com:capralifecycle/jenkins-master.git HEAD:"$BRANCH_NAME"

  # TODO: Handle race condition if two jobs run at the same time?
else
  echo "No changes - nothing to commit/push"
fi
