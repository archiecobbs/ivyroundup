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

    <!-- Set this to also retrieve artifacts -->
    <xsl:param name="retrieve.pattern"/>

    <!--
        Set one or more of these to restrict what gets resolved.
        Format of these parameters is: value1[,value2[,value3,...]].
    -->
    <xsl:param name="resolve.org"/>
    <xsl:param name="resolve.mod"/>
    <xsl:param name="resolve.rev"/>

    <xsl:template match="/modules">
        <project name="resolve" default="resolve">

            <!-- Define Ivy ant tasks -->
            <property environment="env"/>
            <condition property="ivy.jar" value="${{env.IVY_JAR}}" else="/usr/share/java/ivy.jar">
                <isset property="env.IVY_JAR"/>
            </condition>
            <taskdef uri="urn:org.apache.ivy.ant"
              resource="org/apache/ivy/ant/antlib.xml"
              classpath="${{ivy.jar}}"/>

            <!--
                Configure ivy.
            -->
            <ivy:settings id="ivy-settings" file="resolve-settings.xml"/>

            <!-- Resolve all (matching) revisions -->
            <target name="resolve" description="Resolve all revisions of all modules">
                <xsl:apply-templates select="org[not($resolve.org) or starts-with($resolve.org, @name) or contains($resolve.org, concat(',', @name))]"/>
            </target>
        </project>
    </xsl:template>

    <xsl:template match="org">
        <xsl:comment>
            <xsl:value-of select="concat(' *** Organisation: ', @name, ' ')"/>
        </xsl:comment>
        <xsl:apply-templates select="mod[not($resolve.mod) or starts-with($resolve.mod, @name) or contains($resolve.mod, concat(',', @name))]"/>
    </xsl:template>

    <xsl:template match="mod">
        <xsl:comment>
            <xsl:value-of select="concat(' ***** Module: ', @name, ' ')"/>
        </xsl:comment>
        <xsl:apply-templates select="rev[not($resolve.rev) or starts-with($resolve.rev, @name) or contains($resolve.rev, concat(',', @name))]"/>
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

        <!-- Resolve artifacts -->
        <ivy:resolve settingsRef="ivy-settings" transitive="true" inline="true"
          organisation="{$org}" module="{$mod}" revision="{$rev}" type="*" conf="*"/>

        <!-- Retrieve artifacts -->
        <xsl:if test="$retrieve.pattern">
            <ivy:retrieve settingsRef="ivy-settings" inline="true" log="default" pattern="{$retrieve.pattern}"
              organisation="{$org}" module="{$mod}" revision="{$rev}" type="*" conf="*"/>
        </xsl:if>
    </xsl:template>

</xsl:transform>
