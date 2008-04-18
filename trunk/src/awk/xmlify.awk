# $Id$

BEGIN {
    ORG=""
    MOD=""
    printf "<?xml-stylesheet type=\"text/xsl\" href=\"xsl/modules.xsl\"?>\n"
    printf "<modules>\n"
    printf "  <timestamp>%s</timestamp>\n", strftime("%Y-%m-%d %H:%M:%S GMT", systime())
    printf "  <svnRevision>%s</svnRevision>\n", SVNREV
}

{
    THISORG=$3
    for (i = 4; i < NF - 2; i++)
        THISORG=THISORG "." $i
    THISMOD=$(NF - 2)
    THISREV=$(NF - 1)
    if (THISMOD != MOD) {
        if (MOD != "")
            printf "    </mod>\n"
        MOD = ""
    }
    if (THISORG != ORG) {
        if (ORG != "")
            printf "  </org>\n"
        ORG = ""
    }
    if (THISORG != ORG) {
        printf "  <org name=\"%s\">\n", THISORG
        ORG = THISORG
    }
    if (THISMOD != MOD) {
        printf "    <mod name=\"%s\">\n", THISMOD
        MOD = THISMOD
    }
    printf "      <rev name=\"%s\"/>\n", THISREV
}

END {
    if (MOD != "")
        printf "    </mod>\n"
    if (ORG != "")
        printf "  </org>\n"
    printf "</modules>\n"
}

