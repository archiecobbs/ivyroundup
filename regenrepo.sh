#!/bin/sh
# $Id$

#
# This script should be used to regenerate the repository
#

# Bail on errors, show commands
set -e

# There should be no outstanding changes
echo 'regenrepo: checking status of source'
if ! [ "`svn st src | wc -c`" -eq 0 ]; then
    echo 'regenrepo: ERROR: src/ is not clean:'
    svn st src
    exit 1
fi

# Update to get lastest stuff
echo 'regenrepo: updating from SVN'
svn up

# Regenerate repo
echo 'regenrepo: regenerating repository'
ant repo > regen.out

# Check for errors (fatal)
if grep -q ERROR regen.out; then
    echo 'regenrepo: ERROR: errors found during repository generation:'
    grep ERROR regen.out
    rm -f regen.out
    exit 1
fi

# Check for warnings (non-fatal)
if grep -q WARNING regen.out; then
    echo 'regenrepo: warnings found during repository generation:'
    grep WARNING regen.out
fi
rm -f regen.out

# If there's anything new, svn copy it from source
if svn st repo/modules | grep -q '^\?'; then

    # Do the copy
    echo 'regenrepo: svn copying new stuff into repository'
    svn st repo/modules \
      | grep '^\?' \
      | awk '{print $2}' \
      | sed -r 's/^repo\///g' \
      | while read NAME; do
        rm -rf repo/$NAME
        svn cp src/$NAME repo/$NAME
        svn pd svn:mergeinfo repo/$NAME
    done

    # Need to regenerate
    echo 'regenrepo: regenerating repository (again)'
    ant repo
fi

echo 'regenrepo: done'
