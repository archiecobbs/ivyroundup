#!/bin/sh

set -e

./src/scripts/regenrepo.sh
git commit ${1+"$@"}
git checkout gh-pages
git merge --ff-only master
git checkout master
git push --all

