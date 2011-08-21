<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:a="http://schemas.datacontract.org/2004/07/"
  xmlns="http://www.w3.org/1999/xhtml">

  <xsl:output method="html" omit-xml-declaration="yes" cdata-section-elements="script"/>
  <xsl:template match="/">
    <html>
      <head>
        <link href="?file=main.css" rel="stylesheet" type="text/css" />
        <script>
          <xsl:call-template name="configuration" />
        </script>
        <script src="?file=main.js"></script>
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
            Alive was created by <a href="">Mikael Lundin @ litemedia</a> and is free for use and <a href="">open source</a>.
            <!--If you want to contribute to this project you can <a href="http://fundedbyme.com/">donate money</a> or source code.-->
          </p>
        </footer>
      </body>
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
    <li class="chart">
      <img id="{name}" src="http://placekitten.com/g/440/220">
        <xsl:attribute name="id">
          <xsl:value-of select="a:Name"/>
        </xsl:attribute>
      </img>
    </li>
  </xsl:template>
  <!--<xsl:template match="@* | node()">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()"/>
    </xsl:copy>
  </xsl:template>-->
  <!--<ArrayOfModel.Group xmlns="http://schemas.datacontract.org/2004/07/" xmlns:i="http://www.w3.org/2001/XMLSchema-instance">
    <Model.Group>
      <Counters>
        <Model.Counter>
          <CategoryName>Processor Information</CategoryName>
          <CounterName>% Processor Time</CounterName>
          <CurrentValue>0</CurrentValue>
          <InstanceName xmlns:a="http://schemas.datacontract.org/2004/07/Microsoft.FSharp.Core">
            <a:value>_Total</a:value>
          </InstanceName>
          <Name>CPU</Name>
        </Model.Counter>
        <Model.Counter>
          <CategoryName>Processor Information</CategoryName>
          <CounterName>% Processor Time</CounterName>
          <CurrentValue>0</CurrentValue>
          <InstanceName xmlns:a="http://schemas.datacontract.org/2004/07/Microsoft.FSharp.Core">
            <a:value>0,1</a:value>
          </InstanceName>
          <Name>CPU#1</Name>
        </Model.Counter>
        <Model.Counter>
          <CategoryName>Processor Information</CategoryName>
          <CounterName>% Processor Time</CounterName>
          <CurrentValue>0</CurrentValue>
          <InstanceName xmlns:a="http://schemas.datacontract.org/2004/07/Microsoft.FSharp.Core">
            <a:value>0,1</a:value>
          </InstanceName>
          <Name>CPU#2</Name>
        </Model.Counter>
      </Counters>
      <Name>Hardware</Name>
    </Model.Group>
    <Model.Group>
      <Counters>
        <Model.Counter>
          <CategoryName>Paging File</CategoryName>
          <CounterName>% Usage</CounterName>
          <CurrentValue>0</CurrentValue>
          <InstanceName xmlns:a="http://schemas.datacontract.org/2004/07/Microsoft.FSharp.Core">
            <a:value>_Total</a:value>
          </InstanceName>
          <Name>Paging File % Usage</Name>
        </Model.Counter>
      </Counters>
      <Name>Swap</Name>
    </Model.Group>
  </ArrayOfModel.Group>-->
</xsl:stylesheet>