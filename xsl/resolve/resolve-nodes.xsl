<?xml version="1.0" encoding="ISO-8859-1"?>

<!--

This stylesheet is created for the NATO Interoperability Standard and
profiles (NISP), and is intended for resolving volume 2.

Copyright (c) 2002-2017, Jens Stavnstrup/DALO <stavnstrup@mil.dk>
Danish Defence Acquisition and Logistic Organisation (DALO),
Danish Defence Research Establishment (DDRE) and
NATO Command, Control and Consultation Organisation (NC3O).

-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version='1.1'
                xmlns:saxon="http://icl.com/saxon"
                exclude-result-prefixes="#default saxon">

<xsl:import href="../common/common.xsl"/>
<xsl:import href="resolve-common.xsl"/>


<xsl:output method="xml" indent="yes"
            saxon:next-in-chain="resolve-fix.xsl"/>
						
<xsl:variable name="db"
              select="document(concat($dbdir, $dbname))"/>



<!-- ==================================================================== -->

<xsl:template match="/">
  <xsl:comment>

     DO NOT MODIFY THIS DOCUMENT. THIS IS A RESOLVED VERSION ONLY.

  </xsl:comment>

  <xsl:apply-templates/>
</xsl:template>

<!-- ==================================================================== -->

<xsl:template match="processing-instruction('dbmerge')">

  <xsl:variable name="pis"><xsl:value-of select="."/></xsl:variable>

  <xsl:choose>
    <xsl:when test="starts-with($pis, 'node=')">
      <!-- Get the  the node attribute -->
      <xsl:variable name="node">
        <xsl:call-template name="dbmerge-attribute">
          <xsl:with-param name="pi" select="$pis"/>
	        <xsl:with-param name="attribute" select="'node'"/>
        </xsl:call-template>
      </xsl:variable>
      <xsl:variable name="obligation">
        <xsl:call-template name="dbmerge-attribute">
          <xsl:with-param name="pi" select="$pis"/>
	        <xsl:with-param name="attribute" select="'obligation'"/>
        </xsl:call-template>
      </xsl:variable>

      <xsl:if test="not($node='')">
        <xsl:apply-templates select="$db//node[@id=$node]" mode="highlevel">
          <xsl:with-param name="obligation" select="$obligation"/>
        </xsl:apply-templates>
      </xsl:if>
    </xsl:when>
  </xsl:choose>
</xsl:template>

<!-- ==================================================================== -->
<xsl:template match="processing-instruction('cpbprfmerge')">
  <xsl:variable name="pis"><xsl:value-of select="."/></xsl:variable>
  <xsl:variable name="cpbprf" select="$db//capabilityprofile[@id=$pis]"/>
  <xsl:variable name="lc" select="'abcdefghijklmnopqrstuvwxyz'"/>
  <xsl:variable name="uc" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>
	<row>
		<entry align="left" colname="col1">
			<emphasis role="bold"><xsl:value-of select="$cpbprf/@servicearea"/></emphasis>
		</entry>
		<entry align="left" colname="col2">
			<xsl:value-of select="$cpbprf/@title"/>
		</entry>
	</row>
	<row>
		<entry align="left" namest="col1" nameend="col2">
		<xsl:apply-templates select="$cpbprf/description"/>
	</entry>
	</row>
	<row>
		<entry align="left" colname="col1">
			<ulink url="{$cpbprf/status/uri}"><xsl:value-of select="$cpbprf/status/pdf"/></ulink>
			<xsl:if test="$cpbprf/@docinfo != ''">
				<xsl:value-of select="concat(' - ',$cpbprf/@docinfo)"/>
			</xsl:if>
		</entry>
		<entry align="left" colname="col2">
			<xsl:value-of select="translate($cpbprf/@id,$lc,$uc)"/>
		</entry>
	</row>
	<row><!-- Intentional Blank Line --><entry align="left" namest="col1" nameend="col2"><xsl:text> </xsl:text></entry></row>
</xsl:template>

<xsl:template match="capabilityprofile/description">
	<xsl:copy-of select="*"/>
</xsl:template>


<!-- ==================================================================== -->

<xsl:template match="indexterm">
  <xsl:variable name="orgid" select="./primary"/>

  <xsl:variable name="orgname">
    <xsl:choose>
      <xsl:when test="$orgid != ''"><xsl:value-of
                select="$db//standards/organisations/orgkey[@key=$orgid]/@long"/></xsl:when>
      <xsl:otherwise><primary><xsl:text>UNKNOWN ORG</xsl:text></primary></xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:if test="$use.show.indexterms != 0">
    <emphasis role="bold">
      <xsl:text> [</xsl:text>
      <xsl:value-of select="$orgname"/>
      <xsl:text>, </xsl:text>
      <xsl:value-of select="./secondary"/>
      <xsl:text>] </xsl:text>
    </emphasis>
  </xsl:if>

  <indexterm>
    <primary><xsl:value-of select="$orgname"/></primary>
    <xsl:copy-of select="secondary"/>
  </indexterm>
