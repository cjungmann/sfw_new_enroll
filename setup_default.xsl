<?xml version="1.0" encoding="utf-8" ?>

<xsl:stylesheet
    version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:html="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="html">

  <xsl:output
      method="xml"
      version="1.0"
      indent="yes"
      encoding="utf-8"/>

  <xsl:param name="version" select="'debug'" />
  <xsl:param name="sheet" />
  <xsl:param name="app_title">Enrollment Template</xsl:param>

  <xsl:variable name="nl">&#xa;&#xd;</xsl:variable>

  <!-- Generic node copying stuff -->

  <xsl:template match="/">
    <xsl:apply-templates select="node()" />
  </xsl:template>

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="text()"><xsl:value-of select="." /></xsl:template>

  <xsl:template match="comment()">
    <xsl:comment><xsl:value-of select="." /></xsl:comment>
  </xsl:template>

  <xsl:template match="processing-instruction()">
    <xsl:processing-instruction name="{local-name()}">
      <xsl:value-of select="." />
    </xsl:processing-instruction>
  </xsl:template>

  <!-- xsl stylesheet-specific templates -->

  <!-- Explicitly match root element to preserve xmlns attributes. -->
  <xsl:template match="xsl:stylesheet">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" />
    </xsl:copy>
  </xsl:template>

  <!-- Explicitly match xsl types in order to add the xsl prefix -->
  <xsl:template match="xsl:*">
    <xsl:element name="xsl:{local-name()}">
      <xsl:apply-templates select="@*" />
      <xsl:apply-templates select="node()" />
    </xsl:element>
  </xsl:template>

  <!-- Customization -->

  <!-- Override templates to remove comments and processing-instructions: -->
  <xsl:template match="comment()"></xsl:template>
  <xsl:template match="processing-instruction()"></xsl:template>

  <!--
      Consult parameter to use debug or compiled imports,
      then import custom stylesheet. 
  -->
  <xsl:template match="xsl:import[contains(@href,'debug.xsl')]">
    <xsl:element name="xsl:import">
      <xsl:attribute name="href">
        <xsl:choose>
          <xsl:when test="$version = 'debug'">
            <xsl:text>includes/sfw_debug.xsl</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>includes/sfw_compiled.xsl</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
    </xsl:element>

    <!-- Uncomment following to add import of custom stylesheet after other import. -->
    <!-- <xsl:element name="xsl:import"> -->
    <!--   <xsl:attribute name="href">concal.xsl</xsl:attribute> -->
    <!-- </xsl:element> -->

  </xsl:template>

  <!-- Consult parameter to use debug or combined/minimized javascript. -->
  <xsl:template match="xsl:apply-templates[@mode='fill_head']/xsl:with-param[@name='jscripts']">
    <xsl:copy>
      <xsl:apply-templates select="@*" />
      <xsl:choose>
        <xsl:when test="$version = 'debug'">debug</xsl:when>
        <xsl:otherwise>sfw.min</xsl:otherwise>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="html:title|html:h1">
    <xsl:element name="{local-name()}">
      <xsl:value-of select="$app_title" />
    </xsl:element>
  </xsl:template>

  <xsl:template match="html:head">
    <head>
      <xsl:apply-templates select="*" />
      <xsl:value-of select="$nl" />

      <!-- Uncomment to add custom stylesheet at the end of the head element: -->
      <!-- <link rel="stylesheet" type="text/css" href="concal.css"></link> -->
    </head>
  </xsl:template>

</xsl:stylesheet>
