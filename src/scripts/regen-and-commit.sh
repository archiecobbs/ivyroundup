#!/bin/sh

set -e

MSG="$*"
if echo "${MSG}" | grep -qE '^[[:space:]]*$'; then
    echo "error: empty commit message" 1>&2
    exit 1
fi
echo "Commit message will be: ${MSG}"

./src/scripts/regenrepo.sh
git commit -m "${MSG}"
git checkout gh-pages
git merge --ff-only master
git checkout master
git push --all