</xsl:template>


<!-- ==================================================================== -->

<xsl:template match="@*" mode="addindexentry">
  <xsl:variable name="id" select="."/>

  <xsl:variable name="record" select="$db//standard[@id=$id]"/>
  <xsl:for-each select="$record/document">
     <xsl:variable name="org" select="@orgid"/>
     <indexterm>
       <xsl:choose>
         <xsl:when test="@orgid != ''"><primary><xsl:value-of
                   select="ancestor::standards/organisations/orgkey[@key=$org]/@long"/></primary></xsl:when>
         <xsl:otherwise><primary><xsl:text>UNKNOWN ORG</xsl:text></primary></xsl:otherwise>
       </xsl:choose>
       <xsl:choose>
         <xsl:when test="@pubnum != ''"><secondary><xsl:value-of select="./@pubnum"/></secondary></xsl:when>
       </xsl:choose>
     </indexterm>
    </xsl:for-each>
</xsl:template>


<!-- ==================================================================== -->

<xsl:template match="select|remarks">
  <xsl:apply-templates/>
</xsl:template>

<!-- ==================================================================== -->

<!-- This template can properly be merged into the procesing
     instruction template, but assumes that the node seleted is at a
     sufficiently high level and do not "have" any standards.

-->

<xsl:template match="node" mode="highlevel">
  <xsl:param name="obligation" select="''"/>

  <xsl:variable name="id" select="@id"/>
  <informaltable frame="all" pgwide="1">
  <tgroup cols="4">
    <colspec colwidth="40*" colname="c1" />
    <colspec colwidth="25*" colname="c2"/>
    <colspec colwidth="20*" colname="c3"/>
    <colspec colwidth="15*" colname="c4"/>
    <thead>
      <row>
        <entry>Title</entry>
        <entry>Pubnum</entry>
        <entry>Profiles</entry>
        <entry>Responsible Party</entry>
      </row>
    </thead>
    <tbody>
      <xsl:choose>
        <xsl:when test="$obligation='mandatory'">
          <xsl:apply-templates select="." mode="listmandatory"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="." mode="listcandidate"/>
        </xsl:otherwise>
      </xsl:choose>
    </tbody>
  </tgroup>
  </informaltable>
</xsl:template>


<xsl:template match="node" mode="listmandatory">
  <xsl:variable name="id" select="@id"/>

  <xsl:variable name="refs" select="count(/standards/profilehierachy//hrefstandard[(../@obligation='mandatory') and (../../reftaxonomy/@refid=$id)])"/>
  <xsl:if test="$refs>0">
    <row>
      <entry namest="c1" nameend="c4"><emphasis role="bold"><xsl:value-of select="@title"/></emphasis></entry>
    </row>
    <!-- Get standards from profiles -->
    <xsl:apply-templates select="/standards/profilehierachy//hrefstandard[(../@obligation='mandatory') and (../../reftaxonomy/@refid=$id)]" mode="listmandatory">
      <xsl:with-param name="taxref" select="$id"/>
      <xsl:sort select="@refid"/>
    </xsl:apply-templates>
  </xsl:if>
  <!-- Handle child nodes -->
  <xsl:apply-templates mode="listmandatory"/>
</xsl:template>


