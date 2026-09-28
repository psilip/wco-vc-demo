<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  exclude-result-prefixes="xs">

  <xsl:output method="html" encoding="UTF-8" indent="yes"/>
  <xsl:strip-space elements="*"/>

  <xsl:key name="type-by-name" match="xs:complexType[@name] | xs:simpleType[@name]" use="@name"/>

  <xsl:template match="/xs:schema">
    <html lang="en">
      <head>
        <meta charset="UTF-8"/>
        <meta name="viewport" content="width=device-width, initial-scale=1"/>
        <title>XSD outline view</title>
        <style>
          :root {
            color-scheme: light dark;
            --bg: Canvas;
            --fg: CanvasText;
            --muted: color-mix(in srgb, CanvasText 58%, transparent);
            --faint: color-mix(in srgb, CanvasText 8%, Canvas);
            --line: color-mix(in srgb, CanvasText 18%, transparent);
            --accent: #2563eb;
            --container: #7c3aed;
            --type: #047857;
          }
          * { box-sizing: border-box; }
          body {
            max-width: 1120px;
            margin: 0 auto;
            padding: 2rem clamp(1rem, 3vw, 3rem) 4rem;
            background: var(--bg);
            color: var(--fg);
            font-family: system-ui, -apple-system, "Segoe UI", sans-serif;
            line-height: 1.45;
          }
          h1, h2 { line-height: 1.2; }
          h1 { margin-bottom: .35rem; }
          h2 { margin-top: 2.8rem; border-bottom: 1px solid var(--line); padding-bottom: .4rem; }
          a { color: var(--accent); text-decoration-thickness: .08em; text-underline-offset: .15em; }
          code, .mono {
            font-family: ui-monospace, "Cascadia Code", "SFMono-Regular", Consolas, monospace;
          }
          .meta {
            margin: 0 0 2rem;
            color: var(--muted);
            overflow-wrap: anywhere;
          }
          .toolbar {
            position: sticky;
            top: 0;
            z-index: 10;
            display: flex;
            flex-wrap: wrap;
            gap: .5rem;
            padding: .65rem 0;
            background: color-mix(in srgb, var(--bg) 92%, transparent);
            backdrop-filter: blur(8px);
            border-bottom: 1px solid var(--line);
          }
          button {
            border: 1px solid var(--line);
            border-radius: .4rem;
            padding: .35rem .65rem;
            background: var(--faint);
            color: var(--fg);
            cursor: pointer;
          }
          button:hover { border-color: var(--accent); }
          details { margin: .18rem 0; }
          details > summary { cursor: pointer; list-style-position: outside; }
          details.node {
            margin-left: 1.15rem;
            border-left: 1px solid var(--line);
            padding-left: .8rem;
          }
          details.node > summary { margin-left: -.1rem; }
          .root > details.node { margin-left: 0; }
          .children { margin: .25rem 0 .45rem; }
          .leaf {
            display: grid;
            grid-template-columns: minmax(14rem, 1fr) minmax(16rem, 1.2fr) auto;
            align-items: baseline;
            gap: .5rem 1rem;
            margin: .18rem 0 .18rem 2rem;
            padding: .12rem .2rem;
          }
          .leaf:hover { background: var(--faint); }
          .name { font-weight: 650; }
          .container-name { color: var(--container); font-weight: 720; }
          .type-name { color: var(--type); }
          .cardinality {
            color: var(--muted);
            font-size: .9em;
            white-space: nowrap;
          }
          .keyword { color: var(--muted); }
          .type-block {
            margin: .45rem 0 .8rem 1.15rem;
            padding: .65rem .8rem;
            border-left: 2px solid var(--line);
            background: var(--faint);
          }
          .field {
            display: grid;
            grid-template-columns: minmax(11rem, .8fr) minmax(14rem, 1fr) auto;
            gap: .4rem 1rem;
            padding: .12rem 0;
          }
          .section-label {
            margin-top: .45rem;
            color: var(--muted);
            font-size: .84rem;
            font-weight: 750;
            text-transform: uppercase;
            letter-spacing: .06em;
          }
          .dependency {
            margin: .3rem 0;
            padding-left: 1rem;
            border-left: 2px solid var(--line);
            overflow-wrap: anywhere;
          }
          .annotation {
            margin: .25rem 0 .4rem 2rem;
            color: var(--muted);
            font-style: italic;
          }
          .empty { color: var(--muted); font-style: italic; }
          @media (max-width: 760px) {
            .leaf, .field { grid-template-columns: 1fr; gap: 0; }
            .leaf { margin-left: 1.2rem; }
          }
          @media print {
            .toolbar { display: none; }
            details > * { display: block !important; }
            body { max-width: none; padding: 0; font-size: 9pt; }
          }
        </style>
        <script>
          function setAll(openState) {
            document.querySelectorAll('details').forEach(function (d) { d.open = openState; });
          }
          function openStructure() {
            document.querySelectorAll('details').forEach(function (d) { d.open = false; });
            document.querySelectorAll('#structure details').forEach(function (d) { d.open = true; });
          }
        </script>
      </head>
      <body>
        <h1>XSD outline view</h1>
        <p class="meta">
          <span class="keyword">target namespace:</span>
          <code><xsl:value-of select="@targetNamespace"/></code>
        </p>

        <div class="toolbar">
          <button type="button" onclick="setAll(true)">Expand all</button>
          <button type="button" onclick="setAll(false)">Collapse all</button>
          <button type="button" onclick="openStructure()">Show structure</button>
        </div>

        <xsl:if test="xs:import or xs:include">
          <h2>Dependencies</h2>
          <xsl:apply-templates select="xs:import | xs:include" mode="dependency"/>
        </xsl:if>

        <h2>Schema structure</h2>
        <div id="structure" class="root">
          <xsl:choose>
            <xsl:when test="xs:element">
              <xsl:apply-templates select="xs:element" mode="outline"/>
            </xsl:when>
            <xsl:otherwise><p class="empty">No global elements.</p></xsl:otherwise>
          </xsl:choose>
        </div>

        <xsl:if test="xs:complexType[@name] or xs:simpleType[@name]">
          <h2>Named types</h2>
          <div id="types">
            <xsl:apply-templates select="xs:complexType[@name] | xs:simpleType[@name]" mode="named-type"/>
          </div>
        </xsl:if>
      </body>
    </html>
  </xsl:template>

  <xsl:template match="xs:import | xs:include" mode="dependency">
    <div class="dependency">
      <span class="name"><xsl:value-of select="local-name()"/></span>
      <xsl:if test="@namespace">
        <xsl:text> </xsl:text><code><xsl:value-of select="@namespace"/></code>
      </xsl:if>
      <xsl:if test="@schemaLocation">
        <br/><span class="keyword">location: </span>
        <a href="{@schemaLocation}"><code><xsl:value-of select="@schemaLocation"/></code></a>
      </xsl:if>
    </div>
  </xsl:template>

  <xsl:template match="xs:element" mode="outline">
    <xsl:variable name="has-children" select="xs:complexType/xs:sequence/xs:element or xs:complexType/xs:choice/xs:element or xs:complexType/xs:all/xs:element or xs:complexType/xs:complexContent//xs:element"/>
    <xsl:choose>
      <xsl:when test="$has-children">
        <details class="node" open="open">
          <summary>
            <span class="container-name"><xsl:call-template name="element-name"/></span>
            <xsl:text> </xsl:text>
            <span class="cardinality"><xsl:call-template name="cardinality"/></span>
            <xsl:if test="@type">
              <xsl:text> </xsl:text><span class="type-name mono"><xsl:value-of select="@type"/></span>
            </xsl:if>
          </summary>
          <xsl:call-template name="documentation"/>
          <div class="children">
            <xsl:apply-templates select="xs:complexType/xs:sequence/xs:element | xs:complexType/xs:choice/xs:element | xs:complexType/xs:all/xs:element | xs:complexType/xs:complexContent//xs:element" mode="outline"/>
          </div>
        </details>
      </xsl:when>
      <xsl:otherwise>
        <div class="leaf">
          <span class="name mono"><xsl:call-template name="element-name"/></span>
          <span class="type-name mono">
            <xsl:choose>
              <xsl:when test="@type">
                <xsl:call-template name="type-link">
                  <xsl:with-param name="qname" select="@type"/>
                </xsl:call-template>
              </xsl:when>
              <xsl:when test="xs:simpleType/xs:restriction/@base"><xsl:value-of select="xs:simpleType/xs:restriction/@base"/></xsl:when>
              <xsl:when test="xs:complexType/xs:simpleContent/xs:extension/@base"><xsl:value-of select="xs:complexType/xs:simpleContent/xs:extension/@base"/></xsl:when>
              <xsl:otherwise><span class="keyword">inline type</span></xsl:otherwise>
            </xsl:choose>
          </span>
          <span class="cardinality"><xsl:call-template name="cardinality"/></span>
        </div>
        <xsl:call-template name="documentation"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="xs:complexType[@name] | xs:simpleType[@name]" mode="named-type">
    <details class="node" id="type-{@name}">
      <summary>
        <span class="container-name mono"><xsl:value-of select="@name"/></span>
        <xsl:text> </xsl:text>
        <span class="cardinality"><xsl:value-of select="local-name()"/></span>
      </summary>
      <xsl:call-template name="documentation"/>
      <div class="type-block">
        <xsl:variable name="base" select="(xs:restriction/@base | xs:extension/@base | xs:simpleContent/xs:extension/@base | xs:simpleContent/xs:restriction/@base | xs:complexContent/xs:extension/@base | xs:complexContent/xs:restriction/@base)[1]"/>
        <xsl:if test="$base">
          <div class="field">
            <span class="name">value</span>
            <span><span class="keyword">base: </span><code><xsl:value-of select="$base"/></code></span>
            <span/>
          </div>
        </xsl:if>

        <xsl:if test=".//xs:choice/xs:element">
          <div class="section-label">Choice</div>
          <xsl:apply-templates select=".//xs:choice/xs:element" mode="outline"/>
        </xsl:if>

        <xsl:if test=".//xs:sequence/xs:element or .//xs:all/xs:element">
          <div class="section-label">Elements</div>
          <xsl:apply-templates select=".//xs:sequence/xs:element | .//xs:all/xs:element" mode="outline"/>
        </xsl:if>

        <xsl:if test=".//xs:attribute">
          <div class="section-label">Attributes</div>
          <xsl:apply-templates select=".//xs:attribute" mode="attribute"/>
        </xsl:if>

        <xsl:if test=".//xs:enumeration or .//xs:pattern or .//xs:minInclusive or .//xs:maxInclusive or .//xs:minExclusive or .//xs:maxExclusive or .//xs:minLength or .//xs:maxLength or .//xs:length">
          <div class="section-label">Restrictions</div>
          <xsl:apply-templates select=".//xs:enumeration | .//xs:pattern | .//xs:minInclusive | .//xs:maxInclusive | .//xs:minExclusive | .//xs:maxExclusive | .//xs:minLength | .//xs:maxLength | .//xs:length" mode="facet"/>
        </xsl:if>
      </div>
    </details>
  </xsl:template>

  <xsl:template match="xs:attribute" mode="attribute">
    <div class="field">
      <span class="name mono">
        <xsl:choose>
          <xsl:when test="@name"><xsl:value-of select="@name"/></xsl:when>
          <xsl:otherwise><xsl:value-of select="@ref"/></xsl:otherwise>
        </xsl:choose>
      </span>
      <span class="type-name mono"><xsl:value-of select="@type"/></span>
      <span class="cardinality">
        <xsl:choose>
          <xsl:when test="@use"><xsl:value-of select="@use"/></xsl:when>
          <xsl:otherwise>optional</xsl:otherwise>
        </xsl:choose>
      </span>
    </div>
  </xsl:template>

  <xsl:template match="xs:enumeration | xs:pattern | xs:minInclusive | xs:maxInclusive | xs:minExclusive | xs:maxExclusive | xs:minLength | xs:maxLength | xs:length" mode="facet">
    <div class="field">
      <span class="name mono"><xsl:value-of select="local-name()"/></span>
      <code><xsl:value-of select="@value"/></code>
      <span/>
    </div>
  </xsl:template>

  <xsl:template name="element-name">
    <xsl:choose>
      <xsl:when test="@name"><xsl:value-of select="@name"/></xsl:when>
      <xsl:otherwise><xsl:value-of select="@ref"/></xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="cardinality">
    <xsl:variable name="min">
      <xsl:choose><xsl:when test="@minOccurs"><xsl:value-of select="@minOccurs"/></xsl:when><xsl:otherwise>1</xsl:otherwise></xsl:choose>
    </xsl:variable>
    <xsl:variable name="max">
      <xsl:choose><xsl:when test="@maxOccurs='unbounded'">*</xsl:when><xsl:when test="@maxOccurs"><xsl:value-of select="@maxOccurs"/></xsl:when><xsl:otherwise>1</xsl:otherwise></xsl:choose>
    </xsl:variable>
    <xsl:value-of select="$min"/><xsl:text>..</xsl:text><xsl:value-of select="$max"/>
  </xsl:template>

  <xsl:template name="type-link">
    <xsl:param name="qname"/>
    <xsl:variable name="local">
      <xsl:choose>
        <xsl:when test="contains($qname, ':')"><xsl:value-of select="substring-after($qname, ':')"/></xsl:when>
        <xsl:otherwise><xsl:value-of select="$qname"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="key('type-by-name', $local)">
        <a href="#type-{$local}"><xsl:value-of select="$qname"/></a>
      </xsl:when>
      <xsl:otherwise><xsl:value-of select="$qname"/></xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="documentation">
    <xsl:if test="xs:annotation/xs:documentation">
      <div class="annotation">
        <xsl:for-each select="xs:annotation/xs:documentation">
          <xsl:value-of select="normalize-space(.)"/>
          <xsl:if test="position() != last()"><br/></xsl:if>
        </xsl:for-each>
      </div>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
