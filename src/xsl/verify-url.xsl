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
    Generate an ant build.xml that verifies each download URL of every artifact in the repository.
-->

<!-- $Id$ -->
<xsl:transform
  version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:pipe="http://xml.apache.org/xalan/PipeDocument"
  extension-element-prefixes="pipe">

    <xsl:output encoding="UTF-8" method="xml" indent="yes" media-type="text/xml"/>

    <!--
        Set one or more of these to restrict what gets resolved.
        Format of these parameters is: value1[,value2[,value3,...]].
    -->
    <xsl:param name="resolve.org"/>
    <xsl:param name="resolve.mod"/>
    <xsl:param name="resolve.rev"/>

    <xsl:param name="stylesheet"/>

    <xsl:variable name="maven2repo" select="'http://repo1.maven.org/maven2/'"/>

    <xsl:template match="/modules">
        <project name="verify" default="verify">

            <!-- Define verify macro -->
            <!-- For use of the generated URL checks. Intended to be invoked as:

            <get-and-print packagerfile="src/module/com.icu/1.3.1/packager.xml">
              <url url="http://www.icu-project.org/repos/icu/icu4j/tags/release-49-1/x1.jar"/>
              <url url="http://www.icu-project.org/repos/icu/icu4j/tags/release-49-1/x1-source.zip"/>
              <url url="..." />
            </get-and-print>
          -->
            <macrodef name="get-and-print" description="Checks URL resources availability">
              <attribute name="packagerfile" default="get"/>
              <element name="url" implicit="true" />
              <sequential>
                <get taskname="@{{packagerfile}}" dest="${{basedir}}" usetimestamp="true" ignoreerrors="true" verbose="false">
                  <mergemapper to="timestamp" />
                  <url />
                </get>
              </sequential>
            </macrodef>
            <xsl:value-of select="'&#10;&#10;'" />
 
            <!-- Resolve all (matching) revisions -->
            <target name="verify" description="Verifies each download URL">
              <touch file="timestamp" />
              
              <!-- call all verify targets -->
                <xsl:apply-templates select="org[not($resolve.org)
                  or $resolve.org = @name
                  or starts-with($resolve.org, concat(@name, ','))
                  or contains($resolve.org, concat(',', @name, ','))
                  or substring($resolve.org, string-length($resolve.org) - string-length(@name)) = concat(',', @name)]"/>
            <!-- 
             -->
            </target>
            <xsl:value-of select="'&#10;&#10;'" />
            <xsl:comment>
              <xsl:value-of select="' *** verify targets *** '"/>
            </xsl:comment>
            <xsl:value-of select="'&#10;'" />
            
            <!-- create verify targets from corresponding packager.xml -->
            <xsl:for-each select="org/mod/rev">
                <xsl:variable name="org" select="../../@name"/>
                <xsl:variable name="mod" select="../@name"/>
                <xsl:variable name="rev" select="@name"/>
            <target name="{$org}#{$mod};{$rev}">
