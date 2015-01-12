#!/bin/bash

# Fail on error
set -e

# Constants
PROGNAME="clonemvn"
USER_AGENT="Mozilla/5.0 (X11; U; Linux i686 (x86_64); en-US; rv:1.8.0.8) Gecko/20060911 SUSE/1.5.0.8-0.2 Firefox/1.5.0.8"

# Usage message
usage() {
    echo "Usage: ${PROGNAME} [-p] group artifact version" 1>&2
    echo "Options:" 1>&2
    echo "  -p  Prefix to trim from artifact name for use as configuration name" 1>&2
    echo "      (e.g. Remove 'spring-' from 'spring-aop' to create an 'aop' configuration)" 1>&2
}

# Parse command line
while [ ${#} -gt 0 ]; do
    case "${1}" in
        -p)
            PRE="${2}"
            shift
            shift
            ;;
        -h)
            usage
            exit 0
            ;;
        -*)
            usage
            exit 1
            ;;
         *)
            break;
            ;;
    esac
done
case "$#" in
    3)
        GRP="${1}"
        ART="${2}"
        REV="${3}"
        ;;
    *)
        usage
        exit 1
        ;;
esac

# Get user's full name
DEFAULT_FULL_NAME="${USER}"
read -p "Enter your full name (for copyright message): ["${DEFAULT_FULL_NAME}"] " FULL_NAME
if [ -z "${FULL_NAME}" ]; then
    FULL_NAME="${DEFAULT_FULL_NAME}"
fi

# Sanity check working directory
if [ ! -d "./src/modules" ]; then
    echo "${PROGNAME}: wrong working directory; ./src/modules not found" 1>&2
    exit 1
fi

# Create temp files
TEMP_BASE=`mktemp -q /tmp/clonemvn.XXXXXX`
if [ $? -ne 0 ]; then
    echo "${PROGNAME}: can't create temporary file" 1>&2
    exit 1
fi
trap "rm -f ${TEMP_BASE}*" 0 2 3 5 10 13 15

# List index
GROUP_ID=`echo "${GRP}" | sed 's|\.|/|g'`
REPO="http://repo2.maven.org/maven2/${GROUP_ID}"
wget -q -O "${TEMP_BASE}.list" -U "${USER_AGENT}" "${REPO}"
if [ ! -f "${TEMP_BASE}.list" ]; then
    echo "${PROGNAME}: could not list index of ${REPO}!"
    exit 1
fi

# Create directories
DIR="src/modules/${GRP}"
if [ ! -d "${DIR}" ]; then
    svn mkdir "${DIR}"
fi
DIR="${DIR}/${ART}"
if [ ! -d "${DIR}" ]; then
    svn mkdir "${DIR}"
fi
DIR="${DIR}/${REV}"
if [ ! -d "${DIR}" ]; then
    svn cp src/boilerplate-maven "${DIR}"
fi

# Perform edits
IVY="${DIR}/ivy.xml"
PKG="${DIR}/packager.xml"
head -n 19 "${PKG}" | sed "s/YOUR NAME HERE/${FULL_NAME}/g" > "${TEMP_BASE}.pkg"
mv "${TEMP_BASE}.pkg" "${PKG}"
head -n 30 "${IVY}" | sed "s/YOUR NAME HERE/${FULL_NAME}/g" > "${TEMP_BASE}.ivy"
mv "${TEMP_BASE}.ivy" "${IVY}"

echo "" >> ${IVY}
echo "    <configurations>" >> ${IVY}
echo "        <conf name=\"default\" description=\"Default configuration\"/>" >> ${IVY}

