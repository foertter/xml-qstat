<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE stylesheet [
<!ENTITY  newline "<xsl:text>&#x0a;</xsl:text>">
<!ENTITY  space   "<xsl:text> </xsl:text>">
<!ENTITY  nbsp    "&#xa0;">
]>
<xsl:stylesheet version="1.0"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
>
<!--
   | process XML generated by
   |     "qhost -xml -j -q"
   | to produce
   |   1) detailed list of the queue instances (the default)
   |   2) queue summary (renderMode = summary)
   |   3) list of queues with slots free (renderMode = free)
   |   4) list of queues with warnings (renderMode = warn)
   |
   | expected input:
   | aggregated input from
   |  - qhost.xml
   |
   | uses external files:
   |  - config/config.xml
   -->

<!-- ======================= Imports / Includes =========================== -->
<!-- Include our masthead and templates -->
<xsl:include href="xmlqstat-masthead.xsl"/>
<xsl:include href="xmlqstat-templates.xsl"/>
<!-- Include processor-instruction parsing -->
<xsl:include href="pi-param.xsl"/>


<!-- ======================== Passed Parameters =========================== -->
<xsl:param name="clusterName">
  <xsl:call-template name="pi-param">
    <xsl:with-param  name="name"    select="'clusterName'"/>
  </xsl:call-template>
</xsl:param>
<xsl:param name="timestamp">
  <xsl:call-template name="pi-param">
    <xsl:with-param  name="name"    select="'timestamp'"/>
  </xsl:call-template>
</xsl:param>
<xsl:param name="renderMode">
  <xsl:call-template name="pi-param">
    <xsl:with-param  name="name"    select="'renderMode'"/>
  </xsl:call-template>
</xsl:param>
<xsl:param name="urlExt">
  <xsl:call-template name="pi-param">
    <xsl:with-param  name="name"    select="'urlExt'"/>
  </xsl:call-template>
</xsl:param>


<!-- ======================= Internal Parameters ========================== -->
<!-- configuration parameters -->
<xsl:variable
    name="configFile"
    select="document('../config/config.xml')/config" />
<xsl:variable
    name="clusterNode"
    select="$configFile/clusters/cluster[@name=$clusterName]" />

<!-- the date according to the processing-instruction -->
<xsl:variable name="piDate">
  <xsl:call-template name="pi-named-param">
    <xsl:with-param  name="pis"  select="processing-instruction('qhost')" />
    <xsl:with-param  name="name" select="'date'"/>
  </xsl:call-template>
</xsl:variable>


<!-- ========================== Sorting Keys ============================== -->
<xsl:key
    name="queue-summary"
    match="//host/queue"
    use="@name"
/>
<xsl:key
    name="job-summary"
    match="//host/job"
    use="@name"
/>


<!-- ======================= Output Declaration =========================== -->
<xsl:output method="xml" indent="yes" version="1.0" encoding="UTF-8"
    doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN"
    doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"
/>


<!-- ============================ Matching ================================ -->
<xsl:template match="/" >
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<meta http-equiv="Refresh" content="30" />
&newline;

<xsl:choose>
<xsl:when test="$renderMode='summary'">
  <link rel="icon" type="image/png" href="css/screen/icons/sum.png"/>
  <title> queue summary
  <xsl:if test="$clusterName"> @<xsl:value-of select="$clusterName"/></xsl:if>
  </title>
</xsl:when>
<xsl:when test="$renderMode='free'">
  <link rel="icon" type="image/png" href="css/screen/icons/tick.png"/>
  <title> queues free
  <xsl:if test="$clusterName"> @<xsl:value-of select="$clusterName"/></xsl:if>
  </title>
</xsl:when>
<xsl:when test="$renderMode='warn'">
  <link rel="icon" type="image/png" href="css/screen/icons/error.png"/>
  <title> queue warnings
  <xsl:if test="$clusterName"> @<xsl:value-of select="$clusterName"/></xsl:if>
  </title>
</xsl:when>
<xsl:otherwise>
  <link rel="icon" type="image/png" href="css/screen/icons/shape_align_left.png"/>
  <title> queue instances
  <xsl:if test="$clusterName"> @<xsl:value-of select="$clusterName"/></xsl:if>
  </title>
</xsl:otherwise>
</xsl:choose>

&newline;
<!-- load css -->
<link href="css/xmlqstat.css" media="screen" rel="Stylesheet" type="text/css" />
&newline;
</head>

<!-- PRE-CALCULATE values -->

<!-- count active number of slots -->
<xsl:variable name="AJ_slots" select="sum(//queuevalue[@name='slots_used'])"/>

<!-- done PRE-CALCULATE -->

<!-- begin body -->
<body>
&newline;
<xsl:comment> Main body content </xsl:comment>
&newline;

