<?xml version="1.0" encoding="ISO-8859-1"?>

<!-- $Id$ -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<!--
  You can copy and modify this xsl for your own use, providing that transformed
  ivy files keep a visible link to ivy site (if you don't modify it, it's the 
  link on ivy logo), and that you respect the following license

  BSD License for IvyRep
Copyright (c) 2005, JAYASOFT
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, 
are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice, 
      this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, 
      this list of conditions and the following disclaimer in the documentation 
      and/or other materials provided with the distribution.
    * Neither the name of JAYASOFT nor the names of its contributors 
      may be used to endorse or promote products derived from this software 
      without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE 
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR 
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES 
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; 
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON 
ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT 
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS 
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
  -->
<xsl:template match="/ivy-module">
    <xsl:variable name="repositories" select="/ivy-module/info/repository"/>
    <xsl:variable name="ivyauthors" select="/ivy-module/info/ivyauthor"/>
    <xsl:variable name="licenses" select="/ivy-module/info/license"/>
    <xsl:variable name="module" select="/ivy-module/info/@module"/>
    <xsl:variable name="organisation" select="/ivy-module/info/@organisation"/>
    <xsl:variable name="revision" select="/ivy-module/info/@revision"/>
    <xsl:variable name="configurations" select="/ivy-module/configurations"/>
    <xsl:variable name="public.conf" select="$configurations/conf[not(@visibility) and not(@deprecated)] | $configurations/conf[@visibility='public' and not(@deprecated)]"/>
    <xsl:variable name="deprecated.conf" select="configurations/conf[not(@visibility) and @deprecated] | configurations/conf[@visibility='public' and @deprecated]"/>
    <xsl:variable name="private.conf" select="configurations/conf[@visibility='private']"/>

    <xsl:variable name="artifacts" select="/ivy-module/publications/artifact"/>
    <xsl:variable name="dependencies" select="/ivy-module/dependencies/dependency"/>

  <html>
  <head>
    <title><xsl:value-of select="info/@module"/> by <xsl:value-of select="info/@organisation"/> :: Ivy RoundUp</title>
    <meta http-equiv="content-type" content="text/html; charset=ISO-8859-1" />
    <meta http-equiv="content-language" content="en" />
    <meta name="robots" content="index,follow" />
    <link rel="stylesheet" type="text/css" href="../../../../css/ivy-style.css" /> 
  </head>
  <body>
    <div id="logo"><a href="http://ant.apache.org/ivy/"><img src="../../../../images/logo.png"/></a><br/><a id="rep" href="http://ivyroundup.googlecode.com/">Ivy RoundUp Repository</a></div>
    <h1>
    <span id="module">
	        <xsl:element name="a">
	            <xsl:attribute name="href">../../../<xsl:value-of select="info/@organisation"/>/<xsl:value-of select="info/@module"/>/</xsl:attribute>
	            <xsl:value-of select="info/@module"/>
	        </xsl:element>
    </span> 
    by 
    <span id="organisation">
	        <xsl:element name="a">
	            <xsl:attribute name="href">../../../<xsl:value-of select="info/@organisation"/>/</xsl:attribute>
	            <xsl:value-of select="info/@organisation"/>
	        </xsl:element> 
    </span></h1>
    <div id="revision"><span id="revision">Revision: </span><xsl:value-of select="info/@revision"/></div>
    <table class="header">
    <tr><td class="title">Status</td><td class="value"><xsl:value-of select="info/@status"/></td></tr>
    <tr><td class="title">Home Page</td><td class="value">
    	<xsl:if test="info/description/@homepage">
	        <xsl:element name="a">
	            <xsl:attribute name="href"><xsl:value-of select="info/description/@homepage"/></xsl:attribute>
	            <xsl:value-of select="info/description/@homepage"/>
	        </xsl:element>
    	</xsl:if>
    </td></tr>
    <tr><td class="title">Licenses</td><td class="value">
	    <xsl:for-each select="$licenses">
    	<xsl:if test="@url">
	        <xsl:element name="a">
	            <xsl:attribute name="href"><xsl:value-of select="@url"/></xsl:attribute>
		    	<xsl:value-of select="@name"/>
	        </xsl:element>
    	</xsl:if>
    	<xsl:if test="not(@url)">
		    	<xsl:value-of select="@name"/>
    	</xsl:if>
	    </xsl:for-each>
    </td></tr>
    <tr><td class="title">Ivy Authors</td><td class="value">
	    <xsl:for-each select="$ivyauthors">
    	<xsl:if test="@url">
	        <xsl:element name="a">
	            <xsl:attribute name="href"><xsl:value-of select="@url"/></xsl:attribute>
		    	<xsl:value-of select="@name"/>
	        </xsl:element>
    	</xsl:if>
    	<xsl:if test="not(@url)">
		    	<xsl:value-of select="@name"/>
    	</xsl:if>
	    </xsl:for-each>
    </td></tr>
    <tr><td class="title">Description</td><td class="value"><xsl:copy-of select="info/description"/></td></tr>
    </table>

    <xsl:if test="false() and count($repositories) > 0">
    <div id="repositories">
    <h2>Public Repositories</h2>
    <table>
    <thead>
    <tr>
      <th>Name</th>
      <th>Url</th>
      <th>Pattern</th>
      <th>Ivys</th>
      <th>Artifacts</th>
    </tr>
    </thead>
    <tbody>
    <xsl:for-each select="$repositories">
    <tr>
      <td><xsl:value-of select="@name"/></td>
      <td>
        <xsl:element name="a">
            <xsl:attribute name="href"><xsl:value-of select="@url"/></xsl:attribute>
	    	<xsl:value-of select="@url"/>
        </xsl:element>
      </td>
      <td><xsl:value-of select="@pattern"/></td>
      <td><xsl:value-of select="@ivys"/></td>
      <td><xsl:value-of select="@artifacts"/></td>
    </tr>
    </xsl:for-each>
    </tbody>
    </table>
    </div>
    </xsl:if>

    <div id="public-confs" class="conf">
    <h2>Public Configurations</h2>
    <table>
    <thead>
    <tr>
      <th class="conf-name">Name</th>
      <th class="conf-desc">Description</th>
      <th class="conf-extends">Extends</th>
    </tr>
    </thead>
    <tbody>
    <xsl:for-each select="$public.conf">
    <tr>
      <td><xsl:value-of select="@name"/></td>
      <td><xsl:value-of select="@description"/></td>
      <td><xsl:value-of select="@extends"/></td>
    </tr>
    </xsl:for-each>
    <xsl:if test="count($public.conf) = 0">
    <tr>
      <td>default</td>
      <td><i>Implicit default configuration</i></td>
      <td></td>
    </tr>
    </xsl:if>
    </tbody>
    </table>
    </div>

    <xsl:if test="count($deprecated.conf) > 0">
    <div id="deprecated-confs" class="conf">
    <h2>Deprecated Configurations</h2>
    <table>
    <thead>
    <tr>
      <th class="conf-name">Name</th>
      <th class="conf-desc">Description</th>
      <th class="conf-extends">Extends</th>
    </tr>
    </thead>
    <tbody>
    <xsl:for-each select="$deprecated.conf">
    <tr>
      <td><xsl:value-of select="@name"/></td>
      <td><xsl:value-of select="@description"/></td>
      <td><xsl:value-of select="@extends"/></td>
    </tr>
    </xsl:for-each>
    </tbody>
    </table>
    </div>
    </xsl:if>

    <xsl:if test="count($private.conf) > 0">
    <div id="deprecated-confs" class="conf">
    <h2>Private Configurations</h2>
    <table>
    <thead>
    <tr>
      <th class="conf-name">Name</th>
      <th class="conf-desc">Description</th>
      <th class="conf-extends">Extends</th>
    </tr>
    </thead>
    <tbody>
    <xsl:for-each select="$private.conf">
    <tr>
      <td><xsl:value-of select="@name"/></td>
      <td><xsl:value-of select="@description"/></td>
      <td><xsl:value-of select="@extends"/></td>
    </tr>
    </xsl:for-each>
    </tbody>
    </table>
    </div>
    </xsl:if>

    <div id="artifacts">
    <h2>Published Artifacts</h2>
    <table>
    <thead>
    <tr>
      <th class="art-name">Name</th>
      <th class="art-type">Type</th>
      <th class="art-conf">Configurations</th>
    </tr>
    </thead>
    <tbody>
    <xsl:for-each select="$artifacts">
      <xsl:variable name="aname">
        <xsl:choose>
          <xsl:when test="@name">
            <xsl:value-of select="@name"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$module"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:variable name="atype">
        <xsl:choose>
          <xsl:when test="@type">
            <xsl:value-of select="@type"/>
          </xsl:when>
          <xsl:otherwise>jar</xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:variable name="aext">
        <xsl:choose>
          <xsl:when test="@ext">
            <xsl:value-of select="@ext"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$atype"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
    <tr>
      <td><xsl:value-of select="concat($aname, '.', $aext)"/></td>
      <td><xsl:value-of select="$atype"/></td>
      <td>
          <xsl:value-of select="@conf"/>
          <xsl:for-each select="conf">
            <xsl:if test="position() > 1">, 
            </xsl:if>
            <xsl:value-of select="@name"/>
          </xsl:for-each>
          <xsl:if test="not(@conf) and count(conf) = 0">
          <i>all</i>
          </xsl:if> 
      </td>
    </tr>
    </xsl:for-each>
    <xsl:if test="count($artifacts) = 0">
      <td><xsl:value-of select="info/@module"/></td>
      <td>jar</td>
      <td><i>all</i></td>
    </xsl:if>
    </tbody>
    </table>
    </div>

    <xsl:if test="count($dependencies) > 0">
    <div id="dependencies">
    <h2>Dependencies</h2>
    <table>
    <thead>
    <tr>
      <th class="dep-org">Organisation</th>
      <th class="dep-name">Name</th>
      <th class="dep-rev">Revision</th>
      <th class="dep-conf">Configurations</th>
    </tr>
    </thead>
    <tbody>
    <xsl:for-each select="$dependencies">
    <tr>
      <td><xsl:if test="not(@org)"><xsl:value-of select="/ivy-module/info/@organisation"/></xsl:if><xsl:value-of select="@org"/></td>
      <td>
        <xsl:element name="a">
            <xsl:attribute name="href">../../../../modules.xml#<xsl:value-of select="concat('module-', @name)"/></xsl:attribute>
		    <xsl:value-of select="@name"/>
        </xsl:element>
      </td>
      <td><xsl:value-of select="@rev"/></td>
      <td>
      <xsl:choose>
          <xsl:when test="@conf">
		    <xsl:value-of select="@conf"/>
          </xsl:when>
          <xsl:otherwise>*-&gt;*</xsl:otherwise>
      </xsl:choose>
      </td>
    </tr>
    </xsl:for-each>
    </tbody>
    </table>
    </div>
    </xsl:if>

    <xsl:variable name="builder" select="document('builder.xml', .)/builder-module"/>
    <div id="build-instructions" class="conf">
    <h2>Builder Instructions</h2>

    <xsl:if test="$builder/property">
    <table>
    <thead>
    <tr>
      <th class="conf-name">Property</th>
      <th class="conf-desc">Value</th>
    </tr>
    </thead>
    <tbody>
    <xsl:for-each select="$builder/property">
    <tr>
      <td><xsl:value-of select="@name"/></td>
      <td><xsl:value-of select="@value"/></td>
    </tr>
    </xsl:for-each>
    </tbody>
    </table>
    </xsl:if>

    <xsl:if test="$builder/resource">
    <table>
    <thead>
    <tr>
      <th class="conf-name">Resource</th>
      <th class="conf-name">Action</th>
      <th class="conf-desc">SHA1 Checksum</th>
    </tr>
    </thead>
    <tbody>
    <xsl:for-each select="$builder/resource">
    <tr>
      <td>
        <xsl:value-of select="@url"/>
        <xsl:for-each select="url/@href">
            <br/>
            <xsl:value-of select="concat('[', ., ']')"/>
        </xsl:for-each>
      </td>
      <td>
        <xsl:choose>
            <xsl:when test="@tofile">
                <xsl:value-of select="concat('Copy to ', @tofile)"/>
            </xsl:when>
            <xsl:when test="@dest">
                <xsl:value-of select="concat('Unpack into ', @dest, '/')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="'Unpack into archive/'"/>
            </xsl:otherwise>
        </xsl:choose>
      </td>
      <td><xsl:value-of select="@sha1"/></td>
    </tr>
    </xsl:for-each>
    </tbody>
    </table>
    </xsl:if>

    <xsl:if test="$builder/m2resource/artifact">
    <table>
    <thead>
    <tr>
      <th class="conf-name">Group ID</th>
      <th class="conf-name">Artifact ID</th>
      <th class="conf-name">Version</th>
      <th class="conf-name">Classifier</th>
      <th class="conf-name">Extension</th>
      <th class="conf-name">Action</th>
      <th class="conf-desc">SHA1 Checksum</th>
    </tr>
    </thead>
    <tbody>
    <xsl:for-each select="$builder/m2resource/artifact">
    <tr>
      <td>
        <xsl:choose>
            <xsl:when test="../@groupId">
                <xsl:value-of select="../@groupId"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$organisation"/>
            </xsl:otherwise>
        </xsl:choose>
      </td>
      <td>
        <xsl:choose>
            <xsl:when test="../@artifactId">
                <xsl:value-of select="../@artifactId"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$module"/>
            </xsl:otherwise>
        </xsl:choose>
      </td>
      <td>
        <xsl:choose>
            <xsl:when test="../@version">
                <xsl:value-of select="../@version"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$revision"/>
            </xsl:otherwise>
        </xsl:choose>
      </td>
      <td>
        <xsl:if test="@classifier">
            <xsl:value-of select="@classifier"/>
        </xsl:if>
      </td>
      <td>
        <xsl:choose>
            <xsl:when test="@ext">
                <xsl:value-of select="ext"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="'jar'"/>
            </xsl:otherwise>
        </xsl:choose>
      </td>
      <td>
        <xsl:choose>
            <xsl:when test="@tofile">
                <xsl:value-of select="concat('Copy to ', @tofile)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="concat('Unpack into ', @dest, '/')"/>
            </xsl:otherwise>
        </xsl:choose>
      </td>
      <td><xsl:value-of select="@sha1"/></td>
    </tr>
    </xsl:for-each>
    </tbody>
    </table>
    </xsl:if>

    <xsl:if test="$builder/build/node()">
    <table>
    <thead>
    <tr>
      <th class="conf-name">Build Steps</th>
    </tr>
    </thead>
    <tbody>
    <tr>
      <td><div class="build-inst"><xsl:apply-templates mode="escape" select="$builder/build/node()"/></div></td>
    </tr>
    </tbody>
    </table>
    </xsl:if>

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
