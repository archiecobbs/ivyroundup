<?xml version="1.0" encoding="ISO-8859-1"?>

<!--
    Copyright 2012 Archie L. Cobbs.

    Licensed under the Apache License, Version 2.0 (the "License"); you may
    not use this file except in compliance with the License. You may obtain
    a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
    License for the specific language governing permissions and limitations
    under the License.
-->

<xsl:transform
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:fn="http://www.w3.org/2005/xpath-functions"
  version="2.0">

    <xsl:output encoding="UTF-8" method="xml" indent="no" media-type="text/xml"/>

    <xsl:param name="org"/>
    <xsl:param name="mod"/>
    <xsl:param name="rev"/>

    <xsl:variable name="squot">'</xsl:variable>

    <xsl:template match="/packager-module/m2resource/artifact/@sha1">

        <!-- Get repo base URI (with trailing slash) -->
        <xsl:variable name="repoURI">
            <xsl:choose>
                <xsl:when test="../../@repo">
                    <xsl:value-of select="../../@repo"/>
                    <xsl:if test="not(fn:matches(../../@repo, '/$'))">
                        <xsl:value-of select="'/'"/>
                    </xsl:if>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="'http://repo2.maven.org/maven2/'"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <!-- Get group ID -->
        <xsl:variable name="groupId">
            <xsl:choose>
                <xsl:when test="../../@groupId">
                    <xsl:call-template name="substitute">
                        <xsl:with-param name="string" select="../../@groupId"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$org"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <!-- Get artifact ID -->
        <xsl:variable name="artifactId">
            <xsl:choose>
                <xsl:when test="../../@artifactId">
                    <xsl:call-template name="substitute">
                        <xsl:with-param name="string" select="../../@artifactId"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$mod"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <!-- Get version -->
        <xsl:variable name="version">
            <xsl:choose>
                <xsl:when test="../../@version">
                    <xsl:call-template name="substitute">
                        <xsl:with-param name="string" select="../../@version"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$rev"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <!-- Convert groupID to URI path segement -->
        <xsl:variable name="groupURIPath">
            <xsl:analyze-string select="$groupId" regex="\.">
                <xsl:matching-substring>
                    <xsl:value-of select="'/'"/>
                </xsl:matching-substring>
                <xsl:non-matching-substring>
                    <xsl:value-of select="."/>
                </xsl:non-matching-substring>
            </xsl:analyze-string>
        </xsl:variable>

        <!-- Get classifier suffix, if any -->
        <xsl:variable name="classifierSuffix">
            <xsl:if test="../@classifier">
                <xsl:call-template name="substitute">
                    <xsl:with-param name="string" select="concat('-', ../@classifier)"/>
                </xsl:call-template>
            </xsl:if>
        </xsl:variable>

        <!-- Get filename extension, if any -->
        <xsl:variable name="extension">
            <xsl:choose>
                <xsl:when test="../@ext">
                    <xsl:value-of select="../@ext"/>
                </xsl:when>
                <xsl:otherwise>jar</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <!-- Get complete URI for checksum file -->
        <xsl:variable name="uri">
            <xsl:value-of select="concat($repoURI, $groupURIPath, '/', $artifactId, '/',
              $version, '/', $artifactId, '-', $version, $classifierSuffix, '.', $extension, '.sha1')"/>
        </xsl:variable>

        <!-- Read SHA1 -->
        <xsl:message terminate="no">
            <xsl:value-of select="concat('Downloading ', $uri, '...')"/>
        </xsl:message>
        <xsl:variable name="sha1">
            <xsl:value-of select="substring(normalize-space(unparsed-text($uri, 'utf-8')), 1, 40)"/>
        </xsl:variable>

        <!-- Replace sha1 value -->
        <xsl:attribute name="sha1">
            <xsl:value-of select="$sha1"/>
        </xsl:attribute>
    </xsl:template>

    <!-- Default is to copy exactly -->
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <!-- Substitute ant variables -->
    <xsl:template name="substitute">
        <xsl:param name="string" select="."/>
        <xsl:analyze-string select="$string" regex="\$\{{ivy\.packager\.(organi(s|z)ation|module|revision)\}}">
            <xsl:matching-substring>
                <xsl:choose>
                    <xsl:when test="contains(., 'org')">
                        <xsl:value-of select="$org"/>
                    </xsl:when>
                    <xsl:when test="contains(., 'mod')">
                        <xsl:value-of select="$mod"/>
                    </xsl:when>
                    <xsl:when test="contains(., 'rev')">
                        <xsl:value-of select="$rev"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:message terminate="yes">ERROR: internal problem</xsl:message>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>

</xsl:transform>