for ARTIFACT in `cat "${TEMP_BASE}.list" | sed -n -e 's/.*href="//gp' | sed 's|/.*||g' | sed '/$/N;s/\.\.\n//g'`; do
    if [ "${ARTIFACT}" = "${ART}" ]; then
        echo "    <m2resource>" > "${TEMP_BASE}.pkgr"
    else
        echo "    <m2resource artifactId=\"${ARTIFACT}\">" > "${TEMP_BASE}.pkgr"
    fi
    A="${ARTIFACT}-${REV}.jar"
    PKGR="0"
    if [ -z ${PRE} ]; then
        CONF="${ARTIFACT}"
    else
        CONF=`echo "${ARTIFACT}" | sed "s/${PRE}//g"`
    fi

    wget -q -U "${USER_AGENT}" ${REPO}/${ARTIFACT}/${REV}/${A}.sha1 || true
    if [ -f ${A}.sha1 ]; then
        SHA1=`cat ${A}.sha1 | awk '{print $1}'`
        echo "        <artifact tofile=\"artifacts/jars/${ARTIFACT}.jar\" sha1=\"${SHA1}\"/>" >> "${TEMP_BASE}.pkgr"
        echo "        <artifact name=\"${ARTIFACT}\" conf=\"${CONF}\"/>" >> "${TEMP_BASE}.jars"
        rm ${A}.sha1
        PKGR="1"
    fi
    A="${ARTIFACT}-${REV}-sources.jar"
    wget -q -U "${USER_AGENT}" ${REPO}/${ARTIFACT}/${REV}/${A}.sha1 || true
    if [ -f ${A}.sha1 ]; then
        SHA1=`cat ${A}.sha1 | awk '{print $1}'`
        echo "        <artifact classifier=\"sources\" tofile=\"artifacts/sources/${ARTIFACT}.zip\" sha1=\"${SHA1}\"/>" >> "${TEMP_BASE}.pkgr"
        echo "        <artifact name=\"${ARTIFACT}\" type=\"source\" ext=\"zip\" conf=\"${CONF}\"/>" >> "${TEMP_BASE}.srcs"
        rm ${A}.sha1
        PKGR="1"
    fi
    A="${ARTIFACT}-${REV}-javadoc.jar"
    wget -q -U "${USER_AGENT}" ${REPO}/${ARTIFACT}/${REV}/${A}.sha1 || true
    if [ -f ${A}.sha1 ]; then
        SHA1=`cat ${A}.sha1 | awk '{print $1}'`
        echo "        <artifact classifier=\"javadoc\" tofile=\"artifacts/javadocs/${ARTIFACT}.zip\" sha1=\"${SHA1}\"/>" >> "${TEMP_BASE}.pkgr"
        echo "        <artifact name=\"${ARTIFACT}\" type=\"javadoc\" ext=\"zip\" conf=\"${CONF}\"/>" >> "${TEMP_BASE}.docs"
        rm ${A}.sha1
        PKGR="1"
    fi
    if [ "${PKGR}" = "1" ]; then
        cat "${TEMP_BASE}.pkgr" >> ${PKG}
        echo "    </m2resource>" >> ${PKG}
        echo "        <conf name=\"${CONF}\" description=\"${CONF} configuration\"/>" >> ${IVY}
    fi
done
echo "</packager-module>" >> ${PKG}
echo "    </configurations>" >> ${IVY}
echo "" >> ${IVY}
echo "    <publications>" >> ${IVY}
echo "        <!-- jar -->" >> ${IVY}
cat "${TEMP_BASE}.jars" >> ${IVY}
echo "" >> ${IVY}
echo "        <!-- source -->" >> ${IVY}
cat "${TEMP_BASE}.srcs" >> ${IVY}
echo "" >> ${IVY}
echo "        <!-- javadoc -->" >> ${IVY}
cat "${TEMP_BASE}.docs" >> ${IVY}
echo "    </publications>" >> ${IVY}
echo "" >> ${IVY}
echo "    <dependencies>" >> ${IVY}

POM="${ARTIFACT}-${REV}.pom"
wget -q -U "${USER_AGENT}" ${REPO}/${ARTIFACT}/${REV}/${POM} || true
if [ -f "${POM}" ]; then
    LINES=`cat "${POM}" | wc -l | awk '{print $1}'`
    MODEL_LINE=`cat "${POM}" | grep -n modelVersion | head -n 1 | cut -d ':' -f1`
    echo "<project>" > "${TEMP_BASE}.pom"
    tail -n $((LINES-MODEL_LINE)) "${POM}" >> "${TEMP_BASE}.pom"
    mv "${TEMP_BASE}.pom" "${POM}"
    xml sel -t -m "//dependencies/dependency" -v "concat(groupId,':',artifactId,':',version,':',scope)" -n "${POM}" > "${TEMP_BASE}.deps"
    while read DEP; do
        ORG=`echo "${DEP}" | cut -d ':' -f1`
        NAME=`echo "${DEP}" | cut -d ':' -f2`
        VER=`echo "${DEP}" | cut -d ':' -f3`
        SCOPE=`echo "${DEP}" | cut -d ':' -f4`
        if [ "test" != "${SCOPE}" ]; then
            if [ -z ${VER} ]; then
                VER="[0,)"
            fi
            if [ 0 -lt `echo "${VER}" | grep -c "{"` ]; then
                VER="[0,)"
            fi
            echo "        <dependency org=\"${ORG}\" name=\"${NAME}\" rev=\"${VER}\" conf=\"default->default\"/>" >> ${IVY}
        fi
    done < "${TEMP_BASE}.deps"
fi
echo "    </dependencies>" >> ${IVY}
echo "" >> ${IVY}
echo "</ivy-module>" >> ${IVY}