<div id="main">
<!-- Topomost Logo Div -->
<xsl:call-template name="topLogo"/>
&newline;
<!-- Top Menu Bar -->
<xsl:call-template name="topMenu">
  <xsl:with-param name="urlExt" select="$urlExt"/>
</xsl:call-template>
&newline;

<xsl:comment> Top dotted line bar (holds the cluster/qmaster names and update time) </xsl:comment>
<div class="dividerBarBelow">
<xsl:choose>
<xsl:when test="$clusterNode">
  <!-- cluster/cell name -->
  <xsl:value-of select="$clusterNode/@name"/>
  <xsl:if test="$clusterNode/@cell != 'default'">/<xsl:value-of
      select="$clusterNode/@cell"/>
  </xsl:if>
</xsl:when>
<xsl:otherwise>
  <!-- unnamed cluster: -->
  unnamed cluster
</xsl:otherwise>
</xsl:choose>
<!-- replace 'T' in dateTime for easier reading -->
&space; <xsl:value-of select="translate($piDate, 'T', '_')"/>
<br/>
<xsl:choose>
<xsl:when test="$AJ_slots &gt; 0">
  <!-- active jobs: -->
  <xsl:value-of select="$AJ_slots"/> slots used
</xsl:when>
<xsl:otherwise>
  <!-- no active jobs -->
  no active jobs
</xsl:otherwise>
</xsl:choose>
</div>

&newline;
<xsl:comment> Host or Queue Instance Information </xsl:comment>
&newline;

<blockquote>
<xsl:choose>
<xsl:when test="$renderMode='summary'">
  <!-- summary: -->
  <table class="listing">
    <tr valign="middle">
      <td>
        <div class="tableCaption">Queue Summary</div>
      </td>
    </tr>
  </table>
  <xsl:apply-templates select="//qhost" mode="summary"/>
</xsl:when>
<xsl:when test="$renderMode='free'">
  <!-- free: -->
  <table class="listing">
    <tr valign="middle">
      <td>
        <div class="tableCaption">Queues Free</div>
      </td>
    </tr>
  </table>
  <xsl:apply-templates select="//qhost"/>
</xsl:when>
<xsl:when test="$renderMode='warn'">
  <!-- warnings: -->
  <table class="listing">
    <tr valign="middle">
      <td>
        <div class="tableCaption">Queue Warnings</div>
      </td>
    </tr>
  </table>
  <xsl:apply-templates select="//qhost"/>
</xsl:when>
<xsl:otherwise>
  <!-- queue/host information: -->
  <table class="listing">
    <tr valign="middle">
      <td>
        <div class="tableCaption">Queue Information</div>
      </td>
    </tr>
  </table>
  <xsl:apply-templates select="//qhost"/>
</xsl:otherwise>
</xsl:choose>
</blockquote>

<!-- bottom status bar with rendered time -->
<xsl:call-template name="bottomStatusBar">
  <xsl:with-param name="timestamp" select="$timestamp" />
</xsl:call-template>

&newline;
</div>
</body></html>
<!-- end body/html -->
</xsl:template>


<!--
  cluster summary: header and content
