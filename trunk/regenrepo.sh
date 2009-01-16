#!/bin/sh
# $Id$

#
# This script should be used to regenerate the repository
#

# Bail on errors, show commands
set -e

# Update to get lastest stuff
echo 'regenrepo: updating from SVN'
svn up

# Regenerate repo
echo 'regenrepo: regenerating repository'
ant repo

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
