<?xml version="1.0" encoding="UTF-8"?>

<!--

External Service Functions
These functions may be modified to connect to external services.

Version: 2.1.2022Sep_3.5.1.250403CP1_250610
Revision Date: June 10, 2025

-->

<xsl:stylesheet version="3.0"
  xmlns="http://www.nemsis.org"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array"
  xmlns:hl7="urn:hl7-org:v3"
  xmlns:n="http://www.nemsis.org"
  xmlns:sdtc="urn:hl7-org:sdtc"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">


  <!-- #Terminology Function# -->

  <!-- If you have access to a terminology mapping service, edit this function to implement API 
       calls. The function should accept an HL7 "code" or "value" element and the OID of a target 
       code system to map to, and return the corresponding code from the target code system as a 
       string. -->
  <xsl:function name="n:terminology">
    <!-- An HL7 C-CDA "code" or "value" element -->
    <xsl:param name="code" required="yes"/>
    <!-- The OID of the requested code system to map to -->
    <xsl:param name="codeSystem" required="yes" as="xs:string"/>
    <!-- Implement terminology service API call here. It should return a string value. -->
  </xsl:function>


  <!-- #GNIS Encode Function# -->

  <!-- If you have access to a GNIS lookup service, edit this function to implement API calls. 
       The function should accept a place name and a state postal code, and return the GNIS place 
       code as a string. This reference implementation uses the NEMSIS GNIS web service. -->
  <xsl:function name="n:gnisEncode" as="xs:string">
    <!-- A place name (city) as text -->
    <xsl:param name="placeName" required="yes"/>
    <!-- The postal code of the state where the city is located -->
    <xsl:param name="state" required="yes"/>
    <!-- Implement GNIS encoding service API call here. It should return a string value. -->
    <xsl:variable name="baseUrl">https://ws.nemsis.org/gnis/null/{placeName}</xsl:variable>
    <xsl:variable name="url" select="replace($baseUrl, '\{placeName\}', encode-for-uri($placeName))"/>
    <xsl:variable name="response" select="json-doc($url)?data"/>
    <xsl:variable name="matches" select="array:filter($response, function($i) {$i?STATE_ALPHA = $state and $i?FEATURE_NAME = $placeName})"/>
    <xsl:value-of select="if(array:size($matches) > 0) then $matches?1?FEATURE_ID else ''"/>
  </xsl:function>
</xsl:stylesheet>