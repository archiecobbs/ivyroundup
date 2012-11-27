<?xml version="1.0" encoding="UTF-8"?>

<!--
    Copyright 2012 Martin Weber.

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
    Generate an ant build.xml that verifies each download URL of every artifact in
    the repository.
-->

<!-- $Id$ -->
<xsl:transform version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:pipe="http://xml.apache.org/xalan/PipeDocument"
    extension-element-prefixes="pipe">

    <xsl:output encoding="UTF-8" method="xml" indent="yes"
        media-type="text/xml" />

    <xsl:param name="maven2repo" select="'http://repo1.maven.org/maven2/'" />

    <xsl:param name="batchcnt" select="10" />
    <xsl:variable name="batchsize"
        select="ceiling(count(/modules/org/mod/rev) div $batchcnt)" />

    <!-- Ant snippets for the generated build file live here -->
    <xsl:param name="libdir" />

    <xsl:template match="/modules">
        <project name="verify" default="verify">
            <description>Generated URL-verifier script</description>
            <xsl:value-of select="'&#10;&#10;'" />

            <property name="mvnrepo" value="{$maven2repo}" />
            <property name="report.dir" value="${{basedir}}" />
            <xsl:value-of select="'&#10;&#10;'" />
            <import file="{$libdir}/verify-url-lib.xml" />
            <xsl:value-of select="'&#10;&#10;'" />
            <xsl:comment>
                <xsl:value-of select="'load persistent validation properties'" />
            </xsl:comment>
            <xsl:value-of select="'&#10;&#10;'" />

            <xsl:value-of select="'&#10;'" />

            <!-- Verify all (matching) revisions -->
            <target name="verify" description="Verifies all URLs">
                <echo>
                    <xsl:attribute name="message">
                    <xsl:value-of
                        select="concat('Verifying URLs of ', count(org/mod/rev), ' module revisions...')" />
                </xsl:attribute>
                </echo>
                <touch file="timestamp" />
                <xsl:value-of select="'&#10;&#10;'" />
                <!-- run all batches in forked ant -->
                <!--
                    <antcall target="verify.0" />
                -->
                <parallel threadsperprocessor="4">
                    <xsl:apply-templates select="org/mod/rev"
                        mode="batch-invoke" />
                </parallel>
            </target>


            <!-- create batch targets -->
            <xsl:value-of select="'&#10;&#10;'" />
            <xsl:comment>
                <xsl:value-of
                    select="' ############### batch targets ############### '" />
            </xsl:comment>
            <xsl:apply-templates select="org/mod/rev" mode="batch" />

            <xsl:value-of select="'&#10;'" />
            <xsl:comment>
                <xsl:value-of
                    select="' ############### verify targets ############### '" />
            </xsl:comment>
            <xsl:value-of select="'&#10;'" />
            <!-- create verify targets from corresponding packager.xml -->
            <xsl:for-each select="org/mod/rev">
                <xsl:variable name="org" select="../../@name" />
                <xsl:variable name="mod" select="../@name" />
                <xsl:variable name="rev" select="@name" />

                <target name="#{$org}-{$mod}-{$rev}" unless="valid.{$org}-{$mod}-{$rev}">
                    <!-- <echo message="organisation={$org} module={$mod} revision={$rev}"
                        /> -->
                    <xsl:value-of select="'&#10;'" />
                    <!-- set ant properties first -->
                    <xsl:apply-templates mode="prop"
                        select="document(concat('../src/modules/', $org, '/', $mod, '/', $rev, '/packager.xml'),.)" />
                    <xsl:value-of select="'&#10;&#10;'" />
                    <parallel threadsperprocessor="4">
                        <!-- Iterate over artifacts -->
                        <xsl:apply-templates
                            select="document(concat('../src/modules/', $org, '/', $mod, '/', $rev, '/ivy.xml'),.)" />
                        <xsl:apply-templates
                            select="document(concat('../src/modules/', $org, '/', $mod, '/', $rev, '/packager.xml'),.)" />
                    </parallel>
                </target>
                <xsl:value-of select="'&#10;&#10;&#10;'" />
            </xsl:for-each>
        </project>
    </xsl:template>

    <!-- generate batch target invocations -->
    <xsl:template match="org/mod/rev" mode="batch-invoke">
        <xsl:variable name="revno" select="count(preceding::rev)" />
        <xsl:variable name="batchno" select="floor($revno div $batchsize)" />
        <xsl:if test="$revno mod $batchsize =0">
            <xsl:variable name="fbatchno" select="format-number($batchno,'00')" />
            <antcall target="verify.{$fbatchno}">
                <!--
                    <reference refid="valid"/>
                -->
            </antcall>
        </xsl:if>
    </xsl:template>

    <!-- generate batch targets -->
    <xsl:template match="org/mod/rev" mode="batch">
        <xsl:variable name="revno" select="count(preceding::rev)" />
        <xsl:variable name="batchno" select="floor($revno div $batchsize)" />
        <xsl:if test="$revno mod $batchsize =0">
            <xsl:variable name="fbatchno" select="format-number($batchno,'00')" />
            <xsl:value-of select="'&#10;&#10;'" />
            <xsl:comment>
                <xsl:value-of
                    select="concat(' ### Batch number ', $fbatchno, ', rev ', $revno, '++ ')" />
            </xsl:comment>
            <xsl:value-of select="'&#10;'" />

            <target name="verify.{$fbatchno}"
                depends="-reports.{$fbatchno}.uptodate,-report-in.{$fbatchno}"
                unless="reports.{$fbatchno}.uptodate" description="Invoke batch {$fbatchno}">
                <!-- speed up subsequent crawler invocations, cache names of module
                    revisions that are fine -->
                <cacheValidModRevs dir="${{report.dir}}"
                    reportfile="report-in.{$fbatchno}.txt" cachefile="valid-modrevs.{$fbatchno}.properties" />

                <!-- analyze build output -->
                <extracReportOK dir="${{report.dir}}" srcfile="report-in.{$fbatchno}.txt"
                    destfile="REPORT-OK.{$fbatchno}.txt" />
                <echo message="Wrote report ${{report.dir}}/REPORT-OK.{$fbatchno}.txt" />
                <extracReportProblems dir="${{report.dir}}"
                    srcfile="report-in.{$fbatchno}.txt" destfile="REPORT-problems.{$fbatchno}.txt" />
                <echo
                    message="Wrote report ${{report.dir}}/REPORT-problems.{$fbatchno}.txt" />

            </target>

            <target name="-report-in.{$fbatchno}" depends="-report-in.{$fbatchno}.uptodate"
                unless="report-in.{$fbatchno}.uptodate">
                <!-- strip crawler log -->
                <stripRawReport dir="${{report.dir}}" srcfile="crawler.{$fbatchno}.log"
                    destfile="report-in.{$fbatchno}.txt" />
                <echo message="Wrote ${{report.dir}}/report-in.{$fbatchno}.txt" />
            </target>

            <target name="-crawler.{$fbatchno}" unless="crawler.disabled"
                description="Verifies download URLs in sepate JVM. Use this when Ant goes out of memory.">
                <forkAnt buildfile="${{ant.file}}" builddir="${{basedir}}"
                    target="batch.{$fbatchno}" output="crawler.{$fbatchno}.log" />
                <!-- finally mark crawler log as complete -->
                <touch file="crawler.{$fbatchno}.log.timestamp" />
            </target>

            <xsl:value-of select="'&#10;&#10;'" />
            <!-- must create reports? -->
            <target name="-reports.{$fbatchno}.uptodate">
                <uptodate property="reports.{$fbatchno}.uptodate"
                    targetfile="${{report.dir}}/REPORT-problems.{$fbatchno}.txt"
                    srcfile="${{report.dir}}/report-in.{$fbatchno}.txt" />
            </target>
            <!-- must strip raw report? -->
            <target name="-report-in.{$fbatchno}.uptodate" depends="-crawler.{$fbatchno}">
                <uptodate property="report-in.{$fbatchno}.uptodate"
                    targetfile="${{report.dir}}/report-in.{$fbatchno}.txt"
                    srcfile="${{report.dir}}/crawler.{$fbatchno}.log.timestamp" />
                <fail
                    message="crawler.disabled but crawler must be run (in verify.{$fbatchno})">
                    <condition>
                        <and>
                            <isset property="crawler.disabled" />
                            <not>
                                <isset property="report-in.{$fbatchno}.uptodate" />
                            </not>
                        </and>
                    </condition>
                </fail>
            </target>
            <xsl:value-of select="'&#10;&#10;'" />

            <!-- batch target -->
            <target name="batch.{$fbatchno}" description="Verifies all module revisions in batch.">
                <xsl:comment>
                    <xsl:value-of select="'load persistent validation properties'" />
                </xsl:comment>
                <property id="valid" file="valid-modrevs.{$fbatchno}.properties" />
                <!-- remove duplicate entries in property file -->
                <echoproperties prefix="valid"
                    destfile="valid-modrevs.{$fbatchno}.properties" />

                <touch file="timestamp" />
                <!-- call verify targets in batch -->
                <xsl:apply-templates
                    select="/modules/org/mod/rev[count(preceding::rev) >= $batchno * $batchsize and count(preceding::rev) &lt; ($batchno+1) * $batchsize]" />

            </target>
        </xsl:if>
    </xsl:template>

    <xsl:template match="org/mod/rev">
        <xsl:variable name="org" select="../../@name" />
        <xsl:variable name="mod" select="../@name" />
        <xsl:variable name="rev" select="@name" />
        <xsl:variable name="modpath" select="concat($org, '/', $mod, '/', $rev)" />

        <!-- call verify target -->
        <antcall target="#{$org}-{$mod}-{$rev}">
            <reference refid="valid" />
            <param name="ivy.packager.organisation" value="{$org}" />
            <param name="ivy.packager.module" value="{$mod}" />
            <param name="ivy.packager.revision" value="{$rev}" />
            <param name="modpath" value="{$modpath}" />
            <xsl:if
                test="document(concat('../src/modules/', $org, '/', $mod, '/', $rev, '/ivy.xml'),.)/ivy-module/info/@branch">
                <param name="ivy.packager.branch">
                    <xsl:attribute name="value">
                        <xsl:value-of
                        select="document(concat('../src/modules/', $org, '/', $mod, '/', $rev, '/ivy.xml'),.)/ivy-module/info/@branch" />
                    </xsl:attribute>
                </param>
            </xsl:if>
        </antcall>
    </xsl:template>

    <!-- packager.xml: packager-module -->
    <xsl:template match="/packager-module" mode="prop">
        <xsl:apply-templates select="property|m2resource"
            mode="prop" />
    </xsl:template>

    <!-- packager.xml: packager-module -->
    <xsl:template match="/packager-module">
        <xsl:apply-templates select="resource|m2resource/artifact" />
    </xsl:template>

    <!-- packager.xml: packager-module -->
    <xsl:template match="/packager-module[m2resource]" mode="prop">
        <xsl:apply-templates select="property" mode="prop" />
        <!-- default maven group property -->
        <!-- Convert groupId into URL directories, where dots become slashes -->
        <xsl:if test="m2resource[not(@groupId)]">
            <!-- DEFAULT GROUP NEEDED IN CHILDS -->
            <mvngrp2dir property="grp" location="${{ivy.packager.organisation}}" />
        </xsl:if>
        <!--
            <xsl:choose>
            <xsl:when test="m2resource[not(@groupId)]"></xsl:when>
            <xsl:otherwise>
            NO DEFAULT GROUP NEEDED IN CHILDS
            </xsl:otherwise>
            </xsl:choose>
        -->
        <xsl:apply-templates select="m2resource[@groupId]"
            mode="prop" />
    </xsl:template>

    <!-- packager.xml: Maven2 resource group id -->
    <xsl:template match="/packager-module/m2resource[@groupId]"
        mode="prop">
        <xsl:variable name="group"
            select="concat('grp.', string(count(preceding-sibling::m2resource)+1))" />

        <!-- Convert groupId into URL directories, where dots become slashes -->
        <mvngrp2dir property="{$group}" location="{@groupId}" />
    </xsl:template>

    <!-- packager.xml: Copy property tags -->
    <xsl:template match="/packager-module/property" mode="prop">
        <xsl:copy-of select="." />
    </xsl:template>

    <!-- packager.xml: Maven2 resource artifact -->
    <xsl:template match="/packager-module/m2resource/artifact">
        <!-- determine Ant property name for group -->
        <xsl:variable name="group_prop">
            <xsl:choose>
                <xsl:when test="../@groupId">
                    <!-- TODO: complain if groupId="${ivy.packager.module}" -->
                    <xsl:value-of
                        select="concat('grp.', string( count(../preceding-sibling::m2resource)+1))" />
                </xsl:when>
                <xsl:otherwise>   <!-- use default property -->
                    <xsl:value-of select="'grp'" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <!-- Get maven2 artifactId (or use default) -->
        <xsl:variable name="artifactId">
            <xsl:choose>
                <xsl:when test="../@artifactId">
                    <xsl:value-of select="../@artifactId" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="'${ivy.packager.module}'" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <!-- Get maven2 version (or use default) -->
        <xsl:variable name="version">
            <xsl:choose>
                <xsl:when test="../@version">
                    <xsl:value-of select="../@version" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="'${ivy.packager.revision}'" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <!-- Get maven2 repository URL (or use default) -->
        <xsl:variable name="repourl">
            <xsl:choose>
                <xsl:when
                    test="../@repo and substring(../@repo, string-length(../@repo) - 1) = '/'">
                    <xsl:value-of select="../@repo" />
                </xsl:when>
                <xsl:when test="../@repo">
                    <xsl:value-of select="concat(../@repo, '/')" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="'${mvnrepo}'" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <!-- Compose directory in the maven2 repository -->
        <xsl:variable name="m2dir"
            select="concat($repourl, '${', $group_prop, '}/', $artifactId, '/', $version, '/')" />

        <!-- Get classifier (or use default) -->
        <xsl:variable name="classifier">
            <xsl:choose>
                <xsl:when test="@classifier">
                    <xsl:value-of select="concat('-', @classifier)" />
                </xsl:when>
                <xsl:otherwise />
            </xsl:choose>
        </xsl:variable>

        <!-- Get s (or use default) -->
        <xsl:variable name="suffix">
            <xsl:choose>
                <xsl:when test="@ext">
                    <xsl:value-of select="concat('.', @ext)" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="'.jar'" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <!-- Compose to get filename, then complete URL -->
        <xsl:variable name="filename"
            select="concat($artifactId, '-', $version, $classifier, $suffix)" />
        <xsl:variable name="url" select="concat($m2dir, $filename)" />

        <!-- Get resource -->
        <my-get file="${{modpath}}/packager.xml" url="{$url}" type="mvn" />
    </xsl:template>

    <!-- packager.xml: Analyse primary resource URL -->
    <xsl:template match="/packager-module/resource[@url]">
        <xsl:value-of select="'&#10;'" />
        <xsl:choose>
            <!-- Check for manually downloaded resources -->
            <xsl:when test="starts-with(@url, 'file:')">
                <echo taskname="${{modpath}}/packager.xml :man" message="Must download manually: {@url}" />
            </xsl:when>
            <xsl:otherwise>
                <my-get file="${{modpath}}/packager.xml" url="{@url}" />
                <xsl:apply-templates select="url" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- packager.xml: Analyse alternative resource URL -->
    <xsl:template match="/packager-module/resource/url">
        <xsl:value-of select="'&#10;'" />
        <xsl:choose>
            <!-- Check for manually downloaded resources -->
            <xsl:when test="starts-with(@href, 'file:')">
                <echo taskname="${{modpath}}/packager.xml :man" message="Must download manually: {@href}">X${{user.dir}}X</echo>
            </xsl:when>
            <xsl:otherwise>
                <my-get file="${{modpath}}/packager.xml" url="{@href}"
                    type="alt" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- ivy.xml: Analyse homepage URL -->
    <xsl:template match="/ivy-module/info/description[@homepage]">
        <xsl:value-of select="'&#10;'" />
        <my-get file="${{modpath}}/ivy.xml" url="{@homepage}" type="homepage" />
    </xsl:template>

    <xsl:template match="@*|node()">
        <xsl:apply-templates select="@*|node()" />
    </xsl:template>

</xsl:transform>
