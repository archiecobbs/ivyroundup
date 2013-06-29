#!/bin/sh

set -e

unid()
{
    if grep -qE '\$Id:.*\$' "$1"; then
        sed 's/^\(.*\$Id\):.*\(\$.*\)$/\1\2/g' < "$1" > "$1".new
        mv "$1"{.new,}
        echo "unid: unid'd ${1}"
    fi
}

for ARG in $*; do
    if [ -d "${ARG}" ]; then
        find "${ARG}" -name '.*' -prune -o -type f -print | while read FILE; do
            unid "${FILE}"
        done
    else
        unid "${ARG}"
    fi
done

