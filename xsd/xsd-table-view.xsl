<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  exclude-result-prefixes="xs">

  <xsl:output method="html" encoding="UTF-8" indent="yes"/>
  <xsl:strip-space elements="*"/>

  <xsl:template match="/xs:schema">
    <html lang="en">
      <head>
        <meta charset="UTF-8"/>
        <meta name="viewport" content="width=device-width, initial-scale=1"/>
        <title>XSD table view</title>
        <style>
          :root { color-scheme: light dark; }
          body { font-family: system-ui, -apple-system, "Segoe UI", sans-serif; margin: 2rem; line-height: 1.4; }
          h1, h2 { line-height: 1.15; }
          .meta { display: grid; grid-template-columns: max-content 1fr; gap: .35rem 1rem; margin-bottom: 2rem; }
          .meta dt { font-weight: 700; }
          .meta dd { margin: 0; overflow-wrap: anywhere; }
          .table-wrap { overflow-x: auto; margin-bottom: 2.5rem; }
          table { border-collapse: collapse; width: 100%; min-width: 760px; }
          th, td { border: 1px solid #9998; padding: .45rem .6rem; text-align: left; vertical-align: top; }
          th { position: sticky; top: 0; background: Canvas; font-weight: 700; }
          tbody tr:nth-child(even) { background: color-mix(in srgb, CanvasText 5%, Canvas); }
          code { font-family: ui-monospace, "Cascadia Code", Consolas, monospace; font-size: .92em; }
          .muted { opacity: .72; }
          .empty { font-style: italic; opacity: .7; }
          .path { white-space: nowrap; }
          @media print { body { margin: .7cm; font-size: 9pt; } th { position: static; } }
        </style>
      </head>
      <body>
        <h1>XSD table view</h1>

        <dl class="meta">
          <dt>Target namespace</dt><dd><code><xsl:value-of select="@targetNamespace"/></code></dd>
          <dt>Default namespace</dt><dd><code><xsl:value-of select="@xmlns"/></code></dd>
          <dt>Element form</dt><dd><code><xsl:value-of select="@elementFormDefault"/></code></dd>
          <dt>Attribute form</dt><dd><code><xsl:value-of select="@attributeFormDefault"/></code></dd>
        </dl>

        <h2>Imports and includes</h2>
        <div class="table-wrap">
          <table>
            <thead><tr><th>Kind</th><th>Namespace</th><th>Schema location</th></tr></thead>
            <tbody>
              <xsl:apply-templates select="xs:import | xs:include" mode="dependency"/>
              <xsl:if test="not(xs:import | xs:include)">
                <tr><td colspan="3" class="empty">None</td></tr>
              </xsl:if>
            </tbody>
          </table>
        </div>

        <h2>Elements</h2>
        <div class="table-wrap">
          <table>
            <thead>
              <tr>
                <th>Path</th><th>Name</th><th>Declared type</th><th>Min</th><th>Max</th><th>Inline structure</th>
              </tr>
            </thead>
            <tbody>
              <xsl:apply-templates select=".//xs:element" mode="element-row"/>
              <xsl:if test="not(.//xs:element)">
                <tr><td colspan="6" class="empty">None</td></tr>
              </xsl:if>
            </tbody>
          </table>
        </div>

        <h2>Named types</h2>
        <div class="table-wrap">
          <table>
            <thead>
              <tr>
                <th>Name</th><th>Kind</th><th>Base</th><th>Content model</th><th>Facets or alternatives</th>
              </tr>
            </thead>
            <tbody>
              <xsl:apply-templates select="xs:complexType | xs:simpleType" mode="type-row"/>
              <xsl:if test="not(xs:complexType | xs:simpleType)">
                <tr><td colspan="5" class="empty">None</td></tr>
              </xsl:if>
            </tbody>
          </table>
        </div>

        <h2>Attributes</h2>
        <div class="table-wrap">
          <table>
            <thead>
              <tr><th>Owner</th><th>Name</th><th>Type</th><th>Use</th><th>Default</th><th>Fixed</th></tr>
            </thead>
            <tbody>
              <xsl:apply-templates select=".//xs:attribute" mode="attribute-row"/>
              <xsl:if test="not(.//xs:attribute)">
                <tr><td colspan="6" class="empty">None</td></tr>
              </xsl:if>
            </tbody>
          </table>
        </div>
      </body>
    </html>
  </xsl:template>

  <xsl:template match="xs:import | xs:include" mode="dependency">
    <tr>
      <td><code><xsl:value-of select="local-name()"/></code></td>
      <td><code><xsl:value-of select="@namespace"/></code></td>
      <td><code><xsl:value-of select="@schemaLocation"/></code></td>
    </tr>
  </xsl:template>

  <xsl:template match="xs:element" mode="element-row">
    <tr>
      <td class="path"><code><xsl:call-template name="element-path"/></code></td>
      <td><code><xsl:choose><xsl:when test="@name"><xsl:value-of select="@name"/></xsl:when><xsl:otherwise>ref: <xsl:value-of select="@ref"/></xsl:otherwise></xsl:choose></code></td>
      <td><code><xsl:value-of select="@type"/></code></td>
      <td><code><xsl:choose><xsl:when test="@minOccurs"><xsl:value-of select="@minOccurs"/></xsl:when><xsl:otherwise>1</xsl:otherwise></xsl:choose></code></td>
      <td><code><xsl:choose><xsl:when test="@maxOccurs"><xsl:value-of select="@maxOccurs"/></xsl:when><xsl:otherwise>1</xsl:otherwise></xsl:choose></code></td>
      <td>
        <xsl:choose>
          <xsl:when test="xs:complexType">complex type</xsl:when>
          <xsl:when test="xs:simpleType">simple type</xsl:when>
          <xsl:otherwise><span class="muted">No</span></xsl:otherwise>
        </xsl:choose>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match="xs:complexType | xs:simpleType" mode="type-row">
    <tr>
      <td><code><xsl:value-of select="@name"/></code></td>
      <td><code><xsl:value-of select="local-name()"/></code></td>
      <td><code><xsl:value-of select="(xs:restriction/@base | xs:extension/@base | xs:simpleContent/xs:extension/@base | xs:complexContent/xs:extension/@base | xs:simpleContent/xs:restriction/@base | xs:complexContent/xs:restriction/@base)[1]"/></code></td>
      <td>
        <xsl:choose>
          <xsl:when test="xs:sequence or .//xs:sequence">sequence</xsl:when>
          <xsl:when test="xs:choice or .//xs:choice">choice</xsl:when>
          <xsl:when test="xs:all or .//xs:all">all</xsl:when>
          <xsl:when test="xs:simpleContent">simple content</xsl:when>
          <xsl:when test="xs:complexContent">complex content</xsl:when>
        </xsl:choose>
      </td>
      <td>
        <xsl:for-each select=".//xs:enumeration | .//xs:pattern | .//xs:minInclusive | .//xs:maxInclusive | .//xs:minLength | .//xs:maxLength | .//xs:length">
          <code><xsl:value-of select="local-name()"/>=<xsl:value-of select="@value"/></code><xsl:if test="position() != last()"><br/></xsl:if>
        </xsl:for-each>
        <xsl:if test=".//xs:choice/xs:element">
          <xsl:if test=".//xs:enumeration | .//xs:pattern | .//xs:minInclusive | .//xs:maxInclusive | .//xs:minLength | .//xs:maxLength | .//xs:length"><br/></xsl:if>
          <span class="muted">choice: </span>
          <xsl:for-each select=".//xs:choice/xs:element">
            <code><xsl:value-of select="@name"/></code><xsl:if test="position() != last()">, </xsl:if>
          </xsl:for-each>
        </xsl:if>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match="xs:attribute" mode="attribute-row">
    <tr>
      <td><code><xsl:call-template name="attribute-owner"/></code></td>
      <td><code><xsl:choose><xsl:when test="@name"><xsl:value-of select="@name"/></xsl:when><xsl:otherwise>ref: <xsl:value-of select="@ref"/></xsl:otherwise></xsl:choose></code></td>
      <td><code><xsl:value-of select="@type"/></code></td>
      <td><code><xsl:choose><xsl:when test="@use"><xsl:value-of select="@use"/></xsl:when><xsl:otherwise>optional</xsl:otherwise></xsl:choose></code></td>
      <td><code><xsl:value-of select="@default"/></code></td>
      <td><code><xsl:value-of select="@fixed"/></code></td>
    </tr>
  </xsl:template>

  <xsl:template name="element-path">
    <xsl:for-each select="ancestor-or-self::xs:element">
      <xsl:text>/</xsl:text>
      <xsl:choose><xsl:when test="@name"><xsl:value-of select="@name"/></xsl:when><xsl:otherwise><xsl:value-of select="@ref"/></xsl:otherwise></xsl:choose>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="attribute-owner">
    <xsl:choose>
      <xsl:when test="ancestor::xs:complexType[@name]"><xsl:value-of select="ancestor::xs:complexType[@name][1]/@name"/></xsl:when>
      <xsl:when test="ancestor::xs:simpleType[@name]"><xsl:value-of select="ancestor::xs:simpleType[@name][1]/@name"/></xsl:when>
      <xsl:when test="ancestor::xs:element"><xsl:for-each select="ancestor::xs:element"><xsl:text>/</xsl:text><xsl:value-of select="@name"/></xsl:for-each></xsl:when>
      <xsl:otherwise>schema</xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
