#!/bin/sh

#
# Copy this file and builder-resolver.patch to the top of the ivy source tree,
# then run this script. Example:
#
#   $ cp builder-resolver.patch apply-patch.sh ~/ivycore/trunk
#   $ cd ~/ivycore/trunk
#   $ sh apply-patch.sh
#   $ ant
#

set -e
SRCDIR="."
PATCH="${SRCDIR}/builder-resolver.patch"
MODTGZ="${SRCDIR}/test/repositories/builder/website/dist/mod-1.0.tar.gz"

# Create directories
echo creating directories
cat "${PATCH}" | grep '^Index' | awk '{print $2}' | while read FILE; do
    mkdir -p `dirname "${FILE}"`
    if echo "${FILE}" | grep -E '\.jar$'; then
        cat /dev/null > "${FILE}"
    fi
done

# Create mod-1.0.tar.gz file
echo creating "${MODTGZ}"
cat << "xxEOFxx" | openssl enc -d -base64 > "${MODTGZ}"
H4sIAIdOBkgAA+3RUQoCIRSFYZfiBpq8dtX1SAVNMARW1PLTmF6CHnpwIPq/l3tR
wQNnOu1WMri16chVKYQ2JQXX5qZuz/OZEamXqsnX3YmoV2NDz1Av1/MlF2tNLtvD
uP/8Lt9yGe9LJFrUNPdf53DMpcsfreCo+kX/PsZkrOuS5s2f9w8AAAAAAAAAAAAA
AADgdz0AL9ijtAAoAAA=
xxEOFxx

# Done
echo done

