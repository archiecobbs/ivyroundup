#!/bin/bash

#
# This script corrects/updates the maven SHA1 checksums in all <m2resource> tags.
# Run it with one or more packager.xml files on the command line. The filenames must
# all be of the following form so this script can infer the org, mod, and rev:
#
#       src/modules/com.example/modname/1.2.3/packager.xml
#
# This requires the "saxon9" executable to be available.

# Get sed extended regex flag
set -e
set -o pipefail
case `uname -s` in
    Darwin|*BSD)
        SEDFLAG="-E"
        ;;
    *)
        SEDFLAG="-r"
        ;;
esac

# Get repo flag
REPOBASE='https://repo1.maven.org/maven2/'
if [ "$1" = '-r' ]; then
    shift
    REPOBASE="${1}"
    shift
fi

# Find saxon
for NAME in saxon{9,8,b-xslt,}; do
    SAXON=`which "${NAME}" 2>/dev/null || true`
    if [ -n "${SAXON}" ]; then
        break
    fi
done
if [ -z "${SAXON}" ]; then
    echo "Error: saxon executable not found" 1>&2
    exit 1
fi

# Iterate over files
for FILE; do

    # Check filename matches pattern
    PAT='^src/modules/([^/]+)/([^/]+)/([^/]+)/packager.xml$'
    FILE=`echo "${FILE}" | sed "${SEDFLAG}" 's|/$||g'`
    if ! [[ "${FILE}" =~ ^src/modules/([^/]+)/([^/]+)/([^/]+)/packager.xml$ ]]; then
        echo "Error: file does not match pattern \'${PAT}': ${FILE}" 1>&2
        exit 1
    fi
    ORG=`echo "${FILE}" | sed "${SEDFLAG}" -n 's|'"${PAT}"'|\1|gp'`
    MOD=`echo "${FILE}" | sed "${SEDFLAG}" -n 's|'"${PAT}"'|\2|gp'`
    REV=`echo "${FILE}" | sed "${SEDFLAG}" -n 's|'"${PAT}"'|\3|gp'`

    # Apply XSLT
    echo "*** Updating ${FILE}" 1>&2
    "${SAXON}" "${FILE}" src/xsl/update-maven-checksums.xsl \
      org="${ORG}" mod="${MOD}" rev="${REV}" repoBase="${REPOBASE}" \
      | sed "${SEDFLAG}" -e 's/^(<\?xml version="1.0" encoding="UTF-8"\?>)(<!--[[:space:]]*)$/\1\
\
\2/g' -e 's/^(-->)(<packager-module.*)$/\1\
\
\2/g' -e '$a\' \
      > "${FILE}".new

    # Check result
    if ! [ -s "${FILE}".new ]; then
        echo "Error: transform failed on ${FILE}" 1>&2
        rm -f "${FILE}".new
        exit 1
    fi

    # Replace file
    mv "${FILE}"{.new,}
done

# Done
echo "*** Done" 1>&2

