#!/bin/bash

set -e

# Clean up repo
git checkout repo
git clean -fd repo

# Determine what's changed
MOD_ORGS=`git status | grep -E '(new file|modified):[[:space:]]*src/modules/' | awk -F/ '{print $3}' | sort -u | xargs printf '%s,' | sed 's/,$//g'`
MOD_MODS=`git status | grep -E '(new file|modified):[[:space:]]*src/modules/' | awk -F/ '{print $4}' | sort -u | xargs printf '%s,' | sed 's/,$//g'`
MOD_REVS=`git status | grep -E '(new file|modified):[[:space:]]*src/modules/' | awk -F/ '{print $5}' | sort -u | xargs printf '%s,' | sed 's/,$//g'`

# Resolve modified modules
printf '\nVerifying:\n  orgs: %s\n  mods: %s\n  revs: %s\n\n' "${MOD_ORGS}" "${MOD_MODS}" "${MOD_REVS}"

ant \
  -Dresolve.org="${MOD_ORGS}" \
  -Dresolve.mod="${MOD_MODS}" \
  -Dresolve.rev="${MOD_REVS}" \
  -Dskip-graph=true \
  clean get-xalan repo resolve

