<?xml version="1.0" encoding="UTF-8"?>

<!--

ePatient section

Version: 2.1.2022Sep_3.5.1.250403CP1_250610
Revision Date: June 10, 2025

-->

<xsl:stylesheet version="3.0"
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
  <!-- This generates a complete NEMSIS ePatient section, filling in "Not Values" where data are 
       not available in the C-CDA document. -->
  <xsl:template match="hl7:patientRole">
    <ePatient>
      <!-- Names -->
      <!-- If a Legal name is provided, use that; otherwise, use the first name entry for the patient. -->
      <xsl:choose>
        <xsl:when test="hl7:patient/hl7:name[@use='L']">
          <xsl:apply-templates select="hl7:patient/hl7:name[@use='L'][1]"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="hl7:patient/hl7:name[1]"/>
        </xsl:otherwise>
      </xsl:choose>
      <!-- Home Address, City, State, ZIP Code, and Country -->
      <!-- Use the first address that represents a "home" address, if available. Otherwise, use the 
           first address that represents an "other" address, if available. Otherwise, use the first 
           address that has no use specified. Do not use "work" or "bad" addresses. -->
      <xsl:choose>
        <xsl:when test="hl7:addr[key('code', @use, $addressType/n:home)]">
          <xsl:apply-templates select="hl7:addr[key('code', @use, $addressType/n:home)][1]"/>
        </xsl:when>
        <xsl:when test="hl7:addr[key('code', @use, $addressType/n:other)]">
          <xsl:apply-templates select="hl7:addr[key('code', @use, $addressType/n:other)][1]"/>
        </xsl:when>
        <xsl:when test="hl7:addr[not(@use)]">
          <xsl:apply-templates select="hl7:addr[not(@use)][1]"/>
        </xsl:when>
      </xsl:choose>
      <!-- SSN -->
      <xsl:copy-of select="n:map('ePatient.12', hl7:id[@root='2.16.840.1.113883.4.1'], true())"/>
      <!-- Gender -->
      <xsl:copy-of select="n:map('ePatient.13', hl7:patient/hl7:administrativeGenderCode, true())"/>
      <!-- Race -->
      <xsl:copy-of select="n:map('ePatient.14', hl7:patient/hl7:raceCode, true())"/>
      <!-- Race: Additional Races (only the ones supported by NEMSIS; the complete list has 490 items) -->
      <xsl:copy-of select="n:map('ePatient.14', hl7:patient/sdtc:raceCode[key('code', @code, $race)], false())"/>
      <!-- Race: Hispanic or Latino Ethnicity-->
      <xsl:copy-of select="n:map('ePatient.14', hl7:patient/hl7:ethnicGroupCode, false())"/>
      <!-- Age/Age Units -->
      <!-- "Not Recorded". Age/Age Units should be calculated using date of birth and incident 
           date/time when the data from this transformation are imported into an EMS PCR. -->
      <ePatient.AgeGroup>
        <ePatient.15 xsi:nil="true" NV="7701003"/>
        <ePatient.16 xsi:nil="true" NV="7701003"/>
      </ePatient.AgeGroup>
      <!-- Date of Birth -->
      <xsl:copy-of select="n:map('ePatient.17', hl7:patient/hl7:birthTime[matches(@value, '^[0-9]{8}')], false())"/>
      <!-- Phone Numbers -->
      <xsl:copy-of select="n:map('ePatient.18', hl7:telecom[starts-with(@value, 'tel:')], false())"/>
      <!-- Email Addresses -->
      <xsl:copy-of select="n:map('ePatient.19', hl7:telecom[starts-with(@value, 'mailto:')], false())"/>
      <!-- Driver License -->
      <xsl:apply-templates select="hl7:id[starts-with(@root, '2.16.840.1.113883.4.3')]" mode="dl"/>
      <!-- Preferred Language(s)-->
      <xsl:copy-of select="n:map('ePatient.24', hl7:patient/hl7:languageCommunication, false())"/>
      <!-- Sex -->
      <!-- Use a Sex observation if provided ; otherwise, use a Birth Sex observation if provided. -->
      <xsl:choose>
        <xsl:when test="/hl7:ClinicalDocument/hl7:component/hl7:structuredBody/hl7:component/hl7:section/hl7:entry/hl7:observation[hl7:templateId/@root = '2.16.840.1.113883.10.20.22.4.507']">
          <xsl:copy-of select="n:map('ePatient.25', /hl7:ClinicalDocument/hl7:component/hl7:structuredBody/hl7:component/hl7:section/hl7:entry/hl7:observation[hl7:templateId/@root = '2.16.840.1.113883.10.20.22.4.507'][1], true())"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:copy-of select="n:map('ePatient.25', /hl7:ClinicalDocument/hl7:component/hl7:structuredBody/hl7:component/hl7:section/hl7:entry/hl7:observation[hl7:templateId/@root = '2.16.840.1.113883.10.20.22.4.200'][1], true())"/>
        </xsl:otherwise>
      </xsl:choose>
    </ePatient>
  </xsl:template>


  <!-- #Elements# -->

  <!-- Name -->
  <xsl:template match="hl7:patient/hl7:name">
    <ePatient.PatientNameGroup>
      <xsl:copy-of select="n:map('ePatient.02', hl7:family, false())"/>
      <xsl:copy-of select="n:map('ePatient.03', hl7:given[1], false())"/>
      <xsl:copy-of select="n:map('ePatient.04', hl7:given, false())"/>
      <xsl:copy-of select="n:map('ePatient.23', hl7:suffix, false())"/>
    </ePatient.PatientNameGroup>
  </xsl:template>

  <!-- Home Address -->
  <xsl:template match="hl7:patientRole/hl7:addr">
    <xsl:copy-of select="n:map('ePatient.05', hl7:streetAddressLine[1], false())"/>
    <xsl:copy-of select="n:map('ePatient.06', hl7:city, false())"/>
    <!-- County: not supported -->
    <ePatient.07 xsi:nil="true" NV="7701003"/>
    <xsl:copy-of select="n:map('ePatient.08', hl7:state, true())"/>
    <xsl:copy-of select="n:map('ePatient.09', hl7:postalCode, true())"/>
    <xsl:copy-of select="n:map('ePatient.10', hl7:country, true())"/>
  </xsl:template>

  <!-- Street Address -->
  <!-- HL7 allows up to four street address lines; NEMSIS allows up to 2.-->
  <xsl:template match="hl7:streetAddressLine[1]">
    <xsl:if test="../hl7:streetAddressLine[2]">
      <xsl:attribute name="StreetAddress2" select="../hl7:streetAddressLine[2]"/>
    </xsl:if>
    <xsl:apply-templates/>
  </xsl:template>

  <!-- City -->
  <!-- TODO: GNIS mapping -->
  <xsl:template match="hl7:city">
    <xsl:value-of select="n:gnisEncode(., ../hl7:state)"/>
  </xsl:template>

  <!-- State -->
  <!-- HL7 Value Set for State has no authoritative source. NEMSIS specifies specifies ANSI INCITS 
       38-2009 two-digit numeric codes. This transformation will use two-digit codes (assumed to be 
       ANSI codes) or map from postal abbreviations. -->
  <xsl:template match="hl7:state">
    <xsl:choose>
      <xsl:when test="matches(., '^[0-9]{2}$')">
        <xsl:apply-templates/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="key('code', ., $state)/@nemsis"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Postal Code -->
  <!-- NEMSIS only supports postal codes matching US, Canada, or Mexico patterns. If the value is 
       valid for NEMSIS, use it. -->
  <xsl:template match="hl7:postalCode[matches(., '^[0-9]{5}|[0-9]{5}-[0-9]{4}|[0-9]{5}-[0-9]{5}|[A-Z][0-9][A-Z] [0-9][A-Z][0-9]$')]">
    <xsl:apply-templates/>
  </xsl:template>

  <!-- Country -->
  <!-- HL7 Value Set for Country has no authoritative source. NEMSIS specifies ISO 3166 and 
       requires exactly two characters. If the value is valid for NEMSIS, use it. -->
  <xsl:template match="hl7:country[string-length() = 2]">
    <xsl:apply-templates/>
  </xsl:template>

  <!-- SSN -->
  <xsl:template match="hl7:id[@root='2.16.840.1.113883.4.1']">
    <xsl:value-of select="translate(@extension, '-', '')"/>
  </xsl:template>

  <!-- Gender -->
  <xsl:template match="hl7:administrativeGenderCode">
    <xsl:value-of select="key('code', @code, $gender)/@nemsis"/>
  </xsl:template>

  <!-- Race -->
  <xsl:template match="*:raceCode">
    <xsl:value-of select="key('code', @code, $race)/@nemsis"/>
  </xsl:template>

  <!-- Ethnicity: Hispanic or Latino -->
  <xsl:template match="hl7:ethnicGroupCode[@code='2135-2']">
    2514007
  </xsl:template>

  <!-- Date of Birth -->
  <xsl:template match="hl7:birthTime">
    <xsl:value-of select="n:date(@value)"/>
  </xsl:template>

  <!-- Phone Number -->
  <xsl:template match="hl7:telecom[starts-with(@value, 'tel:')]">
    <xsl:variable name="value">
      <xsl:choose>
        <!-- If the phone number starts with "+" after "tel:", try to extract digits matching 
             international format -->
        <xsl:when test="starts-with(@value, 'tel:+')">
          <xsl:variable name="digits" select="concat('+', normalize-space(replace(@value, '[^\d]', ' ')))"/>
          <xsl:if test="matches($digits, '^(\+([0-9] ?){6,14}[0-9])$')">
            <xsl:value-of select="$digits"/>
          </xsl:if>
        </xsl:when>
        <!-- Otherwise, try to extract digits matching US format -->
        <xsl:otherwise>
          <xsl:variable name="digits" select="replace(@value, '[^\d]', '')"/>
          <!-- If the digits are valid for NEMSIS, transform to NEMSIS US format  -->
          <xsl:if test="matches($digits, '^[2-9][0-9]{2}[2-9][0-9]{6}$')">
            <xsl:value-of select="replace($digits, '^([2-9][0-9]{2})([2-9][0-9]{2})([0-9]{4})$', '$1-$2-$3')"/>
          </xsl:if>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <!-- If the transformed value is valid for NEMSIS, proceed -->
    <xsl:if test="$value">
      <xsl:if test="key('code', @use, $phoneNumberType)/@nemsis != ''">
        <xsl:attribute name="PhoneNumberType" select="key('code', @use, $phoneNumberType)/@nemsis"/>
      </xsl:if>
      <xsl:value-of select="$value"/>
    </xsl:if>
  </xsl:template>

  <!-- Email Address -->
  <xsl:template match="hl7:telecom[starts-with(@value, 'mailto:')]">
    <!-- If the email address is valid for NEMSIS, proceed -->
    <xsl:if test="matches(@value, '@')">
      <xsl:attribute name="EmailAddressType" select="@use"/>
      <xsl:value-of select="tokenize(@value, ':')[2]"/>
    </xsl:if>
  </xsl:template>

  <!-- Driver License -->
  <xsl:template match="hl7:id[starts-with(@root, '2.16.840.1.113883.4.3')]" mode="dl">
    <!-- The 8th segment of the OID is the state ANSI code; see http://oid-info.com/get//2.16.840.1.113883.4.3. -->
    <ePatient.20><xsl:number value="tokenize(@root, '.')[8]" format="01"/></ePatient.20>
    <ePatient.21><xsl:value-of select="@extension"/></ePatient.21>
  </xsl:template>

  <!-- Preferred Language(s) -->
  <!-- If language code has a dash (for regional subtags), use only the portion before the dash -->
  <xsl:template match="hl7:languageCommunication">
    <xsl:value-of select="key('code', tokenize(hl7:languageCode/@code, '-')[1], $language)/@nemsis"/>
  </xsl:template>

  <!-- Sex -->
  <xsl:template match="hl7:observation[hl7:templateId/@root = ('2.16.840.1.113883.10.20.22.4.507', '2.16.840.1.113883.10.20.22.4.200')]">
    <xsl:variable name="result" select="key('code', hl7:value/@code, $sex)/@nemsis"/>
    <xsl:choose>
      <xsl:when test="$result = '8801019'">
        <xsl:attribute name="xsi:nil">true</xsl:attribute>
        <xsl:attribute name="PN" select="$result"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$result"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- #Variables# -->

  <!-- Address Type Variable -->
  <xsl:variable name="addressType">
    <home>
      <code hl7="H" hl7Desc="home address"/>
      <code hl7="HP" hl7Desc="primary home"/>
      <code hl7="HV" hl7Desc="vacation home"/>
      <code hl7="PHYS" hl7Desc="physical visit address"/>
      <code hl7="PST" hl7Desc="postal address"/>
    </home>
    <work>
      <code hl7="WP" hl7Desc="work place"/>
      <code hl7="DIR" hl7Desc="direct"/>
      <code hl7="PUB" hl7Desc="public"/>
    </work>
    <bad>
      <code hl7="BAD" hl7Desc="bad address"/>
    </bad>
    <other>
      <code hl7="CONF" hl7Desc="confidential address"/>
      <code hl7="TMP" hl7Desc="temporary address"/>
    </other>
  </xsl:variable>

</xsl:stylesheet>