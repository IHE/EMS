<?xml version="1.0" encoding="UTF-8"?>

<!--

Terminology service function

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


  <!-- #Terminology Function# -->

  <!-- If you have access to a terminology mapping service, edit this function to implement API calls. -->
  <xsl:function name="n:terminology">
    <!-- An HL7 C-CDA "code" or "value" element -->
    <xsl:param name="code" required="yes"/>
    <!-- The OID of the requested code system to map to -->
    <xsl:param name="codeSystem" required="yes" as="xs:string"/>
    <!-- Implement terminology service API call here. It should return a string value. -->
  </xsl:function>


</xsl:stylesheet>