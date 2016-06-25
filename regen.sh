#!/bin/sh

set -ex
git pull --ff-only
if [ $# -eq 0 ]; then
    ./src/scripts/regen-and-commit.sh -m Regen
else
    ./src/scripts/regen-and-commit.sh ${1+"$@"}
fi
( cd /opt/repo/roundup && git pull)

