#!/bin/sh

set -e

MSG="$*"
echo "Commit message will be: ${MSG}"

./src/scripts/regenrepo.sh
git commit -m "${MSG}"
git checkout gh-pages
git merge --ff-only master
git checkout master
git push --all

