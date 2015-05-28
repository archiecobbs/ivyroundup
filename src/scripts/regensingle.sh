#!/bin/sh

#
# This script should be used to regenerate the repository
#

# Bail on errors, show commands
set -e

# Set locale
export LANG=C
export LC_ALL=C

# Use the right sed(1) flag
case "`uname -s`" in
    Darwin|FreeBSD)
        SEDFLAG="-E"
        ;;
    *)
        SEDFLAG="-r"
        ;;
esac

SCRIPT="regensingle"
ORG="$1"
MOD="$2"
REV="$3"

if [ -z $ORG ]; then
    echo "$SCRIPT: organization must be specified as first argument"
    exit 1
fi
if [ -z $MOD ]; then
    echo "$SCRIPT: module must be specified as first argument"
    exit 1
fi
if [ -z $REV ]; then
    echo "$SCRIPT: revision must be specified as first argument"
    exit 1
fi

# Subroutine
regenerate_repo()
{
    # Regenerate repo
    echo "$SCRIPT: regenerating repository" "$1"
    ant -Djavax.xml.transform.TransformerFactory=org.apache.xalan.processor.TransformerFactoryImpl \
      -Ddownload-xalan=true -Drepo.org="$ORG" -Drepo.mod="$MOD" -Drepo.rev="$REV" repo-for-module > regen.out

    # Check for errors (fatal)
    if grep -q ERROR regen.out; then
        echo "$SCRIPT: ERROR: errors found during repository generation:"
        grep ERROR regen.out
        rm -f regen.out
        exit 1
    fi

    # Check for warnings (non-fatal)
    if grep -q WARNING regen.out; then
        echo "$SCRIPT: warnings found during repository generation:"
        grep WARNING regen.out
    fi
    rm -f regen.out
}

# Revert any changes to existing repo
git checkout HEAD -- repo

# Regenerate repo
regenerate_repo

# Done
echo "$SCRIPT: done"
