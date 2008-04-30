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

<!--
    Generate a GraphViz .dot file graphing all modules dependencies.
-->

<!-- $Id$ -->
<xsl:transform
  version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:output encoding="UTF-8" method="text" media-type="text/x-dot"/>

    <!-- See dot(1) man page for valid settings -->
    <xsl:param name="graph.size"/>
    <xsl:param name="graph.margin"/>
    <xsl:param name="graph.rankdir"/>
    <xsl:param name="graph.splines"/>
    <xsl:param name="node.shape"/>

    <xsl:variable name="revision" select="'$Id$'"/>
    <xsl:variable name="modules" select="/modules"/>
    <xsl:variable name="timestamp" select="$modules/timestamp"/>
    <xsl:variable name="svnrev" select="$modules/svnRevision"/>

    <xsl:template match="/modules">
// GENERATED FILE - DO NOT EDIT
//  Input: r<xsl:value-of select="$svnrev"/> generated at <xsl:value-of select="$timestamp"/>
//  Style: <xsl:value-of select="$revision"/>

        strict digraph modules {
            compound="true";
            <xsl:if test="$graph.rankdir">
                rankdir="<xsl:value-of select="$graph.rankdir"/>";
            </xsl:if>
            <xsl:if test="$graph.size">
                size="<xsl:value-of select="$graph.size"/>";
            </xsl:if>
            <xsl:if test="$graph.splines">
                splines="<xsl:value-of select="$graph.splines"/>";
            </xsl:if>
            <xsl:if test="$graph.margin">
                margin="<xsl:value-of select="$graph.margin"/>";
            </xsl:if>
            <xsl:if test="$node.shape">
                node [shape="<xsl:value-of select="$node.shape"/>"];
            </xsl:if>
            <xsl:apply-templates/>
        }
    </xsl:template>

    <xsl:template match="org">
        subgraph "cluster<xsl:value-of select="@name"/>" {
            <xsl:call-template name="color">
                <xsl:with-param name="node" select="."/>
            </xsl:call-template>
            <xsl:apply-templates/>
        }
    </xsl:template>

    <xsl:template match="mod">
        subgraph "<xsl:value-of select="@name"/>" {
            <xsl:apply-templates/>
        }
    </xsl:template>

    <xsl:template match="rev">
        <xsl:variable name="org" select="../../@name"/>
        <xsl:variable name="mod" select="../@name"/>
        <xsl:variable name="rev" select="@name"/>
        <xsl:variable name="ivy" select="document(concat('modules/', $org, '/', $mod, '/', $rev, '/ivy.xml'), .)/ivy-module"/>
        <xsl:variable name="node" select="concat($org, '/', $mod)"/>
        "<xsl:value-of select="$node"/>" [label="<xsl:value-of select="$mod"/>"];
        <xsl:for-each select="$ivy/dependencies/dependency">
            <xsl:variable name="depnode" select="concat(@org, '/', @name)"/>
            "<xsl:value-of select="$node"/>" -&gt; "<xsl:value-of select="$depnode"/>" [label="<xsl:value-of select="@rev"/>"];
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="node()">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template name="color">
        <xsl:choose>
            <xsl:when test="position() mod 7 = 0">
                node [style="filled", fillcolor="aquamarine"];
            </xsl:when>
            <xsl:when test="position() mod 7 = 1">
                node [style="filled", fillcolor="cadetblue1"];
            </xsl:when>
            <xsl:when test="position() mod 7 = 2">
                node [style="filled", fillcolor="cyan"];
            </xsl:when>
            <xsl:when test="position() mod 7 = 3">
                node [style="filled", fillcolor="gold"];
            </xsl:when>
            <xsl:when test="position() mod 7 = 4">
                node [style="filled", fillcolor="darkorange"];
            </xsl:when>
            <xsl:when test="position() mod 7 = 5">
                node [style="filled", fillcolor="burlywood3"];
            </xsl:when>
            <xsl:when test="position() mod 7 = 6">
                node [style="filled", fillcolor="darkorchid1"];
            </xsl:when>
        </xsl:choose>
    </xsl:template>

</xsl:transform>
