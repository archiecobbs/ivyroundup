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

<!-- $Id: ivy-repo.xsl 90 2008-04-14 22:08:55Z archie.cobbs $ -->
<xsl:transform
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  version="1.0">

    <xsl:output encoding="UTF-8" method="xml" indent="no" media-type="text/xml"/>

    <xsl:variable name="svnrevision" select="'$Id: ivy-repo.xsl 90 2008-04-14 22:08:55Z archie.cobbs $'"/>

    <xsl:param name="organisation"/>
    <xsl:param name="module"/>
    <xsl:param name="revision"/>

    <xsl:template match="/">
        <xsl:copy>
            <xsl:value-of select="'&#10;'"/>
            <!-- Add stylesheet reference -->
            <xsl:processing-instruction name="xml-stylesheet">type="text/xsl" href="../../../../xsl/ivy-doc.xsl"</xsl:processing-instruction>
            <xsl:value-of select="'&#10;'"/>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="/ivy-module">
        <xsl:value-of select="'&#10;'"/>
        <xsl:comment> GENERATED FILE - DO NOT EDIT </xsl:comment>
        <xsl:value-of select="'&#10;'"/>
        <xsl:comment> Generated by <xsl:value-of select="concat($svnrevision, ' ')"/></xsl:comment>
        <xsl:value-of select="'&#10;'"/>
        <xsl:copy>
            <!-- Add version and xsi:noNamespaceSchemaLocation attributes -->
            <xsl:attribute name="version">1.3</xsl:attribute>
            <xsl:attribute name="xsi:noNamespaceSchemaLocation">../../../../xsd/ivy.xsd</xsl:attribute>
            <xsl:apply-templates select="@*[name() != 'rev']|node()"/>
        </xsl:copy>
        <xsl:value-of select="'&#10;'"/>
    </xsl:template>

    <xsl:template match="/ivy-module/info">
        <xsl:copy>
            <!-- Auto-insert organisation, module, and revision attributes -->
            <xsl:attribute name="organisation">
                <xsl:value-of select="$organisation"/>
            </xsl:attribute>
            <xsl:attribute name="module">
                <xsl:value-of select="$module"/>
            </xsl:attribute>
            <xsl:attribute name="revision">
                <xsl:value-of select="$revision"/>
            </xsl:attribute>
            <xsl:if test="not(@status)">
                <xsl:attribute name="status">release</xsl:attribute>
            </xsl:if>
            <xsl:apply-templates select="@*"/>
            <xsl:value-of select="'&#10;        '"/>
            <xsl:if test="license">
                <xsl:apply-templates select="license"/>
                <xsl:value-of select="'&#10;        '"/>
            </xsl:if>
            <xsl:choose>
                <xsl:when test="ivyauthor">
                    <xsl:apply-templates select="ivyauthor"/>
                    <xsl:value-of select="'&#10;        '"/>
                </xsl:when>
                <xsl:otherwise>
                    <!-- Set <ivyauthor> based on SVN revision string -->
                    <ivyauthor>
                        <xsl:attribute name="name">
                            <xsl:choose>
                                <xsl:when test="/ivy-module/@rev">
                                    <xsl:value-of select="/ivy-module/@rev"/>
                                </xsl:when>
                                <xsl:otherwise>Ivy RoundUp Repository</xsl:otherwise>
                            </xsl:choose>
                        </xsl:attribute>
                        <xsl:attribute name="url">http://ivyroundup.googlecode.com/</xsl:attribute>
                    </ivyauthor>
                    <xsl:value-of select="'&#10;        '"/>
                </xsl:otherwise>
            </xsl:choose>
            <!-- Add <repository> tag pointing to Ivy RoundUp -->
            <repository name="ivyroundup" url="http://ivyroundup.googlecode.com/" ivys="true"
              pattern="http://ivyroundup.googlecode.com/svn/trunk/repo/modules/[organisation]/[module]/[revision]/ivy.xml"/>
            <xsl:value-of select="'&#10;        '"/>
            <xsl:apply-templates select="description"/>
            <xsl:value-of select="'&#10;    '"/>
        </xsl:copy>
    </xsl:template>

    <!-- Copy everything else exactly -->
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

</xsl:transform>
