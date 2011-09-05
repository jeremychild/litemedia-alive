<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:a="http://schemas.datacontract.org/2004/07/"
  xmlns="http://www.w3.org/1999/xhtml">

  <xsl:output method="html" omit-xml-declaration="yes" cdata-section-elements="script"/>
  <xsl:template match="/">
    <html>
      <head>
        <link href="?file=main.css" rel="stylesheet" type="text/css" />
      </head>
      <body>
        <article>
          <header>
            <h1>
              <a href="http://litemedia.info">lite<span class="acute">media</span>
              </a>
              Alive
            </h1>
          </header>
          <ul class="charts">
            <xsl:call-template name="charts" />
          </ul>
        </article>
        <footer>
          <p>
            Alive was created by <a href="http://litemedia.info/about">Mikael Lundin @ litemedia</a> and is free for use and <a href="https://code.google.com/p/litemedia-alive/">open source</a>.
            If you want to contribute to this project you can <a href="http://fundedbyme.com/">donate money</a> or source code.
          </p>
        </footer>
      </body>

      <script>
        <xsl:call-template name="configuration" />

        var settings = {
          base_color: '#606060',
          graph_colors: ['#006666', '#339999', '#00CC99', '#66CCCC', '#00FFCC', '#33FFCC', '#66FFCC', '#99FFCC', '#CCFFFF']
        };
      </script>
      <script src="?file=chart.js"></script>
      <script src="?file=main.js"></script>
      <script>
      <![CDATA[
        // initialize
        initialize();
      ]]>
      </script>
    </html>
  </xsl:template>

  <xsl:template name="configuration">
    charts = {
      <xsl:apply-templates select="//a:Model.Group" mode="json"/>
    }
  </xsl:template>
  <xsl:template name="charts">
    <xsl:apply-templates select="//a:Model.Group" mode="li" />
  </xsl:template>
  <xsl:template match="a:Model.Group" mode="json"><xsl:if test="not(position()=1)"><xsl:text>,</xsl:text></xsl:if>'<xsl:value-of select="a:Name"/>': { 'latency': <xsl:value-of select="a:UpdateLatency"/> }</xsl:template>
  <xsl:template match="a:Model.Group" mode="li">
    <li>
      <canvas width="440" height="220" class="chart">
        <xsl:attribute name="id">
          <xsl:value-of select="a:Name"/>
        </xsl:attribute>
        You need a browser that support the &lt;canvas&gt; element.
      </canvas>
    </li>
  </xsl:template>
  <!--<xsl:template match="@* | node()">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()"/>
    </xsl:copy>
  </xsl:template>-->
</xsl:stylesheet>