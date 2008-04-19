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

<!-- $Id: genbuilder.xsl 39 2008-04-10 16:17:36Z archie.cobbs $ -->
<xsl:transform
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:pipe="http://xml.apache.org/xalan/PipeDocument"
  extension-element-prefixes="pipe"
  version="1.0">

    <xsl:template match="/modules/org/mod/rev">
        <xsl:variable name="org" select="../../@name"/>
        <xsl:variable name="mod" select="../@name"/>
        <xsl:variable name="rev" select="@name"/>
        <pipe:pipeDocument source="../src/modules/{$org}/{$mod}/{$rev}/builder.xml" target="repo/modules/{$org}/{$mod}/{$rev}/builder.xml">
            <stylesheet href="builder-repo.xsl">
                <param name="organisation" value="{$org}"/>
                <param name="module" value="{$mod}"/>
                <param name="revision" value="{$rev}"/>
            </stylesheet>
        </pipe:pipeDocument>
    </xsl:template>

    <xsl:template match="*">
        <xsl:apply-templates/>
    </xsl:template>

</xsl:transform>
