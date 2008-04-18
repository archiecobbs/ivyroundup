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
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:import href="util.xsl"/>

<xsl:template match="/modules">
  <html>
  <head>
    <title>Ivy RoundUp Repository Contents</title>
    <meta http-equiv="content-type" content="text/html; charset=ISO-8859-1"/>
    <meta http-equiv="content-language" content="en"/>
    <meta name="robots" content="index,follow"/>
    <link rel="stylesheet" type="text/css" href="css/ivy-style.css" /> 
  </head>
  <body>

    <div id="logo"><a href="http://ant.apache.org/ivy/"><img src="images/logo.png"/></a><br/><a id="rep" href="http://ivyroundup.googlecode.com/">Ivy RoundUp Repository</a></div>
    <h1>
    <span id="module">Ivy RoundUp Repository Contents</span>
    </h1>

    <div id="revision"><span id="revision">Last Repository Build: </span><xsl:value-of select="timestamp"/> (r<xsl:value-of select="svnRevision"/>)</div>
    <p class="header">
    This page lists all revisions of all modules contained in the <a href="http://ivyroundup.googlecode.com/">Ivy RoundUp Repository</a>.
    </p>

    <div id="modules">
    <h2>Modules</h2>
    <table>
    <thead>
    <tr>
      <th>Name</th>
      <th>Organization</th>
      <th>Revisions</th>
    </tr>
    </thead>
    <tbody>
    <xsl:for-each select="org/mod">
    <xsl:sort select="@name"/>
    <xsl:variable name="orgdir">
        <xsl:call-template name="dot2slash">
            <xsl:with-param name="s" select="../@name"/>
        </xsl:call-template>
    </xsl:variable>
    <a>
        <xsl:attribute name="href">
            <xsl:value-of select="concat('module-', ../@name)"/>
        </xsl:attribute>
    </a>
    <tr>
      <td><xsl:value-of select="@name"/></td>
      <td><xsl:value-of select="../@name"/></td>
      <td>
      <xsl:for-each select="rev">
          <xsl:sort select="@name"/>
          <xsl:element name="a">
              <xsl:attribute name="href">
                  <xsl:value-of select="concat('modules/', $orgdir, '/', ../@name, '/', @name, '/ivy.xml')"/>
              </xsl:attribute>
              <span class="revision"><xsl:value-of select="@name"/></span>
          </xsl:element>
          <xsl:value-of select="'&#160;'"/>
      </xsl:for-each>
      </td>
    </tr>
    </xsl:for-each>
    </tbody>
    </table>
    </div>

  </body>
  </html>
</xsl:template>

<xsl:template mode="escape" match="comment()">
    <xsl:value-of select="concat('&lt;!--', ., '--&gt;')"/>
</xsl:template>

<xsl:template mode="escape" match="*">
    <xsl:value-of select="concat('&lt;', name(.))"/>
    <xsl:apply-templates select="@*" mode="escape"/>
    <xsl:choose>
        <xsl:when test="node()">
            <xsl:value-of select="'&gt;'"/>
            <xsl:apply-templates select="node()" mode="escape"/>
            <xsl:value-of select="concat('&lt;/', name(.), '&gt;')"/>
        </xsl:when>
        <xsl:otherwise>
            <xsl:value-of select="'/&gt;'"/>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template mode="escape" match="@*">
    <xsl:value-of select="concat(' ', name(.), '=&quot;', ., '&quot;')"/>
</xsl:template>

<xsl:template mode="escape" match="text()">
    <xsl:value-of select="."/>
</xsl:template>

</xsl:stylesheet>
