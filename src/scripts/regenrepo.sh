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

# Subroutine
regenerate_repo()
{
    # Regenerate repo
    echo 'regenrepo: regenerating repository' "$1"
    ant -Djavax.xml.transform.TransformerFactory=org.apache.xalan.processor.TransformerFactoryImpl \
      -Ddownload-xalan=true repo > regen.out

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
}

# Revert any changes to existing repo
git checkout HEAD -- repo

# Regenerate repo
regenerate_repo

# If any directories have been removed from the source tree, remove them from the generated repo
( cd repo/modules && find . -mindepth 1 -maxdepth 3 -type d \
  | xargs -n 1 -I '{}' sh -c 'test -d ../../src/modules/{} || echo {}' ) | sort -r | while read DIR; do
    echo "regenrepo: removing deleted directory ${DIR}"
    rm -rf repo/modules/"${DIR}"
done

# Generate HTML files
echo 'regenrepo: regenerating HTML files' "$1"
xsltproc repo/xsl/modules.xsl repo/modules.xml > repo/modules.html
git status  --porcelain repo/modules | grep -E '/ivy.xml$' | cut -c 4- | while read IVYFILE; do
    HTMLFILE=`echo "${IVYFILE}" | sed 's/\.xml$/.html/g'`
    xsltproc repo/xsl/ivy-doc.xsl "${IVYFILE}" > "${HTMLFILE}"
done

# Done
echo 'regenrepo: done'
