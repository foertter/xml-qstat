<xsl:stylesheet version="1.0"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:date="http://exslt.org/dates-and-times"
    xmlns:datetime="http://exslt.org/dates-and-times"
    extension-element-prefixes="date"
>
<!--
   | process XML generated by
   |     "qstat -xml -j job_identifier_list"
   | to produce a list of active and pending jobs
   | with their details
   | The menuMode only affects the top menu
-->


<!-- output declarations -->
<xsl:output method="xhtml" indent="yes" version="4.01" encoding="ISO-8859-1"
    doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN"
    doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"
/>

<!-- Import the XSLTL library methods -->
<xsl:include href="exslt-templates/date.add-duration.function.xsl"/>
<xsl:include href="exslt-templates/date.add.template.xsl"/>
<xsl:include href="exslt-templates/date.duration.template.xsl"/>

<!-- Import our uniform masthead -->
<xsl:include href="xmlqstat-masthead.xsl"/>

<!-- Import our templates -->
<xsl:include href="xmlqstat-templates.xsl"/>

<!-- XSL Parameters   -->
<xsl:param name="clusterName"/>
<xsl:param name="timestamp"/>
<xsl:param name="menuMode"/>

<!-- get specific configuration parameters -->
<xsl:param name="viewfileProgram" select="//config/programs/viewfile" />
<xsl:param name="viewlogProgram" select="//config/programs/viewlog" />

<!-- possibly append ~{clusterName} to urls -->
<xsl:param name="clusterSuffix">
  <xsl:if test="$clusterName">~<xsl:value-of select="$clusterName"/></xsl:if>
</xsl:param>


<xsl:param name="cgiParams">
  <xsl:if
    test="//config/cluster">&amp;SGE_ROOT=<xsl:value-of
    select="//config/cluster/@root"/><xsl:if
    test="//config/cluster/@cell != 'default'"
    >&amp;SGE_CELL=<xsl:value-of
    select="//config/cluster/@cell"/></xsl:if>
  </xsl:if>
</xsl:param>


<!-- Read in our bitmask translation XML config file -->
<xsl:variable name="codeFile" select="document('../config/status-codes.xml')" />


<xsl:template match="/">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<link rel="icon" type="image/png" href="images/icons/silk/lorry.png"/>
<title> job details
  <xsl:if test="//config/cluster/@name">
  - <xsl:value-of select="//config/cluster/@name"/>
  </xsl:if>
</title>
<xsl:text>
</xsl:text>

<xsl:comment> Load CSS from a file </xsl:comment>
<xsl:text>
</xsl:text>
<link href="css/xmlqstat.css"  media="screen" rel="Stylesheet" type="text/css" />
<xsl:text>
</xsl:text>
</head>
<body>
<xsl:text>
</xsl:text>

<xsl:comment> Main body content </xsl:comment>
<xsl:text>
</xsl:text>

<div id="main">
<!-- Topomost Logo Div and Top Menu Bar -->
<xsl:choose>
<xsl:when test="$menuMode='xmlqstat'">
  <xsl:call-template name="xmlqstatLogo"/>
  <xsl:call-template name="xmlqstatMenu">
    <xsl:with-param name="clusterSuffix" select="$clusterSuffix"/>
    <xsl:with-param name="jobinfo" select="'less'"/>
  </xsl:call-template>
</xsl:when>
<xsl:otherwise>
  <xsl:call-template name="topLogo"/>
  <xsl:call-template name="topMenu">
    <xsl:with-param name="jobinfo" select="'less'"/>
  </xsl:call-template>
</xsl:otherwise>
</xsl:choose>

<!-- Top dotted line bar (holds the cluster name) -->
<xsl:choose>
<xsl:when test="//config/cluster">
  <div class="dividerBarBelow">
    <!-- cluster/cell name -->
    <xsl:value-of select="//config/cluster/@name"/>
    <xsl:if test="//config/cluster/@cell != 'default'">/<xsl:value-of
        select="//config/cluster/@cell"/>
    </xsl:if>
  </div>
</xsl:when>
<xsl:when test="//query/host">
  <div class="dividerBarBelow">
    [<xsl:value-of select="//query/host"/>]
    <!-- remove 'T' in dateTime for easier reading -->
    <xsl:value-of select="translate(//query/time, 'T', ' ')"/>
  </div>
