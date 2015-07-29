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
    echo 'regenrepo: regenerating repository'
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

# Generate directory index files
echo 'regenrepo: regenerating directory indexes'
find repo -type d -print | while read DIR; do
    printf '<html><head><title>ivyroundup - %s</title></head>\n<body>\n<h2>ivyroundup - %s</h2>\n<ul>\n' \
      "${DIR}" "${DIR}" > "${DIR}"/index.html
    printf '<li><a href="../">..</a></li>\n' >> "${DIR}"/index.html
    find "${DIR}" -mindepth 1 -maxdepth 1 -print | while read FILEPATH; do
        FILE=`basename "${FILEPATH}"`
        if [ -d "${FILEPATH}" ]; then
            FILE="${FILE}/"
        fi
        if [ "${FILE}" = 'index.html' ]; then
            continue;
        fi
        printf '<li><a href="%s">%s</a></li>\n' "${FILE}" "${FILE}" >> "${DIR}"/index.html
    done
    printf '</ul><hr noshade><em>Powered by <a href="https://github.com/archiecobbs/ivyroundup/">Ivy RoundUp</a></em></body></html>\n' >> "${DIR}"/index.html
done

# Schedule repo updates for commit
git add --all repo

# Done
echo 'regenrepo: done'
