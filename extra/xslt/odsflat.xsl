<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0"
		            xmlns:style="urn:oasis:names:tc:opendocument:xmlns:style:1.0"
		            xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0"
		            xmlns:table="urn:oasis:names:tc:opendocument:xmlns:table:1.0"
		            xmlns:draw="urn:oasis:names:tc:opendocument:xmlns:drawing:1.0"
		            xmlns:fo="urn:oasis:names:tc:opendocument:xmlns:xsl-fo-compatible:1.0"
		            xmlns:xlink="http://www.w3.org/1999/xlink"
		            xmlns:dc="http://purl.org/dc/elements/1.1/"
		            xmlns:meta="urn:oasis:names:tc:opendocument:xmlns:meta:1.0"
		            xmlns:number="urn:oasis:names:tc:opendocument:xmlns:datastyle:1.0"
		            xmlns:presentation="urn:oasis:names:tc:opendocument:xmlns:presentation:1.0"
		            xmlns:svg="urn:oasis:names:tc:opendocument:xmlns:svg-compatible:1.0"
		            xmlns:chart="urn:oasis:names:tc:opendocument:xmlns:chart:1.0"
		            xmlns:dr3d="urn:oasis:names:tc:opendocument:xmlns:dr3d:1.0"
		            xmlns:math="http://www.w3.org/1998/Math/MathML"
		            xmlns:form="urn:oasis:names:tc:opendocument:xmlns:form:1.0"
		            xmlns:script="urn:oasis:names:tc:opendocument:xmlns:script:1.0"
		            xmlns:ooo="http://openoffice.org/2004/office"
		            xmlns:ooow="http://openoffice.org/2004/writer"
		            xmlns:oooc="http://openoffice.org/2004/calc"
		            xmlns:dom="http://www.w3.org/2001/xml-events"
		            xmlns:xforms="http://www.w3.org/2002/xforms"
		            xmlns:xsd="http://www.w3.org/2001/XMLSchema"
		            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
		            xmlns:field="urn:openoffice:names:experimental:ooxml-odf-interop:xmlns:field:1.0"
		            xmlns:saxon="http://saxon.sf.net/"
                extension-element-prefixes="saxon"
                version='2.0'>
<!--
                exclude-result-prefixes="fo script xlink ooo dc ooow number dom xsi presentation  svg chart dr3d math form meta oooc xforms field"
-->



<!-- Flattens a OpenOffice Spreadsheet.

     When data captured in an Open Office Spreadsheet needs to be
     transformed to XML, we make the assumption that no cell spans
     more than one column and row, since that make the stylesheet
     simple to implement.

     However, since OpenOffice saves space by merging identical
     adjacent cells into one cell using the attribute
     table:number-columns-repeated (which is similar to the HTML
     colspan attribute), we need to "flatten" the merged cells,
     i.e. expand them to single non-merged cells before doing any
     processing of the spreadsheet.
-->


<xsl:output indent="yes" saxon:next-in-chain="p2-odsflat.xsl"/>


<xsl:template match="office:document-content">
  <coverpages>
    <xsl:apply-templates/>
  </coverpages>
</xsl:template>

<xsl:template match="office:scripts|office:font-face-decls|office:automatic-styles|table:table-column"/>


<xsl:template match="office:body|office:spreadsheet|table:calculation-settings|office:forms|table:iteration|text:p"><xsl:apply-templates/></xsl:template>

<xsl:template match="table:table">
  <table>
    <xsl:apply-templates/>
  </table>
</xsl:template>


<xsl:template match="table:table-row">
  <row>
    <xsl:apply-templates/>
  </row>
</xsl:template>


<xsl:template match="table:table-cell">
  <cell>
    <xsl:apply-templates/>
  </cell>
</xsl:template>


<xsl:template match="table:table-cell[@table:number-columns-repeated>1]">
  <xsl:call-template name="cellrepeat">
    <xsl:with-param name="repeat" select="@table:number-columns-repeated"/>
  </xsl:call-template>
</xsl:template>


<xsl:template name="cellrepeat">
  <xsl:param name="repeat">1</xsl:param>

  <xsl:if test="$repeat &gt; 0">
    <table:table-cell>
      <xsl:apply-templates select="@*[name()!='table:number-columns-repeated']"/>
      <xsl:apply-templates/>
    </table:table-cell>
    <xsl:call-template name="cellrepeat">
      <xsl:with-param name="repeat" select="$repeat - 1"/>
    </xsl:call-template>
  </xsl:if>
</xsl:template>

<xsl:template match="@*|node()">
  <xsl:copy>
    <xsl:apply-templates select="@*"/>
    <xsl:apply-templates/>
  </xsl:copy>
</xsl:template>

</xsl:stylesheet>