-->
<xsl:template match="//qhost" mode="summary">
<!-- summary: header -->
<table class="listing">
  <tr>
  <th/>
  <th>total</th>
  <th>used</th>
  <th>
    <acronym title="a(larm) C(alendar) S(ubordinate)">warnings</acronym>
  </th>
  <th>
    <acronym title="d(isabled) s(uspended) u(nknown) E(rror)">errors</acronym>
  </th>
  <th>free</th>
  </tr>

  <!-- summary: content -->
  <xsl:for-each select="host/queue">
    <xsl:sort select="@name"/>

    <xsl:variable name="qname" select="@name"/>
    <xsl:variable name="thisNode" select="generate-id(.)"/>
    <xsl:variable name="allNodes" select="key('queue-summary', $qname)"/>
    <xsl:variable name="firstNode" select="generate-id($allNodes[1])"/>

    <xsl:if test="$thisNode = $firstNode">
      <xsl:variable
          name="slotsUsed"
          select="sum($allNodes/queuevalue[@name='slots_used'])"
      />

      <xsl:variable
          name="slotsTotal"
          select="sum($allNodes/queuevalue[@name='slots'])"
      />

      <xsl:variable
          name="slotsDisabled"
          select="sum($allNodes/queuevalue[@name='slots_used'])"
      />

      <!-- select all queue instances with an unusual state -->
      <xsl:variable
          name="stateNodes"
          select="$allNodes/queuevalue[@name='state_string'][. != '']"
      />

  <!-- possible queue states:
       u(nknown), a(larm), A(larm), C(alendar suspended), s(uspended),
       S(ubordinate), d(isabled), D(isabled), E(rror)
  -->

      <!-- select unknown separately -->
      <xsl:variable
          name="nodeSet_unknown"
          select="$stateNodes[contains(., 'u')]"
      />

      <xsl:variable
          name="nodeSet_known"
          select="$stateNodes[not(contains(., 'u'))]"
      />

      <!-- discount these queue instances -->
      <xsl:variable
          name="slotsProblem"
          select="sum($stateNodes/../queuevalue[@name='slots']) -
                  sum($stateNodes/../queuevalue[@name='slots_used'])"
      />

      <!-- group cdsuE -->
      <xsl:variable name="group_cdsuE">
        <xsl:variable
            name="subset"
            select="$stateNodes[
                contains(., 'c')
             or contains(., 'd')
             or contains(., 's')
             or contains(., 'u')
             or contains(., 'E')
             ]"
        />
        <xsl:value-of
          select="sum($subset/../queuevalue[@name='slots']) -
                  sum($subset/../queuevalue[@name='slots_used'])"
        />
      </xsl:variable>

      <!-- determine group aoACDS implicitly -->
      <xsl:variable
          name="group_aoACDS"
          select="$slotsProblem - $group_cdsuE"
      />

      <xsl:variable
          name="slotsAvailable"
          select="$slotsTotal - $slotsProblem"
      />


      <tr align="right">
        <!-- queue name -->
        <td align="left"><xsl:value-of select="@name"/></td>

        <!-- total: display as alarm if none found -->
        <xsl:choose>
        <xsl:when test="$slotsTotal">
          <td>
            <xsl:value-of select="$slotsTotal" />
          </td>
        </xsl:when>
        <xsl:otherwise>
          <!-- alarm color -->
          <td class="alarmState">0</td>
        </xsl:otherwise>
        </xsl:choose>

        <!-- used slots -->
        <td width="100px" align="left">
          <xsl:call-template name="progressBarAbs">
            <xsl:with-param name="title" select="total = $slotsAvailable" />
            <xsl:with-param name="value" select="$slotsUsed" />
            <xsl:with-param name="total" select="$slotsAvailable" />
          </xsl:call-template>
        </td>

        <!-- aoACDS errors (warnings) -->
        <td width="100px" align="left">
          <xsl:call-template name="progressBarAbs">
            <xsl:with-param name="class" select="'warnBar'" />
            <xsl:with-param name="label" select="$group_aoACDS" />
            <xsl:with-param name="value" select="$group_aoACDS" />
            <xsl:with-param name="total" select="$slotsTotal" />
          </xsl:call-template>
        </td>

        <!-- cdsuE errors -->
        <td width="100px" align="left">
          <xsl:call-template name="progressBarAbs">
            <xsl:with-param name="class" select="'alarmBar'" />
            <xsl:with-param name="label" select="$group_cdsuE" />
            <xsl:with-param name="value" select="$group_cdsuE" />
            <xsl:with-param name="total" select="$slotsTotal" />
          </xsl:call-template>
        </td>

        <!-- free: display warn/alarm when exhausted -->
        <xsl:choose>
        <xsl:when test="$slotsAvailable &gt; $slotsUsed">
          <td><xsl:value-of select="$slotsAvailable - $slotsUsed"/></td>
        </xsl:when>
        <xsl:otherwise>
          <!-- warn color -->
          <td class="warnState">0</td>
        </xsl:otherwise>
        </xsl:choose>

      </tr>
&newline;
    </xsl:if>
  </xsl:for-each>

</table>
</xsl:template>


<!--
  queue/host information: header
-->
<xsl:template match="//qhost">
<div id="hostInfoTable">
  <table class="listing">
  <thead>
  <tr>
    <th/>
    <th><acronym title="non-normalized cpu load">load</acronym></th>
    <th>
      queue
      <acronym title="B(atch), I(nteractive), P(arallel)">information</acronym>
    </th>
    <th>cpu</th>
    <th>jobs</th>
    <th>mem</th>
    <th>swap</th>
  </tr>
  </thead>
  <xsl:apply-templates select="host[@name != 'global']"/>
  </table>
</div>
</xsl:template>


<!--
  queue/host information: content
-->
<xsl:template match="qhost/host">

  <xsl:variable name="render">
    <xsl:choose>
    <xsl:when test="$renderMode='free'">
      <xsl:for-each select="queue">
        <xsl:if
            test="queuevalue[@name='state_string'] = '' and
            (queuevalue[@name='slots'] - queuevalue[@name='slots_used']) != 0">
          true
        </xsl:if>
      </xsl:for-each>
    </xsl:when>
    <xsl:when test="$renderMode='warn'">
      <xsl:if test="queue/queuevalue[@name='state_string'][
          contains(., 'a') or contains(., 'd') or contains(., 'E')]">
        true
      </xsl:if>
    </xsl:when>
    <xsl:otherwise>
      true
    </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

