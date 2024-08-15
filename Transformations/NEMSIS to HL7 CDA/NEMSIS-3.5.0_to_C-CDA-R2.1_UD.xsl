<?xml version="1.0" encoding="UTF-8"?>

<!--

XML Stylesheet Language Transformation (XSLT) to transform from NEMSIS EMSDataSet v3.5.0 to HL7 
C-CDA v2.1 Unstructured Document

This product is provided by the NEMSIS TAC, without charge, to facilitate a data mapping between 
NEMSIS v3.5.0 and HL7 C-CDA. This stylesheet transforms a PCR from an EMS crew, provided in NEMSIS 
v3.5.0 format, into an HL7 C-CDA R2.1 Clinical Document representing the information from EMS's care 
of the patient.

This stylesheet assumes the document to be transformed is a NEMSIS EMSDataSet Document containing a 
single PCR. If the document contains multiple PCRs, only the first PCR is transformed.

Version: 3.5.0.230317CP4_2.1.2022Sep_240815
Revision Date: August 15, 2024

-->

<xsl:stylesheet version="2.0"
  xmlns="urn:hl7-org:v3"
  xmlns:hl7="urn:hl7-org:v3"
  xmlns:n="http://www.nemsis.org"
  xmlns:sdtc="urn:hl7-org:sdtc"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="hl7 n xs">

  <xsl:output method="xml" encoding="UTF-8" indent="yes"/>

  <!-- Parameter: configUrl (optional)
       Format: URL
       This transformation requires a configuration document containing information about the EMS 
       agency that is not available in NEMSIS but mandatory in the HL7 C-CDA header. This parameter 
       makes it possible to point to a file or other URL that contains the necessary information. 
       If this parameter is not provided, the stylesheet will use the configuration in 
       NEMSIS-3.5.0_to_C-CDA-R2.1_Config.xml located in the same location as this transformation 
       file.
   -->
  <xsl:param name="configUrl"/>

  <xsl:variable name="config" select="document(if ($configUrl) then $configUrl else 'NEMSIS-3.5.0_to_C-CDA-R2.1_Config.xml')/hl7:config"/>

  <!-- The current date/time is used for effectiveTime and author/time. The C-CDA US Realm Header 
       specifies that effectiveTime "signifies the document creation time, when the document first 
       came into being. Where the CDA document is a transform from an original document in some 
       other format, the ClinicalDocument.effectiveTime is the time the original document is 
       created. The time when the transform occurred is not currently represented in CDA." However, 
       the NEMSIS document contains no information about when the original document was created or 
       modified. -->
  <xsl:variable name="currentDateTime" select="n:dateTime(xs:string(current-dateTime()))"/>

  <xsl:key name="code" match="*" use="@nemsis"/>


  <!-- #Terminology Function# -->

  <!-- If you have access to a GNIS lookup service, edit this function to implement API calls. 
       The function should accept a GNIS place code and return the place name as a string. This 
       reference implementation uses the NEMSIS GNIS web service. -->
  <xsl:function name="n:gnis" as="xs:string">
    <xsl:param name="gnis" required="yes"/>
    <xsl:variable name="baseUrl">https://ws.nemsis.org/gnis/{gnis}/null</xsl:variable>
    <xsl:variable name="url" select="replace($baseUrl, '\{gnis\}', $gnis)"/>
    <xsl:variable name="gnisResponse" select="unparsed-text($url)"/>
    <xsl:variable name="gnisName" select="substring-before(substring-after($gnisResponse, '&quot;FEATURE_NAME&quot;:&quot;'), '&quot;')"/>
    <xsl:value-of select="$gnisName"/>
  </xsl:function>


  <!-- #Root Template# -->

  <xsl:template match="/">
    <xsl:comment>
     This HL7 C-CDA R2.1 Unstructured Document was generated from a NEMSIS EMSDataSet document via 
     an XML Stylesheet Language Transformation (XSLT).
    </xsl:comment>
    <xsl:text>&#10;</xsl:text>
    <xsl:if test="not(/n:EMSDataSet)">
      <xsl:comment>
        Warning: The source document does not appear to be a NEMSIS EMSDataSet Document. Results 
        may be incomplete or incorrect.
      </xsl:comment>
    </xsl:if>
    <xsl:if test="count(/n:EMSDataSet/n:Header/n:PatientCareReport) > 1">
      <xsl:comment>
        Warning: The source document contains multiple patient care reports. Only the first one is
        transformed.
      </xsl:comment>
    </xsl:if>
    <xsl:apply-templates select="/n:EMSDataSet/n:Header[1]/n:PatientCareReport[1]"/>
  </xsl:template>


  <!-- #Document# -->

  <xsl:template match="n:PatientCareReport">
    <ClinicalDocument>
      <realmCode code="US"/>
      <typeId root="2.16.840.1.113883.1.3" extension="POCD_HD000040"/>
      <templateId root="2.16.840.1.113883.10.20.22.1.1" extension="2015-08-01"/>
      <templateId root="2.16.840.1.113883.10.20.22.1.10" extension="2015-08-01"/>
      <!-- id: eRecord.01 Patient Care Report Number could be used instead, but @UUID is 
           guaranteed to be universally unique. This should be an id that changes each time the 
           document is re-generated from the underlying data, but such information is not available 
           in the NEMSIS document. -->
      <id>
        <xsl:copy-of select="n:id(@UUID)"/>
      </id>
      <code code="67796-3" codeSystem="2.16.840.1.113883.6.1" displayName="EMS patient care report"/>
      <title>EMS Patient Care Report</title>
      <effectiveTime value="{$currentDateTime}"/>
      <confidentialityCode codeSystem="2.16.840.1.113883.5.25" code="N" displayName="normal"/>
      <languageCode code="en-US"/>
      <!-- setId: eRecord.01 Patient Care Report Number could be used instead, but @UUID is 
           guaranteed to be universally unique and unchanging. -->
      <setId>
        <xsl:copy-of select="n:id(@UUID)"/>
      </setId>
      <!-- There's not sufficient information in the NEMSIS document to know the versionNumber. -->
      <versionNumber nullFlavor="UNK"/>
      <xsl:apply-templates select="n:ePatient"/>
      <xsl:apply-templates select="$config/hl7:author" mode="authorPerson"/>
      <xsl:apply-templates select="$config/hl7:author" mode="authorSoftware">
        <xsl:with-param name="pcr" select="."/>
      </xsl:apply-templates>
      <xsl:apply-templates select="$config/hl7:custodian" mode="config"/>
      <xsl:apply-templates select="." mode="serviceEvent"/>
      <xsl:apply-templates select="." mode="encompassingEncounter"/>
      <xsl:apply-templates select="." mode="nonXMLBody"/>
    </ClinicalDocument>
  </xsl:template>


  <!-- #Sections# -->

  <!-- Patient -->
  <xsl:template match="n:ePatient">
    <recordTarget>
      <patientRole>
        <xsl:copy-of select="n:map('id', n:ePatient.01, true())"/>
        <xsl:copy-of select="n:map('id', n:ePatient.12, false())"/>
        <xsl:copy-of select="n:map('id', n:ePatient.21, false())"/>
        <addr use="HP">
          <xsl:choose>
            <xsl:when test="(n:ePatient.05, n:ePatient.05/@StreetAddress2, n:ePatient.06, n:ePatient.08, n:ePatient.09, n:ePatient.10)[. != '']">
              <xsl:copy-of select="n:map('streetAddressLine', n:ePatient.05, true())"/>
              <xsl:copy-of select="n:map('streetAddressLine', n:ePatient.05/@StreetAddressLine2, false())"/>
              <xsl:copy-of select="n:map('city', n:ePatient.06, true())"/>
              <xsl:copy-of select="n:map('state', n:ePatient.08, true())"/>
              <xsl:copy-of select="n:map('postalCode', n:ePatient.09, true())"/>
              <xsl:copy-of select="n:map('country', n:ePatient.10, true())"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:attribute name="nullFlavor">NI</xsl:attribute>
            </xsl:otherwise>
          </xsl:choose>
        </addr>
        <xsl:choose>
          <xsl:when test="n:ePatient.18 or n:ePatient.19">
            <xsl:for-each select="(n:ePatient.18, n:ePatient.19)">
              <xsl:copy-of select="n:map('telecom', ., false())"/>
            </xsl:for-each>
          </xsl:when>
          <xsl:otherwise>
            <telecom nullFlavor="NI"/>
          </xsl:otherwise>
        </xsl:choose>
        <patient>
          <name>
            <xsl:choose>
              <xsl:when test="n:ePatient.PatientNameGroup/*">
                <xsl:copy-of select="n:map('given', n:ePatient.PatientNameGroup/n:ePatient.03, true())"/>
                <xsl:copy-of select="n:map('given', n:ePatient.PatientNameGroup/n:ePatient.04, false())"/>
                <xsl:copy-of select="n:map('family', n:ePatient.PatientNameGroup/n:ePatient.02, true())"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:attribute name="nullFlavor">NI</xsl:attribute>
              </xsl:otherwise>
            </xsl:choose>
          </name>
          <xsl:copy-of select="n:map('administrativeGenderCode', n:ePatient.13, true())"/>
          <xsl:copy-of select="n:map('birthTime', n:ePatient.17, true())"/>
          <!-- maritalStatusCode not supported in NEMSIS -->
          <maritalStatusCode nullFlavor="NI"/>
          <!-- raceCode: Select first instance of ePatient.14 (except "Hispanic or Latino", which 
               maps to ethnicGroupCode in HL7). -->
          <xsl:copy-of select="n:map('raceCode', n:ePatient.14[. != '2514007'][1], true())"/>
          <xsl:for-each select="n:ePatient.14[. != '2514007'][position() != 1]">
            <xsl:copy-of select="n:map('sdtc:raceCode', ., false())"/>
          </xsl:for-each>
          <!-- ethnicGroupCode: If "Hispanic or Latino" is recorded, use that. If at least one 
               value is recorded but not "Hispanic or Latino", assume "Not Hispanic or Latino". 
               Otherwise, assume "No Information". -->
          <xsl:choose>
            <xsl:when test="n:ePatient.14 = '2514007'">
              <ethnicGroupCode codeSystem="2.16.840.1.113883.6.238" code="2135-2" displayName="Hispanic or Latino"/>
            </xsl:when>
            <xsl:when test="n:ePatient.14[. != '']">
              <ethnicGroupCode codeSystem="2.16.840.1.113883.6.238" code="2186-5" displayName="Not Hispanic or Latino"/>
            </xsl:when>
            <xsl:otherwise>
              <ethnicGroupCode nullFlavor="NI"/>
            </xsl:otherwise>
          </xsl:choose>
          <!-- languageCommunication not supported in NEMSIS -->
          <languageCommunication>
            <languageCode nullFlavor="NI"/>
            <proficiencyLevelCode nullFlavor="NI"/>
            <preferenceInd nullFlavor="NI"/>
          </languageCommunication>
        </patient>
      </patientRole>
    </recordTarget>
  </xsl:template>

  <!-- Author (person) -->
  <xsl:template match="hl7:author" mode="authorPerson">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <time value="{$currentDateTime}"/>
      <assignedAuthor>
        <xsl:copy-of select="hl7:assignedAuthor/@*"/>
        <xsl:apply-templates select="hl7:assignedAuthor/*[local-name() != 'assignedAuthoringDevice']" mode="config"/>
      </assignedAuthor>
    </xsl:copy>
  </xsl:template>

  <!-- Author (software) -->
  <xsl:template match="hl7:author" mode="authorSoftware">
    <xsl:param name="pcr"/>
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <time value="{$currentDateTime}"/>
      <assignedAuthor>
        <xsl:copy-of select="hl7:assignedAuthor/@*"/>
        <xsl:apply-templates select="hl7:assignedAuthor/hl7:assignedPerson/preceding-sibling::*" mode="config"/>
        <!-- If authoringDevice is not provided in the config, information from author in the 
             config is used along with eRecord.SoftwareApplicationGroup in the NEMSIS document for 
             authoringDevice. -->
       <xsl:choose>
          <xsl:when test="hl7:assignedAuthor/hl7:assignedAuthoringDevice">
            <xsl:copy-of select="hl7:assignedAuthor/hl7:assignedAuthoringDevice"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="$pcr/n:eRecord/n:eRecord.SoftwareApplicationGroup"/>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="hl7:assignedAuthor/hl7:assignedPerson/following-sibling::*" mode="config"/>
      </assignedAuthor>
    </xsl:copy>
  </xsl:template>

  <!-- Software -->
  <xsl:template match="n:eRecord.SoftwareApplicationGroup">
    <assignedAuthoringDevice>
      <xsl:copy-of select="n:map('manufacturerModelName', n:eRecord.02, true())"/>
      <xsl:copy-of select="n:map('softwareName', n:eRecord.03, true())"/>
    </assignedAuthoringDevice>
  </xsl:template>

  <!-- Service Event -->
  <xsl:template match="n:PatientCareReport" mode="serviceEvent">
    <documentationOf>
      <serviceEvent classCode="PCPR" moodCode="EVN">
        <xsl:apply-templates select="n:eTimes"/>
      </serviceEvent>
    </documentationOf>
  </xsl:template>

  <!-- Encompassing Encounter -->
  <xsl:template match="n:PatientCareReport" mode="encompassingEncounter">
    <componentOf>
      <encompassingEncounter classCode="ENC" moodCode="EVN">
        <id>
          <xsl:copy-of select="n:id(n:eRecord/n:eRecord.01)"/>
        </id>
        <!-- code: Even if the EMS incident location type was the patient's home or a healthcare 
            facility, this transformation assumes that the patient was transported, so at least 
            part, if not all, of the EMS encounter was in the field. -->
        <code codeSystem="2.16.840.1.113883.1.11.13955" code="FLD" displayName="field"/>
        <xsl:apply-templates select="n:eTimes"/>
      </encompassingEncounter>
    </componentOf>
  </xsl:template>

  <!-- effectiveTime of Service Event and Encompassing Encounter -->
  <xsl:template match="n:eTimes">
    <effectiveTime xsi:type="IVL_TS">
      <low>
        <!-- Use the first non-empty date/time element in this ordered list -->
        <xsl:apply-templates select="(n:eTimes.07, n:eTimes.06, n:eTimes.05, n:eTimes.04, n:eTimes.03)[. != ''][1]"/>
      </low>
      <high>
        <!-- Use the first non-empty date/time element in this ordered list -->
        <xsl:apply-templates select="(n:eTimes.12, n:eTimes.11, n:eTimes.10, n:eTimes.08, n:eTimes.13)[. != ''][1]"/>
      </high>
    </effectiveTime>
  </xsl:template>

  <!-- NonXMLBody -->
  <xsl:template match="n:PatientCareReport" mode="nonXMLBody">
    <component>
      <nonXMLBody>
        <xsl:choose>
          <xsl:when test="not(n:eOther/n:eOther.FileGroup[n:eOther.09 = '4509027' and n:eOther.11[. != '']])">
            <xsl:comment>
              The source document does not include an unstructured version of the PCR. This 
              transformation requires that the NEMSIS PatientCareReport contains 
              eOther/eOther.FileGroup where eOther.09 External Electronic Document Type is 4509027 
              ("ePCR") and eOther.11 File Attachment Image is a viewable rendering of the PCR.
            </xsl:comment>
          </xsl:when>
          <xsl:when test="not(n:eOther/n:eOther.FileGroup[n:eOther.09 = '4509027'][1]/n:eOther.10)">
            <xsl:comment>
              The source document does not specify the media type of the unstructured version of the 
              PCR, so receiving systems may not be able to render the unstructured PCR data. The 
              media type should be recorded in eOther.10 File Attachment Type.
            </xsl:comment>
          </xsl:when>
          <xsl:when test="not(n:eOther/n:eOther.FileGroup[n:eOther.09 = '4509027'][1]/n:eOther.10 = $mediaType/*/@hl7)">
            <xsl:comment>
              The source document specifies a media type in eOther.10 File Attachment Type for 
              the unstructured version of the PCR that is not on the HL7 mediaType list (see 
              https://vsac.nlm.nih.gov/valueset/2.16.840.1.113883.11.20.7.1/expansion/Latest), so 
              receiving systems may not be able to render the unstructured PCR data.
            </xsl:comment>
          </xsl:when>
        </xsl:choose>
        <xsl:copy-of select="key('code', n:eOther/n:eOther.FileGroup[n:eOther.09 = '4509027'][1]/n:eOther.10, $mediaType)/@hl7"/>
        <xsl:copy-of select="n:map('text', n:eOther/n:eOther.FileGroup[n:eOther.09 = '4509027'][1], true())"/>
      </nonXMLBody>
    </component>
  </xsl:template>

  <!-- NonXMLBody/text -->
  <xsl:template match="n:eOther.FileGroup">
    <xsl:attribute name="mediaType" select="n:eOther.10"/>
    <xsl:attribute name="representation">B64</xsl:attribute>
    <xsl:value-of select="n:eOther.11"/>
  </xsl:template>


  <!-- #Elements# -->

  <!-- Default: copy content -->
  <xsl:template match="node() | @*">
    <xsl:value-of select="."/>
  </xsl:template>

  <!-- content from config: copy everything except comment nodes  -->
  <xsl:template match="node() | @*" mode="config">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*" mode="config"/>
    </xsl:copy>
  </xsl:template>

  <!-- comment nodes in config: don't copy -->
  <xsl:template match="comment()" mode="config" priority="1"/>

  <!-- Date/time elements -->
  <xsl:template match="n:eTimes/*">
    <xsl:attribute name="value" select="n:dateTime(.)"/>
  </xsl:template>

  <!-- Agency Name as Assigning Authority Name for ID elements -->
  <xsl:template match="n:eResponse.03">
    <xsl:attribute name="assigningAuthorityName" select="."/>
  </xsl:template>

  <!-- Patient ID -->
  <xsl:template match="n:ePatient.01">
    <xsl:copy-of select="n:id(.)"/>
    <xsl:apply-templates select="../n:eResponse/n:eResponse.AgencyGroup/n:eResponse.03[. != '']"/>
  </xsl:template>

  <!-- City -->
  <xsl:template match="n:ePatient.06">
    <xsl:value-of select="n:gnis(.)"/>
  </xsl:template>

  <!-- State -->
  <xsl:template match="n:ePatient.08">
    <xsl:value-of select="key('code', ., $state)/@hl7"/>
  </xsl:template>

  <!-- SSN -->
  <!-- SSNs are formatted without delimiters between SSN segments in NEMSIS. This transformation 
       does not add delimiters. -->
  <xsl:template match="n:ePatient.12">
    <xsl:attribute name="assigningAuthorityName">US Social Security Administration</xsl:attribute>
    <xsl:attribute name="root">2.16.840.1.113883.4.1</xsl:attribute>
    <xsl:if test=". != ''">
      <xsl:attribute name="extension" select="."/>
    </xsl:if>
  </xsl:template>

  <!-- Driver's License -->
  <xsl:template match="n:ePatient.21">
    <!-- Attempt to look up state OID, fall back to US Driver License Number OID. The NEMSIS state 
         ANSI code (without leading "0") is the 8th segment of the OID; see 
         http://oid-info.com/get//2.16.840.1.113883.4.3. -->
    <xsl:variable name="oid" select="string-join(('2.16.840.1.113883.4.3', if (../n:ePatient.20) then number(../n:ePatient.20) else ''), '.')"/>
    <xsl:variable name="oidLookup" select="($stateIssuingDriverLicense/hl7:code[@root = $oid], $stateIssuingDriverLicense/hl7:code[@root = '2.16.840.1.113883.4.3'])[1]"/>
    <xsl:attribute name="assigningAuthorityName" select="$oidLookup/@assigningAuthorityName"/>
    <xsl:attribute name="root" select="$oidLookup/@root"/>
    <xsl:attribute name="extension" select="."/>
  </xsl:template>

  <!-- Gender -->
  <xsl:template match="n:ePatient.13">
    <xsl:attribute name="codeSystem">2.16.840.1.113883.5.1</xsl:attribute>
    <xsl:attribute name="code" select="key('code', ., $gender)/@hl7"/>
    <xsl:attribute name="displayName" select="key('code', ., $gender)/@hl7Desc"/>
  </xsl:template>

  <!-- Race -->
  <xsl:template match="n:ePatient.14">
    <xsl:attribute name="codeSystem">2.16.840.1.113883.6.238</xsl:attribute>
    <xsl:attribute name="code" select="key('code', ., $race)/@hl7"/>
    <xsl:attribute name="displayName" select="key('code', ., $race)/@hl7Desc"/>
  </xsl:template>

  <!-- Birthdate -->
  <xsl:template match="n:ePatient.17">
    <xsl:attribute name="value" select="n:date(.)"/>
  </xsl:template>

  <!-- Phone Number -->
  <xsl:template match="n:ePatient.18">
    <xsl:apply-templates select="@PhoneNumberType"/>
    <xsl:attribute name="value" select="concat('tel:', .)"/>
  </xsl:template>

  <!-- Phone Number: Fax -->
  <xsl:template match="n:ePatient.18[@PhoneNumberType = '9913001']">
    <xsl:attribute name="value" select="concat('fax:', .)"/>
  </xsl:template>

  <!-- Phone Number Type/Use -->
   <xsl:template match="@PhoneNumberType">
    <xsl:attribute name="use" select="key('code', ., $phoneNumberType)/@hl7"/>
   </xsl:template>

  <!-- Email Address -->
  <xsl:template match="n:ePatient.19">
    <xsl:apply-templates select="@EmailAddressType"/>
    <xsl:attribute name="value" select="concat('mailto:', .)"/>
  </xsl:template>

  <!-- Email Address Type/Use -->
  <xsl:template match="@EmailAddressType">
    <xsl:attribute name="use" select="key('code', ., $emailAddressType)/@hl7"/>
   </xsl:template>


  <!-- #Functions# -->

  <xsl:function name="n:map">
    <xsl:param name="hl7ElementName" required="yes" as="xs:string"/>
    <xsl:param name="nemsisElement"/>
    <xsl:param name="hl7Required" as="xs:boolean"/>
    <xsl:variable name="result">
      <result>
        <xsl:apply-templates select="$nemsisElement"/>
      </result>
    </xsl:variable>
    <xsl:if test="$nemsisElement/(@NV or @PN) or $result/hl7:result/(descendant-or-self::node() | @*)[. != ''] or $hl7Required">
      <xsl:element name="{$hl7ElementName}">
        <xsl:choose>
          <!-- Not Applicable -> not applicable -->
          <xsl:when test="$nemsisElement/@NV = '7701001'">
            <xsl:attribute name="nullFlavor">NA</xsl:attribute>
          </xsl:when>
          <!-- Not Reporting -> masked -->
          <xsl:when test="$nemsisElement/@NV = '7701005'">
            <xsl:attribute name="nullFlavor">MSK</xsl:attribute>
          </xsl:when>
          <!-- Refused, Unable to Complete -> asked but unknown -->
          <xsl:when test="$nemsisElement/@PN = ('8801019', '8801023')">
            <xsl:attribute name="nullFlavor">ASKU</xsl:attribute>
          </xsl:when>
          <!-- all other null data -> NoInformation -->
          <xsl:when test="not($nemsisElement != '') or not($result/hl7:result/(descendant-or-self::node() | @*)[. != ''])">
            <xsl:attribute name="nullFlavor">NI</xsl:attribute>
          </xsl:when>
          <xsl:otherwise>
            <xsl:copy-of select="$result/hl7:result/(node() | @*)"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:element>      
    </xsl:if>
  </xsl:function>

  <!-- If the agency has an OID, use the @root/@extension format; otherwise the ID goes in @root. -->
  <xsl:function name="n:id">
    <xsl:param name="id"/>
    <xsl:choose>
      <xsl:when test="$config/hl7:oid/@root[. != '']">
        <xsl:copy-of select="$config/hl7:oid/@root"/>
        <xsl:attribute name="extension" select="$id"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:attribute name="root" select="$id"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xsl:function name="n:date">
    <xsl:param name="nemsisDate"/>
    <xsl:if test="$nemsisDate[. != '']">
      <xsl:value-of select="format-date(xs:date($nemsisDate), '[Y0001][M01][D01]')"/>
    </xsl:if>
  </xsl:function>

  <xsl:function name="n:dateTime">
    <xsl:param name="nemsisDateTime"/>
    <xsl:if test="$nemsisDateTime[. != '']">
      <xsl:value-of select="translate(format-dateTime(xs:dateTime($nemsisDateTime), '[Y0001][M01][D01][h01][m01][s01][Z]'), ':', '')"/>
    </xsl:if>
  </xsl:function>


  <!-- #Mapping Variables# -->

  <!-- Gender -->
  <!-- HL7 administrativeGenderCode, value set 2.16.840.1.113883.1.11.1 -->
  <xsl:variable name="gender">
    <code hl7="F" nemsis="9906001" hl7Desc="Female" nemsisDesc="Female"/>
    <code hl7="M" nemsis="9906003" hl7Desc="Male" nemsisDesc="Male"/>
    <code hl7="UN" nemsis="9906005" hl7Desc="Undifferentiated" nemsisDesc="Unknown (Unable to Determine)"/>
    <code hl7="UN" nemsis="9906007" hl7Desc="Undifferentiated" nemsisDesc="Female-to-Male, Transgender Male"/>
    <code hl7="UN" nemsis="9906009" hl7Desc="Undifferentiated" nemsisDesc="Male-to-Female, Transgender Female"/>
    <code hl7="UN" nemsis="9906011" hl7Desc="Undifferentiated" nemsisDesc="Other, neither exclusively male or female"/>
  </xsl:variable>

  <!-- Race -->
  <!-- HL7 raceCode, value set 2.16.840.1.113883.1.11.1 -->
  <xsl:variable name="race">
    <code hl7="1002-5" nemsis="2514001" hl7Desc="American Indian or Alaska Native" nemsisDesc="American Indian or Alaska Native"/>
    <code hl7="2028-9" nemsis="2514003" hl7Desc="Asian" nemsisDesc="Asian"/>
    <code hl7="2054-5" nemsis="2514005" hl7Desc="Black or African American" nemsisDesc="Black or African American"/>
    <code hl7="2076-8" nemsis="2514009" hl7Desc="Native Hawaiian or Other Pacific Islander" nemsisDesc="Native Hawaiian or Other Pacific Islander"/>
    <code hl7="2106-3" nemsis="2514011" hl7Desc="White" nemsisDesc="White"/>
  </xsl:variable>

  <!-- Phone Number Type -->
  <!-- HL7 Telecom Use, value set 2.16.840.1.113883.11.20.9.20 -->
  <xsl:variable name="phoneNumberType">
    <!-- NEMSIS PhoneNumberType 9913001 ("Fax") is a telecom with the "fax:" protocol in HL7 -->
    <code hl7="HP" nemsis="9913003" hl7Desc="primary home" nemsisDesc="Home"/>
    <code hl7="MC" nemsis="9913005" hl7Desc="mobile contact)" nemsisDesc="Mobile"/>
    <code hl7="PG" nemsis="9913007" hl7Desc="pager" nemsisDesc="Pager"/>
    <code hl7="WP" nemsis="9913009" hl7Desc="work place" nemsisDesc="Work"/>
  </xsl:variable>

  <!-- Email Address Type -->
  <!-- HL7 Telecom Use, value set 2.16.840.1.113883.11.20.9.20 -->
  <xsl:variable name="emailAddressType">
    <code hl7="HP" nemsis="9904001" hl7Desc="primary home" nemsisDesc="Personal"/>
    <code hl7="WP" nemsis="9904003" hl7Desc="work place" nemsisDesc="Work"/>
  </xsl:variable>

  <!-- State -->
  <xsl:variable name="state">
    <code hl7="AL" nemsis="01" desc="Alabama"/>
    <code hl7="AK" nemsis="02" desc="Alaska"/>
    <code hl7="AZ" nemsis="04" desc="Arizona"/>
    <code hl7="AR" nemsis="05" desc="Arkansas"/>
    <code hl7="CA" nemsis="06" desc="California"/>
    <code hl7="CO" nemsis="08" desc="Colorado"/>
    <code hl7="CT" nemsis="09" desc="Connecticut"/>
    <code hl7="DE" nemsis="10" desc="Delaware"/>
    <code hl7="DC" nemsis="11" desc="District of Columbia"/>
    <code hl7="FL" nemsis="12" desc="Florida"/>
    <code hl7="GA" nemsis="13" desc="Georgia"/>
    <code hl7="HI" nemsis="15" desc="Hawaii"/>
    <code hl7="ID" nemsis="16" desc="Idaho"/>
    <code hl7="IL" nemsis="17" desc="Illinois"/>
    <code hl7="IN" nemsis="18" desc="Indiana"/>
    <code hl7="IA" nemsis="19" desc="Iowa"/>
    <code hl7="KS" nemsis="20" desc="Kansas"/>
    <code hl7="KY" nemsis="21" desc="Kentucky"/>
    <code hl7="LA" nemsis="22" desc="Louisiana"/>
    <code hl7="ME" nemsis="23" desc="Maine"/>
    <code hl7="MD" nemsis="24" desc="Maryland"/>
    <code hl7="MA" nemsis="25" desc="Massachusetts"/>
    <code hl7="MI" nemsis="26" desc="Michigan"/>
    <code hl7="MN" nemsis="27" desc="Minnesota"/>
    <code hl7="MS" nemsis="28" desc="Mississippi"/>
    <code hl7="MO" nemsis="29" desc="Missouri"/>
    <code hl7="MT" nemsis="30" desc="Montana"/>
    <code hl7="NE" nemsis="31" desc="Nebraska"/>
    <code hl7="NV" nemsis="32" desc="Nevada"/>
    <code hl7="NH" nemsis="33" desc="New Hampshire"/>
    <code hl7="NJ" nemsis="34" desc="New Jersey"/>
    <code hl7="NM" nemsis="35" desc="New Mexico"/>
    <code hl7="NY" nemsis="36" desc="New York"/>
    <code hl7="NC" nemsis="37" desc="North Carolina"/>
    <code hl7="ND" nemsis="38" desc="North Dakota"/>
    <code hl7="OH" nemsis="39" desc="Ohio"/>
    <code hl7="OK" nemsis="40" desc="Oklahoma"/>
    <code hl7="OR" nemsis="41" desc="Oregon"/>
    <code hl7="PA" nemsis="42" desc="Pennsylvania"/>
    <code hl7="RI" nemsis="44" desc="Rhode Island"/>
    <code hl7="SC" nemsis="45" desc="South Carolina"/>
    <code hl7="SD" nemsis="46" desc="South Dakota"/>
    <code hl7="TN" nemsis="47" desc="Tennessee"/>
    <code hl7="TX" nemsis="48" desc="Texas"/>
    <code hl7="UT" nemsis="49" desc="Utah"/>
    <code hl7="VT" nemsis="50" desc="Vermont"/>
    <code hl7="VA" nemsis="51" desc="Virginia"/>
    <code hl7="WA" nemsis="53" desc="Washington"/>
    <code hl7="WV" nemsis="54" desc="West Virginia"/>
    <code hl7="WI" nemsis="55" desc="Wisconsin"/>
    <code hl7="WY" nemsis="56" desc="Wyoming"/>
    <code hl7="AS" nemsis="60" desc="American Samoa"/>
    <code hl7="FM" nemsis="64" desc="Federated codes of Micronesia"/>
    <code hl7="GU" nemsis="66" desc="Guam"/>
    <code hl7="MH" nemsis="68" desc="Marshall Islands"/>
    <code hl7="MP" nemsis="69" desc="Northern Mariana Islands"/>
    <code hl7="PW" nemsis="70" desc="Palau"/>
    <code hl7="PR" nemsis="72" desc="Puerto Rico"/>
    <code hl7="UM" nemsis="74" desc="US Minor Outlying Islands"/>
    <code hl7="VI" nemsis="78" desc="US Virgin Islands"/>
  </xsl:variable>

  <!-- State Issuing Driver's License -->
  <xsl:variable name="stateIssuingDriverLicense">
    <code root="2.16.840.1.113883.4.3" assigningAuthorityName="United States Driver License Number"/>
    <code root="2.16.840.1.113883.4.3.1" assigningAuthorityName="Alabama Driver's License"/>
    <code root="2.16.840.1.113883.4.3.2" assigningAuthorityName="Alaska Driver's License"/>
    <code root="2.16.840.1.113883.4.3.4" assigningAuthorityName="Arizona Driver's License"/>
    <code root="2.16.840.1.113883.4.3.5" assigningAuthorityName="Arkansas Driver's License"/>
    <code root="2.16.840.1.113883.4.3.6" assigningAuthorityName="California Driver's License"/>
    <code root="2.16.840.1.113883.4.3.8" assigningAuthorityName="Colorado Driver's License"/>
    <code root="2.16.840.1.113883.4.3.9" assigningAuthorityName="Connecticut Driver's License"/>
    <code root="2.16.840.1.113883.4.3.10" assigningAuthorityName="Delaware Driver's License"/>
    <code root="2.16.840.1.113883.4.3.11" assigningAuthorityName="DC Driver's License"/>
    <code root="2.16.840.1.113883.4.3.12" assigningAuthorityName="Florida Driver's License"/>
    <code root="2.16.840.1.113883.4.3.13" assigningAuthorityName="Georgia Driver's License"/>
    <code root="2.16.840.1.113883.4.3.15" assigningAuthorityName="Hawaii Driver's License"/>
    <code root="2.16.840.1.113883.4.3.16" assigningAuthorityName="Idaho Driver's License"/>
    <code root="2.16.840.1.113883.4.3.17" assigningAuthorityName="Illinois Driver's License"/>
    <code root="2.16.840.1.113883.4.3.18" assigningAuthorityName="Indiana Driver's License"/>
    <code root="2.16.840.1.113883.4.3.19" assigningAuthorityName="Iowa Driver's License"/>
    <code root="2.16.840.1.113883.4.3.20" assigningAuthorityName="Kansas Driver's License"/>
    <code root="2.16.840.1.113883.4.3.21" assigningAuthorityName="Kentucky Driver's License"/>
    <code root="2.16.840.1.113883.4.3.22" assigningAuthorityName="Louisiana Driver's License"/>
    <code root="2.16.840.1.113883.4.3.23" assigningAuthorityName="Maine Driver's License"/>
    <code root="2.16.840.1.113883.4.3.24" assigningAuthorityName="Maryland Driver's License"/>
    <code root="2.16.840.1.113883.4.3.25" assigningAuthorityName="Massachusetts Driver's License"/>
    <code root="2.16.840.1.113883.4.3.26" assigningAuthorityName="Michigan Driver's License"/>
    <code root="2.16.840.1.113883.4.3.27" assigningAuthorityName="Minnesota Driver's License"/>
    <code root="2.16.840.1.113883.4.3.28" assigningAuthorityName="Mississippi Driver's License"/>
    <code root="2.16.840.1.113883.4.3.29" assigningAuthorityName="Missouri Driver's License"/>
    <code root="2.16.840.1.113883.4.3.30" assigningAuthorityName="Montana Driver's License"/>
    <code root="2.16.840.1.113883.4.3.31" assigningAuthorityName="Nebraska Driver's License"/>
    <code root="2.16.840.1.113883.4.3.32" assigningAuthorityName="Nevada Driver's License"/>
    <code root="2.16.840.1.113883.4.3.33" assigningAuthorityName="New Hampshire Driver's License"/>
    <code root="2.16.840.1.113883.4.3.34" assigningAuthorityName="New Jersey Driver's License"/>
    <code root="2.16.840.1.113883.4.3.35" assigningAuthorityName="New Mexico Driver's License"/>
    <code root="2.16.840.1.113883.4.3.36" assigningAuthorityName="New York Driver's License"/>
    <code root="2.16.840.1.113883.4.3.37" assigningAuthorityName="North Carolina Driver's License"/>
    <code root="2.16.840.1.113883.4.3.38" assigningAuthorityName="North Dakota Driver's License"/>
    <code root="2.16.840.1.113883.4.3.39" assigningAuthorityName="Ohio Driver's License"/>
    <code root="2.16.840.1.113883.4.3.40" assigningAuthorityName="Oklahoma Driver's License"/>
    <code root="2.16.840.1.113883.4.3.41" assigningAuthorityName="Oregon Driver's License"/>
    <code root="2.16.840.1.113883.4.3.42" assigningAuthorityName="Pennsylvania Driver's License"/>
    <code root="2.16.840.1.113883.4.3.44" assigningAuthorityName="Rhode Island Driver's License"/>
    <code root="2.16.840.1.113883.4.3.45" assigningAuthorityName="South Carolina Driver's License"/>
    <code root="2.16.840.1.113883.4.3.46" assigningAuthorityName="South Dakota Driver's License"/>
    <code root="2.16.840.1.113883.4.3.47" assigningAuthorityName="Tennessee Driver's License"/>
    <code root="2.16.840.1.113883.4.3.48" assigningAuthorityName="Texas Driver's License"/>
    <code root="2.16.840.1.113883.4.3.49" assigningAuthorityName="Utah Driver's License"/>
    <code root="2.16.840.1.113883.4.3.50" assigningAuthorityName="Vermont Driver's License"/>
    <code root="2.16.840.1.113883.4.3.51" assigningAuthorityName="Virginia Driver's License"/>
    <code root="2.16.840.1.113883.4.3.53" assigningAuthorityName="Washington Driver's License"/>
    <code root="2.16.840.1.113883.4.3.54" assigningAuthorityName="West Virginia Driver's License"/>
    <code root="2.16.840.1.113883.4.3.55" assigningAuthorityName="Wisconsin Driver's License"/>
    <code root="2.16.840.1.113883.4.3.56" assigningAuthorityName="Wyoming Driver's License"/>
  </xsl:variable>

  <xsl:variable name="mediaType">
    <code hl7="application/msword" hl7Desc="MSWORD"/>
    <code hl7="application/pdf" hl7Desc="PDF"/>
    <code hl7="audio" hl7Desc="AudioMediaType"/>
    <code hl7="audio/basic" hl7Desc="Basic Audio"/>
    <code hl7="audio/k32adpcm" hl7Desc="K32ADPCM Audio"/>
    <code hl7="audio/mpeg" hl7Desc="MPEG audio layer 3"/>
    <code hl7="image/gif" hl7Desc="GIF Image"/>
    <code hl7="image/jpeg" hl7Desc="JPEG Image"/>
    <code hl7="image/png" hl7Desc="PNG Image"/>
    <code hl7="image/tiff" hl7Desc="TIFF Image"/>
    <code hl7="text/html" hl7Desc="HTML Text"/>
    <code hl7="text/plain" hl7Desc="Plain Text"/>
    <code hl7="text/rtf" hl7Desc="RTF Text"/>
    <code hl7="video" hl7Desc="VideoMediaType"/>
    <code hl7="video/mp4" hl7Desc="MP4 Video"/>
    <code hl7="video/mpeg" hl7Desc="MPEG Video"/>
    <code hl7="video/quicktime" hl7Desc="QuickTime Video"/>
    <code hl7="video/webm" hl7Desc="WebM Video"/>
    <code hl7="video/x-avi" hl7Desc="X-AVI Video"/>
    <code hl7="video/x-ms-wmv" hl7Desc="Windows Media Video"/>
  </xsl:variable>

</xsl:stylesheet>