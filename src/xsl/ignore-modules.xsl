<?xml version="1.0" encoding="ISO-8859-1"?>

<!--
    Copyright 2011 Ales Nosek

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
    Remove modules from modules.xml which are defined in ignore.list
-->

<!-- $Id$ -->
<xsl:transform
  version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:ivy="urn:org.apache.ivy.ant">

  <xsl:output encoding="UTF-8" method="xml" indent="yes" media-type="text/xml"/>

  <!-- Modules to ignore -->
  <xsl:param name="ignore.list"/>

  <xsl:template match="/modules/org/mod/rev">
    <xsl:variable name="org" select="../../@name"/>
    <xsl:variable name="mod" select="../@name"/>
    <xsl:variable name="rev" select="@name"/>
    <xsl:choose>
      <xsl:when test="document($ignore.list, .)/modules/org[@name=$org]/mod[@name=$mod]/rev[@name=$rev]">
        <xsl:message><xsl:value-of select="concat('Ignoring module: ', $org, '/', $mod, '/', $rev)"/></xsl:message>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

</xsl:transform>