<xsl:if test="contains($render, 'true')">

  <tr align="right">
  <!-- overall background color based on queue(s) status -->
  <!--
  <xsl:apply-templates select="queue/queuevalue[@name='state_string']" />
  -->

  <!-- no queues configured -->
  <xsl:if test="count(queue) = 0" >
    <xsl:attribute name="style">
      font-style: italic;
    </xsl:attribute>
  </xsl:if>

  <!-- host -->
  <td align="left">
    <xsl:value-of select="substring-before(@name,'.')"/>
  </td>

  <!-- load (w/o dash for missing values) -->
  <td>
    <xsl:value-of select="translate(hostvalue[@name='load_avg'], '-', ' ')"/>
  </td>

  <!-- queue instance information -->
  <xsl:choose>
  <xsl:when test="count(queue)">
    <td>
      <table class="embedded">
      <xsl:for-each select="queue">
        <xsl:apply-templates select="." />
      </xsl:for-each>
      </table>
    </td>
  </xsl:when>
  <xsl:otherwise>
    <td/>
  </xsl:otherwise>
  </xsl:choose>

  <!-- ncpu (w/o dash for missing values) with arch -->
  <td>
    <xsl:element name="acronym">
      <xsl:attribute name="title">arch = <xsl:value-of select="hostvalue[@name='arch_string']"/></xsl:attribute>
      <xsl:value-of select="translate(hostvalue[@name='num_proc'], '-', ' ')"/>
    </xsl:element>
  </td>

  <!-- jobs -->
  <td>
    <xsl:for-each select="job">
      <xsl:choose>
      <xsl:when test="jobvalue[@name='pe_master'] = 'SLAVE'">
        slave
      </xsl:when>
      <xsl:otherwise>
        master
      </xsl:otherwise>
      </xsl:choose>
      <xsl:element name="a">
        <xsl:attribute name="title">details for job <xsl:value-of select="@name"/></xsl:attribute>
        <xsl:attribute name="href">
          <xsl:text>jobinfo</xsl:text>
          <xsl:value-of select="$urlExt"/>?<xsl:value-of select="@name"/>
        </xsl:attribute>
        <xsl:value-of select="@name"/>
      </xsl:element>
      <br/>
    </xsl:for-each>
  </td>

  <!-- mem -->
  <td width="100px" align="left">
    <xsl:call-template name="memoryUsed">
      <xsl:with-param name="used"  select="hostvalue[@name='mem_used']" />
      <xsl:with-param name="total" select="hostvalue[@name='mem_total']" />
    </xsl:call-template>
  </td>

  <!-- swap -->
  <td width="100px" align="left">
    <xsl:call-template name="memoryUsed">
      <xsl:with-param name="used"  select="hostvalue[@name='swap_used']"/>
      <xsl:with-param name="total" select="hostvalue[@name='swap_total']"/>
    </xsl:call-template>
  </td>

  </tr>
&newline;
</xsl:if>
</xsl:template>


<!--
  process host queue information
-->
<xsl:template match="host/queue">
  <xsl:variable name="used"   select="queuevalue[@name='slots_used']"/>
  <xsl:variable name="total"  select="queuevalue[@name='slots']"/>
  <xsl:variable name="state"  select="queuevalue[@name='state_string']"/>

  <tr>
    <!-- 'S' suspend state : alter font-style -->
    <xsl:if test="contains($state, 'S')">
      <xsl:attribute name="style">font-style: italic;</xsl:attribute>
    </xsl:if>

    <!-- font style, background color based on queue(s) status -->
    <xsl:call-template name="queue-state-style">
      <xsl:with-param name="state" select="$state"/>
    </xsl:call-template>

    <!-- state icon and queue name -->
    <td align="left">
      <xsl:call-template name="queue-state-icon">
        <xsl:with-param name="state" select="$state"/>
      </xsl:call-template>
      <xsl:value-of select="@name"/>
    </td>

    <!-- queue type B(atch), I(nteractive), P(arallel) -->
    <td align="right">
      <xsl:value-of select="queuevalue[@name='qtype_string']"/>
    </td>

    <!-- slider showing slot usage -->
    <td width="100px" align="left">
      <xsl:if test="$used &gt; -1">
        <xsl:call-template name="progressBarAbs">
          <xsl:with-param name="value" select="$used" />
          <xsl:with-param name="total" select="$total" />
        </xsl:call-template>
      </xsl:if>
    </td>
  </tr>
</xsl:template>


</xsl:stylesheet>

<!-- =========================== End of File ============================== -->
