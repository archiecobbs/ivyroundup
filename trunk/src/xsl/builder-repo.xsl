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
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  version="1.0">

    <xsl:output encoding="UTF-8" method="xml" indent="yes" media-type="text/xml"/>

    <xsl:variable name="svnrevision" select="'$Id$'"/>

    <xsl:param name="organisation"/>
    <xsl:param name="module"/>
    <xsl:param name="revision"/>

    <xsl:include href="util.xsl"/>

    <xsl:template match="/">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="/builder-module">
        <xsl:value-of select="'&#10;'"/>
        <xsl:comment> GENERATED FILE - DO NOT EDIT </xsl:comment>
        <xsl:value-of select="'&#10;'"/>
        <xsl:comment> Generated by <xsl:value-of select="concat($svnrevision, ' ')"/></xsl:comment>
        <xsl:value-of select="'&#10;'"/>
        <xsl:copy>
            <!-- Add version and xsi:noNamespaceSchemaLocation attributes -->
            <xsl:attribute name="version">1.0</xsl:attribute>
            <xsl:variable name="topdir">
                <xsl:call-template name="topdir">
                    <xsl:with-param name="org" select="$organisation"/>
                </xsl:call-template>
            </xsl:variable>
            <xsl:attribute name="xsi:noNamespaceSchemaLocation">
                <xsl:value-of select="concat($topdir, '/../xsd/builder-1.0.xsd')"/>
            </xsl:attribute>
            <xsl:apply-templates select="@*[name() != 'rev']|node()"/>
        </xsl:copy>
    </xsl:template>

    <!-- Copy everything else exactly -->
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

</xsl:transform>
