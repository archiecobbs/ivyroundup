#!/bin/bash

MOD_ORGS`git status | grep '(new file|modified):' | awk -F/ '{print $3}' | sort -u | xargs printf '%s,' | sed 's/,$//g'`
MOD_MODS`git status | grep '(new file|modified):' | awk -F/ '{print $4}' | sort -u | xargs printf '%s,' | sed 's/,$//g'`
MOD_REVS`git status | grep '(new file|modified):' | awk -F/ '{print $5}' | sort -u | xargs printf '%s,' | sed 's/,$//g'`

ant \
  -Dresolve.org="${MOD_ORGS}" \
  -Dresolve.mod="${MOD_MODS}" \
  -Dresolve.rev="${MOD_REVS}" \
  clean get-xalan repo resolve