<xsl:template match="hrefstandard" mode="listmandatory">
  <xsl:param name="taxref" select="''"/>

  <xsl:variable name="stdid" select="@refid"/>
  <xsl:variable name="std" select="$db//standard[@id=$stdid]"/>
  <xsl:variable name="myorgid" select="$std/responsibleparty/@rpref"/>

  <xsl:if test="not(ancestor::capabilityprofile/preceding-sibling::capabilityprofile//hrefstandard[(@refid=$stdid) and (../@obligation='mandatory') and (../../reftaxonomy/@refid=$taxref)])
                      and
                not(ancestor::serviceprofile/preceding-sibling::serviceprofile//hrefstandard[(@refid=$stdid) and (../@obligation='mandatory') and (../../reftaxonomy/@refid=$taxref)])">
    <row>
      <entry>
        <xsl:choose>
          <xsl:when test="$std/status/uri != ''">
            <ulink url="{$std/status/uri}"><xsl:value-of select="$std/document/@title"/></ulink>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$std/document/@title"/>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:variable name="note" select="string($std/document/@note)"/>
        <xsl:if test="string-length($note) &gt; 0">
        	<footnote><para><xsl:value-of select="$std/document/@pubnum"/> - <xsl:value-of select="$note"/></para></footnote>
        </xsl:if>
        <xsl:apply-templates select="@refid" mode="addindexentry"/>
      </entry>
      <entry>
        <xsl:if test="$std/document/@orgid !=''">
          <xsl:value-of select="/standards/organisations/orgkey[@key=$std/document/@orgid]/@short"/>
          <xsl:text> </xsl:text>
        </xsl:if>
        <xsl:if test="$std/document/@pubnum !=''">
          <xsl:value-of select="$std/document/@pubnum"/>
        </xsl:if>
      </entry>
      <entry>
        <xsl:apply-templates select="/standards/profilehierachy/capabilityprofile" mode="listcp">
          <xsl:with-param name="taxref" select="$taxref"/>
          <xsl:with-param name="stdid" select="$stdid"/>
        </xsl:apply-templates>
      </entry>
      <entry><xsl:value-of select="/standards/organisations/orgkey[@key=$myorgid]/@short"/></entry>
    </row>
  </xsl:if>
</xsl:template>


<xsl:template match="node" mode="listcandidate">
  <xsl:variable name="id" select="@id"/>

  <xsl:variable name="refs" select="count(/standards/bestpracticeprofile//bprefstandard[(../@mode='candidate') and (../../@tref=$id)])"/>
  <xsl:if test="$refs>0">
    <row>
      <entry namest="c1" nameend="c4"><emphasis role="bold"><xsl:value-of select="@title"/></emphasis></entry>
    </row>
    <!-- Get standards from profiles -->
    <xsl:apply-templates select="/standards/bestpracticeprofile//bprefstandard[(../@mode='candidate') and (../../@tref=$id)]" mode="listcandidate">
      <xsl:with-param name="taxref" select="$id"/>
      <xsl:sort select="@refid"/>
    </xsl:apply-templates>
  </xsl:if>
  <!-- Handle child nodes -->
  <xsl:apply-templates mode="listcandidate"/>
</xsl:template>


<xsl:template match="bprefstandard" mode="listcandidate">
  <xsl:param name="taxref" select="''"/>

  <xsl:variable name="stdid" select="@refid"/>
  <xsl:variable name="std" select="$db//standard[@id=$stdid]"/>
  <xsl:variable name="myorgid" select="$std/responsibleparty/@rpref"/>

  <row>
    <entry>
      <xsl:choose>
        <xsl:when test="$std/status/uri != ''">
          <ulink url="{$std/status/uri}"><xsl:value-of select="$std/document/@title"/></ulink>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$std/document/@title"/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:variable name="note" select="string($std/document/@note)"/>
      <xsl:if test="string-length($note) &gt; 0">
      	<footnote><para><xsl:value-of select="$std/document/@pubnum"/> - <xsl:value-of select="$note"/></para></footnote>
      </xsl:if>
      <xsl:apply-templates select="@refid" mode="addindexentry"/>
    </entry>
    <entry>
      <xsl:if test="$std/document/@orgid !=''">
        <xsl:value-of select="/standards/organisations/orgkey[@key=$std/document/@orgid]/@short"/>
        <xsl:text> </xsl:text>
      </xsl:if>
      <xsl:if test="$std/document/@pubnum !=''">
        <xsl:value-of select="$std/document/@pubnum"/>
      </xsl:if>
    </entry>
    <entry>BSP</entry>
    <entry><xsl:value-of select="/standards/organisations/orgkey[@key=$myorgid]/@short"/></entry>
  </row>
</xsl:template>


<xsl:template match="capabilityprofile" mode="listcp">
  <xsl:param name="taxref"/>
  <xsl:param name="stdid"/>

  <xsl:if test=".//hrefstandard[(@refid=$stdid) and (../@obligation='mandatory') and (../../reftaxonomy/@refid=$taxref)]">
    <xsl:choose>
      <xsl:when test="@type = 'bsp'">BSP</xsl:when>
      <xsl:otherwise><xsl:value-of select="translate(@id,'abcdefghijklmnopqrstuvwxyz','ABCDEFGHIJKLMNOPQRSTUVWXYZ')"/></xsl:otherwise>
    </xsl:choose>
    <xsl:if test="following-sibling::capabilityprofile//hrefstandard[(@refid=$stdid) and (../@obligation='mandatory') and (../../reftaxonomy/@refid=$taxref)]">
      <xsl:text>, </xsl:text>
    </xsl:if>
  </xsl:if>
</xsl:template>

</xsl:stylesheet>
