<?xml version="1.0" encoding="ISO-8859-1"?>

<!--
    Copyright 2008 Archie L. Cobbs.

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

<!-- $Id$ -->
<xsl:transform
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  version="1.0">

    <xsl:template name="dot2slash">
        <xsl:param name="s"/>
        <xsl:choose>
            <xsl:when test="contains($s, '.')">
                <xsl:value-of select="concat(substring-before($s, '.'), '/')"/>
                <xsl:call-template name="dot2slash">
                    <xsl:with-param name="s" select="substring-after($s, '.')"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$s"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="topdir">
        <xsl:param name="org"/>
        <xsl:choose>
            <xsl:when test="contains($org, '.')">
                <xsl:value-of select="'../'"/>
                <xsl:call-template name="topdir">
                    <xsl:with-param name="org" select="substring-after($org, '.')"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="'../../..'"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:transform>