</xsl:when>
</xsl:choose>

<xsl:text>
</xsl:text>
<xsl:comment> Overview table </xsl:comment>
<xsl:text>
</xsl:text>

<!--
  overview table
-->
<blockquote>
<table class="listing">
  <tr>
    <td>
      <div class="tableCaption">Overview</div>
    </td>
  </tr>
</table>
<xsl:text>
</xsl:text>
<div id="queueStatusTable">
<table class="listing">
  <tr>
    <th>jobId</th>
    <th>owner</th>
    <th>name</th>
    <th>submitted</th>
    <th>execFile</th>
    <th>group</th>
    <th>state</th>
  </tr>
<xsl:text>
</xsl:text>
  <!-- 6.1: //detailed_job_info/djob_info/qmaster_response -->
  <!-- running jobs first -->
  <xsl:apply-templates
      select="
        //detailed_job_info/djob_info/element[JB_ja_tasks]
      | //detailed_job_info/djob_info/qmaster_response[JB_ja_tasks]
      "
      mode="overview"
  />
  <!-- pending jobs next -->
  <xsl:apply-templates
      select="
        //detailed_job_info/djob_info/element[not(JB_ja_tasks)]
      | //detailed_job_info/djob_info/qmaster_response[not(JB_ja_tasks)]
      "
      mode="overview"
  />
</table>
</div>
</blockquote>
<xsl:text>
</xsl:text>

<!--
  context table
-->
<blockquote>
<table class="listing">
  <tr>
  <td>
    <div class="tableCaption">Context</div>
  </td>
  </tr>
</table>
<div>
<table class="listing">
  <th>jobId</th>
  <th>context</th>
  <th>cwd</th>
  <!-- 6.1: //detailed_job_info/djob_info/qmaster_response -->
  <!-- running jobs first -->
  <xsl:apply-templates
      select="
        //detailed_job_info/djob_info/element[JB_ja_tasks]
      | //detailed_job_info/djob_info/qmaster_response[JB_ja_tasks]
      "
      mode="context"
  />
  <!-- pending jobs next -->
  <xsl:apply-templates
      select="
        //detailed_job_info/djob_info/element[not(JB_ja_tasks)]
      | //detailed_job_info/djob_info/qmaster_response[not(JB_ja_tasks)]
      "
      mode="context"
  />
</table>
</div>
</blockquote>

<!-- 6.1: //detailed_job_info/djob_info/qmaster_response -->
<!--
  detailed_job_info
  running jobs
-->
<xsl:apply-templates
    select="
      //detailed_job_info/djob_info/element[JB_ja_tasks]
    | //detailed_job_info/djob_info/qmaster_response[JB_ja_tasks]
    "
/>
<!--
  detailed_job_info
  pending jobs
-->
<xsl:apply-templates
    select="
      //detailed_job_info/djob_info/element[not(JB_ja_tasks)]
    | //detailed_job_info/djob_info/qmaster_response[not(JB_ja_tasks)]
    "
/>

<!--
  scheduling info
