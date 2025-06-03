<?xml version="1.0" encoding="UTF-8"?>

<!--

Functions

Version: 2.1.2022Sep_3.5.0.230317CP4_250603
Revision Date: June 3, 2025

-->

<xsl:stylesheet version="2.0"
  xmlns="http://www.nemsis.org"
  xmlns:hl7="urn:hl7-org:v3"
  xmlns:n="http://www.nemsis.org"
  xmlns:sdtc="urn:hl7-org:sdtc"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">


  <xsl:function name="n:map">
    <xsl:param name="nemsisElementName" required="yes" as="xs:string"/>
    <xsl:param name="hl7Element"/>
    <xsl:param name="nemsisRequired" as="xs:boolean"/>
    <xsl:variable name="result">
      <xsl:apply-templates select="$hl7Element"/>
    </xsl:variable>
    <xsl:if test="$result[. != ''] or $nemsisRequired">
      <xsl:element name="{$nemsisElementName}">
        <xsl:if test="not($result[. != ''])">
          <xsl:attribute name="xsi:nil">true</xsl:attribute>
          <xsl:attribute name="NV">7701003</xsl:attribute>
        </xsl:if>
        <xsl:copy-of select="$result"/>
      </xsl:element>
    </xsl:if>
  </xsl:function>

  <xsl:function name="n:mapTerminology">
    <xsl:param name="nemsisElementName" required="yes" as="xs:string"/>
    <xsl:param name="code" required="yes"/>
    <xsl:param name="codeSystem" required="yes" as="xs:string"/>
    <!-- Select code from the requested code system, which may come from code or code/translation -->
    <xsl:variable name="codeInSource" select="$code//*[@codeSystem=$codeSystem]/@code[1]"/>
     <xsl:choose>
      <!-- Return the value if found -->
      <xsl:when test="$codeInSource">
        <xsl:element name="{$nemsisElementName}">
          <xsl:value-of select="$codeInSource"/>
        </xsl:element>
      </xsl:when>
      <!-- Otherwise, call the terminology service (extensible function in terminologyService.xsl) -->
      <xsl:otherwise>
        <xsl:variable name="codeFromTerminologyService" select="n:terminology($code, $codeSystem)"/>
        <xsl:choose>
          <xsl:when test="$codeFromTerminologyService">
            <xsl:element name="{$nemsisElementName}">
              <xsl:value-of select="$codeFromTerminologyService"/>
            </xsl:element>
          </xsl:when>
          <xsl:otherwise>
            <xsl:comment>Unable to map code <xsl:value-of select="string-join($code/(@code, @displayName), ' ')"/> from code system <xsl:value-of select="string-join($code/(@codeSystem, @codeSystemName), ' ')"/>.</xsl:comment>
            <xsl:element name="{$nemsisElementName}">
              <xsl:attribute name="xsi:nil">true</xsl:attribute>
              <xsl:attribute name="NV">7701003</xsl:attribute>
            </xsl:element>
              </xsl:otherwise>
          </xsl:choose>
      </xsl:otherwise>
     </xsl:choose>
  </xsl:function>

  <xsl:function name="n:dateTime">
    <xsl:param name="hl7DateTime"/>
    <!-- Only transform dateTime values that are specified at least to the minute and have a timezone -->
    <xsl:if test="matches($hl7DateTime, '^([0-9]{12}|[0-9]{14}(\.[0-9]+)?)([+-][0-9]{4})$')">
      <!-- Add "00" seconds if seconds are missing -->
      <xsl:variable name="fullDateTime" select="replace($hl7DateTime, '^([0-9]{12})([+-][0-9]{4})$', '$100$2')"/>
      <xsl:value-of select="xs:dateTime(replace($fullDateTime, '^([0-9]{4})([0-9]{2})([0-9]{2})([0-9]{2})([0-9]{2})([0-9]{2})?(\.[0-9]+)?([+-])([0-9]{2})([0-9]{2})$','$1-$2-$3T$4:$5:$6$7$8$9:$10'))"/>
    </xsl:if>
  </xsl:function>

  <xsl:function name="n:date">
    <xsl:param name="hl7Date"/>
    <!-- Only transform date values that are specified at least to the day -->
    <xsl:if test="matches($hl7Date, '^[0-9]{8}')">
      <xsl:value-of select="xs:date(replace($hl7Date, '^([0-9]{4})([0-9]{2})([0-9]{2})(.*)$','$1-$2-$3'))"/>
    </xsl:if>
  </xsl:function>


</xsl:stylesheet>