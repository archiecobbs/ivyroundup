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
    Generate an ant build.xml that resolves every artifact in the repository.
-->

<!-- $Id$ -->
<xsl:transform
  version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:ivy="urn:org.apache.ivy.ant">

    <xsl:output encoding="UTF-8" method="xml" indent="yes" media-type="text/xml"/>

    <xsl:template match="/modules">
        <project name="resolve" default="resolve">

            <!-- Define Ivy ant tasks -->
            <taskdef uri="urn:org.apache.ivy.ant"
              resource="org/apache/ivy/ant/antlib.xml"
              classpath="/usr/share/java/ivy.jar"/>

            <!--
                Configure ivy. The override="true" is a workaround for:
                    https://issues.apache.org/jira/browse/IVY-782
            -->
            <ivy:settings id="ivy-settings" override="true" file="resolve-settings.xml"/>

            <!-- Resolve all revisions of all modules -->
            <target name="resolve" description="Resolve all revisions of all modules">
                <xsl:apply-templates select="org"/>
            </target>
        </project>
    </xsl:template>

    <xsl:template match="org">
        <xsl:comment>
            <xsl:value-of select="concat(' *** Organisation: ', @name, ' ')"/>
        </xsl:comment>
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="mod">
        <xsl:comment>
            <xsl:value-of select="concat(' ***** Module: ', @name, ' ')"/>
        </xsl:comment>
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="rev">
        <xsl:variable name="org" select="../../@name"/>
        <xsl:variable name="mod" select="../@name"/>
        <xsl:variable name="rev" select="@name"/>
        <xsl:variable name="ivy" select="document(concat('modules/', $org, '/', $mod, '/', $rev, '/ivy.xml'), .)/ivy-module"/>
        <xsl:variable name="artifacts" select="$ivy/publications/artifact"/>

        <xsl:comment>
            <xsl:value-of select="concat(' ******* Revision: ', $rev, ' ')"/>
        </xsl:comment>

        <xsl:for-each select="$artifacts">

            <!-- Get artifact name -->
        <!--
            <xsl:variable name="name">
                <xsl:choose>
                    <xsl:when test="@name">
                        <xsl:value-of select="@name"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$mod"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
        -->

            <!-- Get artifact type -->
            <xsl:variable name="type">
                <xsl:choose>
                    <xsl:when test="@type">
                        <xsl:value-of select="@type"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'jar'"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>

            <!-- Resolve artifact -->
            <ivy:resolve settingsRef="ivy-settings" transitive="true" inline="true" log="download-only"
              organisation="{$org}" module="{$mod}" revision="{$rev}" type="{$type}" conf="*"/>
        </xsl:for-each>
    </xsl:template>

</xsl:transform>