<!--            <echo message="organisation={$org} module={$mod} revision={$rev}" />-->
            <xsl:apply-templates select="document(concat('modules/', $org, '/', $mod, '/', $rev, '/packager.xml'),.)"/>
            </target>
            <xsl:value-of select="'&#10;&#10;'" />
          
          </xsl:for-each>
        </project>
    </xsl:template>

    <xsl:template match="org">
        <xsl:comment>
            <xsl:value-of select="concat(' *** Organisation: ', @name, ' ')"/>
        </xsl:comment>
        <echo><xsl:value-of select="concat('Verifying organisation ', @name, '...')"/></echo>
        
        <xsl:apply-templates select="mod[not($resolve.mod)
          or $resolve.mod = @name
          or starts-with($resolve.mod, concat(@name, ','))
          or contains($resolve.mod, concat(',', @name, ','))
          or substring($resolve.mod, string-length($resolve.mod) - string-length(@name)) = concat(',', @name)]"/>
    </xsl:template>

    <xsl:template match="mod">
        <xsl:comment>
            <xsl:value-of select="concat(' ***** Module: ', @name, ' ')"/>
        </xsl:comment>
        <xsl:apply-templates select="rev[not($resolve.rev)
          or $resolve.rev = @name
          or starts-with($resolve.rev, concat(@name, ','))
          or contains($resolve.rev, concat(',', @name, ','))
          or substring($resolve.rev, string-length($resolve.rev) - string-length(@name)) = concat(',', @name)]"/>
    </xsl:template>

    <xsl:template match="rev">
        <xsl:variable name="org" select="../../@name"/>
        <xsl:variable name="mod" select="../@name"/>
        <xsl:variable name="rev" select="@name"/>
        <xsl:variable name="packagerfile" select="concat($org, '/', $mod, '/', $rev, '/packager.xml')"/>
        <xsl:comment>
            <xsl:value-of select="concat(' ******* Revision: ', $rev, ' ')"/>
        </xsl:comment>

        <!-- call verify target -->
        <antcall target="{$org}#{$mod};{$rev}">
          <param name="ivy.packager.organisation" value="{$org}"/>
          <param name="ivy.packager.module" value="{$mod}"/>
          <param name="ivy.packager.revision" value="{$rev}"/>
          <param name="packagerfile" value="{$packagerfile}"/>
      <xsl:if test="document(concat('modules/', $org, '/', $mod, '/', $rev, '/ivy.xml'),.)/ivy-module/info/@branch">
          <param name="ivy.packager.branch">
          <xsl:attribute name="value">
          <xsl:value-of select="document(concat('modules/', $org, '/', $mod, '/', $rev, '/ivy.xml'),.)/ivy-module/info/@branch"/>
          </xsl:attribute>
          </param>
      </xsl:if>
        </antcall>
    </xsl:template>

 <!-- packager.xml: Copy property tags -->
  <xsl:template match="/packager-module/property">
    <xsl:copy-of select="."/>
  </xsl:template>
  
   <!-- packager.xml: Maven2 resources (from resolver.xsl) -->
    <xsl:template match="/packager-module/m2resource">

        <!-- Convert groupId into URL directories, where dots become slashes -->
        <xsl:variable name="groupdirs" select="'groupdirs'"/>
           <xsl:variable name="groupId">
                <xsl:choose>
                    <xsl:when test="@groupId">
                        <xsl:value-of select="@groupId"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'${ivy.packager.organisation}'"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
        <pathconvert property="groupdir" dirsep="/">
          <path location="{$groupId}"/>
            <mapper type="unpackage"  to="*">
            <xsl:attribute name="from">
              <xsl:value-of select="'${basedir}${file.separator}*'"/>
            </xsl:attribute>
            </mapper>
        </pathconvert>

        <!-- Get maven2 artifactId (or use default) -->
        <xsl:variable name="artifactId">
            <xsl:choose>
                <xsl:when test="@artifactId">
                    <xsl:value-of select="@artifactId"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="'${ivy.packager.module}'"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <!-- Get maven2 version (or use default) -->
        <xsl:variable name="version">
            <xsl:choose>
                <xsl:when test="@version">
                    <xsl:value-of select="@version"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="'${ivy.packager.revision}'"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <!-- Get maven2 repository URL (or use default) -->
        <xsl:variable name="repourl">
            <xsl:choose>
                <xsl:when test="@repo and substring(@repo, string-length(@repo) - 1) = '/'">
                    <xsl:value-of select="@repo"/>
                </xsl:when>
                <xsl:when test="@repo">
                    <xsl:value-of select="concat(@repo, '/')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$maven2repo"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <!-- Compose directory in the maven2 repository -->
        <xsl:variable name="m2dir" select="concat($repourl, '${groupdir}/', $artifactId, '/', $version, '/')"/>

        <xsl:value-of select="'&#10;'" />
        <get-and-print packagerfile="${{packagerfile}}">
        <!-- Iterate over artifacts -->
        <xsl:for-each select="artifact">

            <!-- Get classifier (or use default) -->
            <xsl:variable name="classifier">
                <xsl:choose>
                    <xsl:when test="@classifier">
                        <xsl:value-of select="concat('-', @classifier)"/>
                    </xsl:when>
                    <xsl:otherwise/>
                </xsl:choose>
            </xsl:variable>

            <!-- Get classifier (or use default) -->
            <xsl:variable name="suffix">
                <xsl:choose>
                    <xsl:when test="@ext">
                        <xsl:value-of select="concat('.', @ext)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'.jar'"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>

            <!-- Compose to get filename, then complete URL -->
            <xsl:variable name="filename" select="concat($artifactId, '-', $version, $classifier, $suffix)"/>
            <xsl:variable name="url" select="concat($m2dir, $filename)"/>

            <!-- Get resource -->
            <url url="{$url}"/>
        </xsl:for-each>
        </get-and-print>
        <xsl:value-of select="'&#10;'" />
    </xsl:template>

  <!-- packager.xml: Analyse resource URL -->
  <xsl:template match="/packager-module/resource[@url]">
  <!-- 
    <xsl:message>resource/@url
    <xsl:value-of select="node()" />
    </xsl:message>
   -->
     <xsl:value-of select="'&#10;'" />
     <get-and-print packagerfile="${{packagerfile}}">
        <url url="{@url}"/>
        <xsl:apply-templates select="url"/>
     </get-and-print>
     <xsl:value-of select="'&#10;'" />
  </xsl:template>

  <!-- packager.xml: Analyse resource URL -->
  <xsl:template match="/packager-module/resource/url">
     <url><xsl:attribute name="url"><xsl:value-of select="@href"/></xsl:attribute>
     </url>
    <xsl:value-of select="'&#10;'" />
  </xsl:template>

  <xsl:template match="@*|node()">
    <xsl:apply-templates select="@*|node()" />
  </xsl:template>
</xsl:transform>