-->
<blockquote>
<table class="listing">
  <tr>
    <td>
      <div class="tableCaption">
      <!-- 6.1: //detailed_job_info/messages/qmaster_response -->
        <xsl:value-of
            select="
              count(//detailed_job_info/messages/element/SME_global_message_list/element/MES_message)
            + count(//detailed_job_info/messages/qmaster_response/SME_global_message_list/element/MES_message)
            "
        />
        Scheduling Messages
      </div>
    </td>
  </tr>
</table>
<table class="listing">
  <tr>
    <td>
      <!-- 6.1: //detailed_job_info/messages/qmaster_response -->
      <xsl:apply-templates
          select="
            //detailed_job_info/messages/element/SME_global_message_list
          | //detailed_job_info/messages/qmaster_response/SME_global_message_list
          "
      />
    </td>
  </tr>
</table>
<xsl:text>
</xsl:text>

<!-- DISABLE FOR NOW

<table class="listing">
<tr>
  <th>share</th>
  <th>fshare</th>
  <th>oticket</th>
  <th>fticket</th>
  <th>sticket</th>
  <th>priority</th>
  <th>ntix</th>
</tr>
  <tr id="priorityJobRow" class="jobDetailRow">
    <td><xsl:value-of select="//JB_ja_template/ulong_sublist/JAT_share"/></td>
    <td><xsl:value-of select="//JB_ja_template/ulong_sublist/JAT_fshare"/></td>
    <td><xsl:value-of select="//JB_ja_template/ulong_sublist/JAT_oticket"/></td>
    <td><xsl:value-of select="//JB_ja_template/ulong_sublist/JAT_fticket"/></td>
    <td><xsl:value-of select="//JB_ja_template/ulong_sublist/JAT_sticket"/></td>
    <td><xsl:value-of select="//JB_ja_template/ulong_sublist/JAT_prio"/></td>
    <td><xsl:value-of select="//JB_ja_template/ulong_sublist/JAT_ntix"/></td>
  </tr>
</table>

-->
</blockquote>

<!-- bottom status bar with rendered time -->
<xsl:call-template name="bottomStatusBar">
  <xsl:with-param name="timestamp" select="$timestamp" />
</xsl:call-template>

<xsl:text>
</xsl:text>
</div>
</body></html>
</xsl:template>

<!--
   overview table: contents
   6.1: //djob_info/qmaster_response
-->
<xsl:template
    match="//djob_info/element | //djob_info/qmaster_response"
    mode="overview"
>
  <xsl:variable name="jobs-href">
    <xsl:choose>
    <xsl:when test="$menuMode='xmlqstat'">
      jobs<xsl:value-of select="$clusterSuffix"/>?<xsl:value-of select="JB_owner"/>
    </xsl:when>
    <xsl:otherwise>jobs?user=<xsl:value-of select="JB_owner"/></xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <tr>
    <!-- jobId with link to details listing -->
    <td>
      <xsl:element name="a">
        <xsl:attribute name="title">details <xsl:value-of select="JB_job_number"/></xsl:attribute>
        <xsl:attribute name="href">#details<xsl:value-of select="JB_job_number"/></xsl:attribute>
        <xsl:value-of select="JB_job_number" />
      </xsl:element>
    </td>

    <!-- owner/uid : link owner names to "jobs?user={owner}" -->
    <td>
     <xsl:element name="a">
       <xsl:attribute name="title">uid <xsl:value-of select="JB_uid"/></xsl:attribute>
       <xsl:attribute name="href"><xsl:value-of select="$jobs-href"/></xsl:attribute>
       <xsl:value-of select="JB_owner" />
     </xsl:element>
    </td>

    <!-- job name -->
    <td><xsl:value-of select="JB_job_name" /></td>

    <!-- submitted: convert epoch to dateTime -->
    <td>
      <xsl:apply-templates select="JB_submission_time" />
    </td>

    <!-- Exec file / script -->
    <td>
      <xsl:element name="acronym">
        <xsl:attribute name="title">script=<xsl:value-of select="JB_script_file" /></xsl:attribute>
        <xsl:value-of select="JB_exec_file" />
      </xsl:element>
    </td>

    <!-- POSIX: group / gid -->
    <td>
      <xsl:element name="acronym">
        <xsl:attribute name="title">gid <xsl:value-of select="JB_gid"/></xsl:attribute>
        <xsl:value-of select="JB_group" />
      </xsl:element>
    </td>

    <!-- state: different state XPath for active and pending/held jobs -->
    <td>
      <xsl:choose>
      <xsl:when test="JB_ja_tasks">
        <xsl:call-template name="stateTranslation">
          <xsl:with-param name="state" select="JB_ja_tasks/ulong_sublist/JAT_status" />
        </xsl:call-template>
        <xsl:if test="$viewlogProgram">
          <xsl:apply-templates select="JB_hard_resource_list" mode="viewlog"/>
        </xsl:if>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="stateTranslation">
          <xsl:with-param name="state" select="JB_ja_template/ulong_sublist/JAT_state" />
        </xsl:call-template>
      </xsl:otherwise>
      </xsl:choose>
    </td>
  </tr>
<xsl:text>
</xsl:text>
</xsl:template>


<!--
  context table: contents
  6.1: //djob_info/qmaster_response
-->
<xsl:template
    match="//djob_info/element | //djob_info/qmaster_response"
    mode="context"
>
<tr>
  <td>
    <xsl:element name="a">
      <xsl:attribute name="title">details <xsl:value-of select="JB_job_number"/></xsl:attribute>
      <xsl:attribute name="href">#details<xsl:value-of select="JB_job_number"/></xsl:attribute>
      <xsl:value-of select="JB_job_number" />
    </xsl:element>
  </td>
  <td><xsl:apply-templates select="JB_context/context_list"/></td>
  <td><xsl:value-of select="JB_cwd"/></td>
</tr>
<xsl:text>
</xsl:text>
</xsl:template>


<!--
  details table
  6.1: //djob_info/qmaster_response
-->
<xsl:template match="//djob_info/element | //djob_info/qmaster_response">
<xsl:variable name="jobId" select="JB_job_number"/>

<blockquote>
<xsl:element name="table">
  <xsl:attribute name="class">listing</xsl:attribute>
  <xsl:attribute name="id">details<xsl:value-of select="$jobId"/></xsl:attribute>
  <tr>
    <td>
      <div class="tableCaption">Details for job
        <strong><xsl:value-of select="$jobId"/></strong>
        <xsl:if test="JB_ja_tasks/ulong_sublist/JAT_master_queue">
          master queue
          <strong><xsl:apply-templates
              select="JB_ja_tasks/ulong_sublist/JAT_master_queue"
          /></strong>
        </xsl:if>
      </div>
    </td>
  </tr>
</xsl:element>
<table class="listing fixedTH">
  <tr>
    <th>owner</th>
    <td><xsl:value-of select="JB_owner"/></td>
  </tr>
  <tr>
    <th>script</th>
    <td><xsl:value-of select="JB_script_file"/></td>
  </tr>
  <tr>
    <th>job name</th>
    <td><xsl:value-of select="JB_job_name"/></td>
  </tr>
  <tr>
    <th>cwd</th>
    <td><xsl:value-of select="JB_cwd"/></td>
  </tr>

  <!-- url viewfile?jobid=...&file={stdout} -->
  <tr>
    <th>stdout</th>
    <td>
      <xsl:variable name="PN_path" select="JB_stdout_path_list/path_list/PN_path" />
      <xsl:choose>
      <xsl:when test="$viewfileProgram">
        <xsl:element name="a">
        <xsl:attribute name="title">view stdout</xsl:attribute>
        <xsl:attribute name="href"><xsl:value-of
            select="$viewfileProgram"/>?jobid=<xsl:value-of
            select="JB_job_number"/><xsl:text>&amp;</xsl:text>file=<xsl:choose>
            <xsl:when test='starts-with($PN_path,"/")' >
              <!-- absolute path -->
              <xsl:value-of select="$PN_path"/>
            </xsl:when>
            <xsl:when test='starts-with($PN_path,"$HOME/")' >
              <!-- $HOME/path -->
              <xsl:value-of select="JB_env_list/job_sublist[VA_variable='__SGE_PREFIX__O_HOME']/VA_value" />
              <xsl:value-of select='substring($PN_path, 6)' />
            </xsl:when>
            <xsl:otherwise>
              <!-- relative path -->
            <xsl:value-of select="JB_cwd"/>/<xsl:value-of select="$PN_path"/>
          </xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
        <xsl:value-of select="$PN_path"/>
        </xsl:element>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$PN_path"/>
      </xsl:otherwise>
      </xsl:choose>
    </td>
  </tr>
  <tr>
    <th>context</th>
    <td><xsl:apply-templates select="JB_context/context_list"/></td>
  </tr>
  <tr>
    <th>job args</th>
    <td><xsl:apply-templates select="JB_job_args"/></td>
  </tr>
  <tr>
    <th>queue request</th>
    <td><xsl:apply-templates select="JB_hard_queue_list"/></td>
  </tr>
  <tr>
    <th>resource request</th>
    <td><xsl:apply-templates select="JB_hard_resource_list/qstat_l_requests"/></td>
  </tr>

  <!-- only for active/running jobs -->
  <xsl:choose>
  <xsl:when test="count(JB_ja_tasks)">
    <xsl:if test="JB_ja_tasks/ulong_sublist/JAT_granted_pe">
      <tr>
        <th>pe granted</th>
        <td>
          <xsl:apply-templates
              select="JB_ja_tasks/ulong_sublist/JAT_granted_pe"
          />
<xsl:text>
</xsl:text>
          <xsl:value-of
select="sum(JB_ja_tasks/ulong_sublist/JAT_granted_destin_identifier_list/element/JG_slots
or JB_ja_tasks/ulong_sublist/JAT_task_list/element/JG_slots)"/>
        </td>
      </tr>
    </xsl:if>
    <tr>
    </tr>

    <xsl:if test="JB_ja_tasks/ulong_sublist/JAT_granted_destin_identifier_list">
    <tr>
      <th>slot info</th>
      <td>
        <xsl:apply-templates
            select="JB_ja_tasks/ulong_sublist/JAT_granted_destin_identifier_list/element"
        />
      </td>
    </tr>
    </xsl:if>
<!--
    //
    // does not seem terribly useful for us
    //
    <tr>
      <th>tickets</th>
      <td>
        <xsl:apply-templates
            select="JB_ja_tasks/ulong_sublist"
            mode="tickets"/>
      </td>
    </tr>
-->
    <tr>
      <th>task info</th>
      <td>
        task = <xsl:value-of select="JB_ja_tasks/ulong_sublist/JAT_task_number"/>
        <xsl:apply-templates
            select="JB_ja_tasks/ulong_sublist/JAT_granted_destin_identifier_list/element"
            mode="tasks"
        />
      </td>
    </tr>
  </xsl:when>
  <xsl:otherwise>
    <xsl:if test="JB_pe">
      <tr>
        <th>pe requested</th>
        <td>
          <xsl:value-of select="JB_pe"/>
<xsl:text>
</xsl:text>
          <xsl:value-of select="JB_pe_range/ranges/RN_max"/>
        </td>
      </tr>
    </xsl:if>
    <tr>
      <th>predecessor</th>
      <td>
        <xsl:for-each
            select="JB_jid_predecessor_list/job_predecessors/JRE_job_number"
        >
          <xsl:value-of select="." />
<xsl:text>
</xsl:text>
        </xsl:for-each>
      </td>
    </tr>
  </xsl:otherwise>
  </xsl:choose>

  <tr>
    <th>posix</th>
    <td>
      uid = <xsl:value-of select="JB_uid"/>
      <br/>
      gid = <xsl:value-of select="JB_gid"/>
      <br/>
      group = <xsl:value-of select="JB_group"/>
    </td>
  </tr>

  <!-- department: seems to be missing in 6.1u3 -->
  <xsl:if test="JB_department">
    <tr>
      <th>department</th>
      <td>
        <xsl:value-of select="JB_department"/>
      </td>
    </tr>
  </xsl:if>

  <!-- project info -->
  <xsl:if test="JB_project">
    <tr>
      <th>project</th>
      <td>
        <xsl:value-of select="JB_project"/>
      </td>
    </tr>
  </xsl:if>

  <!-- path aliases: seems to be missing in 6.1u3 -->
  <xsl:if test="JB_path_aliases">
    <tr>
      <th>path aliases</th>
      <td>
        <xsl:apply-templates select="JB_path_aliases/PathAliases"/>
      </td>
    </tr>
  </xsl:if>

  <!-- job resource usage -->
  <xsl:if test="JB_ja_tasks/ulong_sublist/JAT_usage_list">
    <tr>
      <th>usage</th>
      <td>
        <xsl:apply-templates select="JB_ja_tasks/ulong_sublist/JAT_usage_list/element" />
      </td>
    </tr>
  </xsl:if>

  <!-- scaled job resource usage -->
  <xsl:if test="JB_ja_tasks/ulong_sublist/JAT_scaled_usage_list">
    <tr>
      <th>scaled usage</th>
      <td>
        <xsl:apply-templates select="JB_ja_tasks/ulong_sublist/JAT_scaled_usage_list/scaled"/>
      </td>
    </tr>
  </xsl:if>

<!-- 6.1: /detailed_job_info/messages/qmaster_response -->
  <xsl:if test="
      count(//detailed_job_info/messages/element/SME_message_list/element[MES_job_number_list/element/ULNG = $jobId])
    + count(//detailed_job_info/messages/qmaster_response/SME_message_list/element[MES_job_number_list/element/ULNG = $jobId])
    ">
    <tr>
      <th>
      scheduler messages
      </th>
      <td>
        <xsl:apply-templates
            select="
                //detailed_job_info/messages/element/SME_message_list/element[MES_job_number_list/element/ULNG = $jobId]
              | //detailed_job_info/messages/qmaster_response/SME_message_list/element[MES_job_number_list/element/ULNG = $jobId]
            "
        />
      </td>
    </tr>
  </xsl:if>
</table>
</blockquote>
<xsl:text>
</xsl:text>
</xsl:template>

<!-- (scaled) usage -->
<xsl:template match="JAT_usage_list/element|JAT_scaled_usage_list/scaled">
  <xsl:value-of select="UA_name"/> = <xsl:value-of select="UA_value"/>
  <br/>
</xsl:template>

<xsl:template match="JB_env_list/job_sublist">
  <xsl:value-of select="VA_variable"/> = <xsl:value-of select="VA_value"/>
  <br/>
</xsl:template>

<!-- path aliases -->
<xsl:template match="JB_path_aliases/PathAliases">
  <xsl:value-of select="PA_origin"/>
<xsl:text>
</xsl:text>
  <xsl:value-of select="PA_submit_host"/>
<xsl:text>
</xsl:text>
  <xsl:value-of select="PA_exec_host"/>
<xsl:text>
</xsl:text>
  <xsl:value-of select="PA_translation"/>
  <br/>
</xsl:template>

<xsl:template
    match="JAT_granted_destin_identifier_list/element |
    JAT_task_list/element/PET_granted_destin_identifier_list/element"
    mode="tasks"
>
  <div class="odd">tag_slave_job = <xsl:value-of select="JG_tag_slave_job"/></div>
  <div class="even">task_id_range = <xsl:value-of select="JG_task_id_range"/></div>
</xsl:template>

<xsl:template match="JAT_granted_destin_identifier_list/element">
  <div class="even">
    <strong><xsl:value-of select="JG_slots"/></strong>
    slots:
    <strong><xsl:apply-templates select="JG_qname"/></strong>
  </div>
</xsl:template>

<!-- extract tickets -->
<xsl:template match="JB_ja_tasks/ulong_sublist" mode="tickets">
  <div class="even">share = <xsl:value-of select="JAT_share" /></div>
  <div class="odd">fshare = <xsl:value-of select="JAT_fshare" /></div>
  <div class="even">ticket = <xsl:value-of select="JAT_tix" /></div>
  <div class="odd">oticket = <xsl:value-of select="JAT_oticket"/></div>
  <div class="even">fticket = <xsl:value-of select="JAT_fticket"/></div>
  <div class="odd">sticket = <xsl:value-of select="JAT_sticket"/></div>
  <div class="even">priority = <xsl:value-of select="JAT_prio"/></div>
  <div class="odd">ntix = <xsl:value-of select="JAT_ntix"/></div>
  <div class="even">overide_tickets = <xsl:value-of select="../../JB_override_tickets"/></div>
</xsl:template>

<xsl:template match="context_list">
  <xsl:value-of select="VA_variable"/>=<xsl:value-of select="VA_value"/><br/>
</xsl:template>

<xsl:template match="JB_job_args">
  <xsl:for-each select="element">
    <xsl:value-of select="./ST_name"/><br/>
  </xsl:for-each>
</xsl:template>


<!-- one of the components of a SGE scheduler message -->
<xsl:template match="MES_message_number">
  <!--
      funky stuff required to determine node position in context
      so we can use our standard mod math to determine even/odd class
      tag names
  -->
  <xsl:variable name="position"
      select="1 + count(parent::*/preceding-sibling::*)"
  />

  <xsl:choose>
  <xsl:when test="$position mod 2 = 1">
   <tr class="schedMesgRow">
     <td><span class="even"><xsl:value-of select="../MES_message"/></span></td>
   </tr>
  </xsl:when>
  <xsl:otherwise>
   <tr class="schedMesgRow">
     <td><span class="odd"><xsl:value-of select="../MES_message"/></span></td>
   </tr>
  </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<!-- do nothing because we output this in the template above -->
<xsl:template match="MES_message" />

<!-- job or global scheduling messages -->
<xsl:template match="SME_message_list/element|SME_global_message_list/element">
  <xsl:for-each select="MES_message">
    <xsl:value-of select="."/>
    <br/>
  </xsl:for-each>
</xsl:template>

<!--
  queue instance
-->
<xsl:template match="JG_qname|JAT_master_queue">
  <xsl:value-of select="substring-before(.,'@')"/>@<xsl:value-of select="substring-before(substring-after(.,'@'),'.')"/>
</xsl:template>

<xsl:template match="JB_hard_queue_list/destin_ident_list">
  <xsl:value-of select="QR_name" />
</xsl:template>

<xsl:template match="JB_hard_resource_list/qstat_l_requests">
  <xsl:value-of select="CE_name"/>=<xsl:value-of select="CE_stringval"/>
  <br/>
</xsl:template>


<!--
  create links for viewlog with plots
-->
<xsl:template match="JB_hard_resource_list" mode="viewlog">
<xsl:if test="count(qstat_l_requests/CE_name)">
  <xsl:text>
  </xsl:text>

  <xsl:variable name="resources">
    <xsl:for-each
        select="qstat_l_requests/CE_name"><xsl:value-of
        select="."/>,</xsl:for-each>
  </xsl:variable>
  <xsl:variable name="request">jobid=<xsl:value-of
        select="../JB_job_number"/><xsl:text>&amp;</xsl:text>resources=<xsl:value-of
        select="$resources"/>
  </xsl:variable>

  <!-- url viewlog?jobid=...&resources={resources} -->
  <xsl:element name="a">
    <xsl:attribute name="title">viewlog</xsl:attribute>
    <xsl:attribute name="href"><xsl:value-of
        select="$viewlogProgram"/>?<xsl:value-of
        select="$request"/><xsl:value-of select="$cgiParams"/></xsl:attribute>
    <img alt="[v]" src="images/icons/silk/page_find.png" border="0" />
  </xsl:element>

  <!-- url viewlog?action=plot&jobid=...&resources={resources} -->
  <xsl:element name="a">
    <xsl:attribute name="title">plotlog</xsl:attribute>
    <xsl:attribute name="href"><xsl:value-of
        select="$viewlogProgram"/>?action=plot<xsl:text>&amp;</xsl:text><xsl:value-of
        select="$request"/><xsl:value-of select="$cgiParams"/></xsl:attribute>
    <img alt="[p]" src="images/icons/silk/chart_curve.png" border="0" />
  </xsl:element>

  <!-- url viewlog?action=plot&owner=...&resources={resources} -->
  <xsl:element name="a">
    <xsl:attribute name="title">plotlogs</xsl:attribute>
    <xsl:attribute name="href"><xsl:value-of
        select="$viewlogProgram"/>?action=plot<xsl:text>&amp;</xsl:text>owner=<xsl:value-of
        select="../JB_owner"/><xsl:text>&amp;</xsl:text>resources=<xsl:value-of
        select="$resources"/><xsl:value-of select="$cgiParams"/></xsl:attribute>
    <img alt="[P]" src="images/icons/silk/chart_curve_add.png" border="0" />
  </xsl:element>
</xsl:if>
</xsl:template>

<!-- these nodes might contain the epoch instead of the proper date/time -->
<xsl:template match="JB_submission_time | JAT_start_time">
  <xsl:choose>
  <xsl:when test="contains(., ':')">
    <xsl:value-of select="."/>
  </xsl:when>
  <xsl:otherwise>
    <!-- convert epoch to dateTime -->
    <xsl:variable name="duration">
      <xsl:call-template name="date:duration">
        <xsl:with-param name="seconds" select="." />
      </xsl:call-template>
    </xsl:variable>
    <xsl:call-template name="date:add">
      <xsl:with-param name="date-time" select="'1970-01-01T00:00:00'" />
      <xsl:with-param name="duration"  select="$duration" />
    </xsl:call-template>
  </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<xsl:template name="stateTranslation">
  <xsl:param name="state" />

  <xsl:element name="acronym">
    <xsl:attribute name="title">
      <!-- this lookup translates JAT_state to something more readable -->
      <xsl:value-of
          select="$codeFile/config/status[@bitmask=$state]/long"
      />. The raw JAT_state bitmask code = <xsl:value-of select="$state"/>
    </xsl:attribute>
    <xsl:value-of
        select="$codeFile/config/status[@bitmask=$state]/translation"
    />
  </xsl:element>

</xsl:template>

</xsl:stylesheet>
