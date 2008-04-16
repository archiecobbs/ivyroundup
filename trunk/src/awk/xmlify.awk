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
    if ($4 != MOD) {
        if (MOD != "")
            printf "    </mod>\n"
        MOD = ""
    }
    if ($3 != ORG) {
        if (ORG != "")
            printf "  </org>\n"
        ORG = ""
    }
    if ($3 != ORG) {
        printf "  <org name=\"%s\">\n", $3
        ORG = $3
    }
    if ($4 != MOD && $4 != "aliases.txt") {
        printf "    <mod name=\"%s\">\n", $4
        MOD = $4
    }

    # Handle aliases.txt
    if ($NF == "aliases.txt") {
        while (1) {
            if ((getline ALIAS < $0) <= 0)
                break
            if (ALIAS ~ /^(#.*|[[:space:]]*)$/)
                continue
            printf "    %*s<alias name=\"%s\"/>\n", (NF - 4) * 2, "", ALIAS
        }
        close($0)
        next;
    }

    printf "      <rev name=\"%s\"/>\n", $5
}

END {
    if (MOD != "")
        printf "    </mod>\n"
    if (ORG != "")
        printf "  </org>\n"
    printf "</modules>\n"
}

