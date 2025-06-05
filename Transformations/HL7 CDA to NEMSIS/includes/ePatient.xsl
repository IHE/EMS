<?xml version="1.0" encoding="UTF-8"?>

<!--

ePatient section

Version: 2.1.2022Sep_3.5.0.230317CP4_250605
Revision Date: June 5, 2025

-->

<xsl:stylesheet version="2.0"
  xmlns="http://www.nemsis.org"
  xmlns:hl7="urn:hl7-org:v3"
  xmlns:n="http://www.nemsis.org"
  xmlns:sdtc="urn:hl7-org:sdtc"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="hl7 n sdtc xs">


  <!-- #Section# -->

  <!-- ePatient -->
  <!-- To assist patient identification and record matching, this transformation generates an 
       incomplete NEMSIS ePatient section. It only includes some elements. -->
  <xsl:template match="hl7:patientRole">
    <ePatient>
      <!-- Names -->
      <!-- If a Legal name is provided, use that; otherwise, use the first name entry for the patient. -->
      <xsl:choose>
        <xsl:when test="hl7:patient/hl7:name[@use='L']">
          <xsl:apply-templates select="hl7:patient/hl7:name[@use='L']"/>    
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="hl7:patient/hl7:name[1]"/>
        </xsl:otherwise>
      </xsl:choose>
      <!-- Patient's Home Address, City, State, ZIP Code, and Country could also be mapped, but 
           they are not implemented in this transformation. City would need to be mapped from text
           to GNIS code. State would need to be mapped from postal abbreviation to ANSI code. -->
      <!-- SSN -->
      <xsl:apply-templates select="hl7:id[@root='2.16.840.1.113883.4.1']" mode="ssn"/>
      <!-- Gender -->
      <xsl:apply-templates select="hl7:patient/hl7:administrativeGenderCode"/>
      <!-- Race -->
      <xsl:apply-templates select="hl7:patient/hl7:raceCode"/>
      <!-- Race: Additional Races (only the ones supported by NEMSIS; the complete list has 490 items) -->
      <xsl:apply-templates select="hl7:patient/sdtc:raceCode[key('code', @code, $race)]"/>
      <!-- Race: Hispanic or Latino Ethnicity-->
      <xsl:apply-templates select="hl7:patient/hl7:ethnicGroupCode"/>
      <!-- Date of Birth -->
      <xsl:apply-templates select="hl7:patient/hl7:birthTime[matches(@value, '^[0-9]{8}')]"/>
      <!-- Phone Numbers -->
      <xsl:apply-templates select="hl7:telecom[starts-with(@value, 'tel:')]"/>
      <!-- Email Addresses -->
      <xsl:apply-templates select="hl7:telecom[starts-with(@value, 'mailto:')]"/>
      <!-- Driver License -->
      <xsl:apply-templates select="hl7:id[starts-with(@root, '2.16.840.1.113883.4.3')]" mode="dl"/>
    </ePatient>
  </xsl:template>


  <!-- #Elements# -->

  <!-- Patient Name -->
  <xsl:template match="hl7:patient/hl7:name">
    <ePatient.PatientNameGroup>
      <xsl:apply-templates select="hl7:family"/>
      <xsl:apply-templates select="hl7:given[1]"/>
      <xsl:apply-templates select="hl7:given[2]"/>
    </ePatient.PatientNameGroup>
  </xsl:template>

  <xsl:template match="hl7:family">
    <ePatient.02><xsl:value-of select="."/></ePatient.02>
  </xsl:template>

  <xsl:template match="hl7:given[1]">
    <ePatient.03><xsl:value-of select="."/></ePatient.03>
  </xsl:template>

  <xsl:template match="hl7:given[2]">
    <ePatient.04><xsl:value-of select="."/></ePatient.04>
  </xsl:template>

  <!-- SSN -->
  <xsl:template match="hl7:patientRole/hl7:id[@root='2.16.840.1.113883.4.1']" mode="ssn">
    <ePatient.12><xsl:value-of select="translate(@extension, '-', '')"/></ePatient.12>
  </xsl:template>

  <!-- Gender -->
  <xsl:template match="hl7:administrativeGenderCode">
    <ePatient.13><xsl:value-of select="key('code', @code, $gender)/@nemsis"/></ePatient.13>
  </xsl:template>

  <!-- Race -->
  <xsl:template match="*:raceCode">
    <ePatient.14><xsl:value-of select="key('code', @code, $race)/@nemsis"/></ePatient.14>
  </xsl:template>

  <!-- Ethnicity: Hispanic or Latino -->
  <xsl:template match="hl7:ethnicGroupCode[@code='2135-2']">
    <ePatient.14>2514007</ePatient.14>
  </xsl:template>
  
  <!-- Date of Birth -->
  <xsl:template match="hl7:birthTime">
    <ePatient.17><xsl:copy-of select="n:date(@value)"/></ePatient.17>
  </xsl:template>

  <!-- Phone Number -->
  <xsl:template match="hl7:telecom[starts-with(@value, 'tel:')]">
    <!-- NEMSIS only supports US phone numbers; remove "tel:" prefix, "+1" country code for US if 
         present, and all non-digits. -->
    <xsl:variable name="digits" select="replace(@value, '(tel:)|(\+1)|([^\d])', '')"/>
    <!-- If the remaining digits are valid for NEMSIS, proceed -->
    <xsl:if test="matches($digits, '^[2-9][0-9]{2}[2-9][0-9]{6}$')">
      <ePatient.18>
        <xsl:if test="key('code', @use, $phoneNumberType)/@nemsis != ''">
          <xsl:attribute name="PhoneNumberType" select="key('code', @use, $phoneNumberType)/@nemsis"/>
        </xsl:if>
        <xsl:value-of select="replace($digits, '^([2-9][0-9]{2})([2-9][0-9]{2})([0-9]{4})$', '$1-$2-$3')"/>
      </ePatient.18>
    </xsl:if>
  </xsl:template>

  <!-- Email Address -->
  <xsl:template match="hl7:telecom[starts-with(@value, 'mailto:')]">
    <!-- If the email address is valid for NEMSIS, proceed -->
    <xsl:if test="matches(@value, '@')">
      <ePatient.19>
        <xsl:attribute name="EmailAddressType" select="@use"/>
        <xsl:value-of select="tokenize(@value, ':')[2]"/>
      </ePatient.19>
    </xsl:if>
  </xsl:template>

  <!-- Driver License -->
  <xsl:template match="hl7:id[starts-with(@root, '2.16.840.1.113883.4.3')]" mode="dl">
    <!-- The 8th segment of the OID is the state ANSI code; see http://oid-info.com/get//2.16.840.1.113883.4.3. -->
    <ePatient.20><xsl:number value="tokenize(@root, '.')[8]" format="01"/></ePatient.20>
    <ePatient.21><xsl:value-of select="@extension"/></ePatient.21>
  </xsl:template>


</xsl:stylesheet>