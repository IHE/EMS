<?xml version="1.0" encoding="UTF-8"?>

<!--

XML Stylesheet Language Transformation (XSLT) to transform from HL7 C-CDA v2.1 Discharge Summary 
to NEMSIS EMSDataSet v3.5.0

This product is provided by the NEMSIS TAC, without charge, to facilitate a data mapping between 
HL7 C-CDA and NEMSIS v3.5.0. This stylesheet transforms a Clinical Document from a hospital,
provided in HL7 C-CDA 2.1 format, into a partial NEMSIS v3.5.0 EMSDataSet XML document containing 
an eOutcome data section representing the information from the hospital's care of the patient.

The document to be transformed may represent a hospital emergency department or inpatient encounter.

Version: 2.1.2022Sep_3.5.0.230317CP4_240627
Revision Date: June 27, 2024

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

  <xsl:output method="xml" encoding="UTF-8" indent="yes"/>

  <xsl:key name="code" match="*" use="@hl7"/>


  <!-- #Terminology Function# -->

  <!-- If you have access to a terminology mapping service, edit this function to implement API calls. -->
  <xsl:function name="n:terminology">
    <!-- An HL7 C-CDA "code" or "value" element -->
    <xsl:param name="code" required="yes"/>
    <!-- The OID of the requested code system to map to -->
    <xsl:param name="codeSystem" required="yes" as="xs:string"/>
    <!-- Implement terminology service API call here. It should return a string value. -->
  </xsl:function>


  <!-- Variable to select encounter type -->
  <!-- This transformation expects emergency department encounters to have the value "EMER". Any 
       other value is treated as an inpatient encounter. -->
  <xsl:variable name="encounterType" select="/hl7:ClinicalDocument/hl7:componentOf/hl7:encompassingEncounter/hl7:code/@code"/>


  <!-- #Root Template# -->

  <xsl:template match="/">
    <xsl:comment>
     This partial NEMSIS 3.5.0 document was generated from an HL7 C-CDA 2.1 Discharge Summary document 
     via an XML Stylesheet Language Transformation (XSLT). It is not valid per the NEMSIS 3.5.0 XSD. 
     Its purpose is to convey hospital patient care information in the NEMSIS eOutcome section.
    </xsl:comment>
    <xsl:text>&#10;</xsl:text>
    <xsl:if test="not(/hl7:ClinicalDocument/hl7:templateId/@root = '2.16.840.1.113883.10.20.22.1.8')">
      <xsl:comment>
        Warning: The source document does not appear to be an HL7 C-CDA 2.1 Discharge Summary. 
        Results may be incomplete or incorrect.
      </xsl:comment>
    </xsl:if>
    <xsl:copy>
      <xsl:apply-templates select="hl7:ClinicalDocument"/>
    </xsl:copy>
  </xsl:template>


  <!-- #Document# -->

  <xsl:template match="/hl7:ClinicalDocument">
    <EMSDataSet xmlns="http://www.nemsis.org" xsi:schemaLocation="http://www.nemsis.org http://www.nemsis.org/media/nemsis_v3/release-3.5.0/XSDs/NEMSIS_XSDs/EMSDataSet_v3.xsd">
      <Header>
        <PatientCareReport>
          <!-- patientRole > ePatient -->
          <xsl:apply-templates select="hl7:recordTarget[1]/hl7:patientRole"/>
          <!-- encompassingEncounter > eOutcome -->
          <xsl:apply-templates select="hl7:componentOf/hl7:encompassingEncounter"/>
        </PatientCareReport>
      </Header>
    </EMSDataSet>
  </xsl:template>


  <!-- #Sections# -->

  <!-- Patient -->

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
      <xsl:apply-templates select="hl7:patient/hl7:ethnicityCode"/>
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

  <!-- Outcome -->
  <!-- This generates a complete NEMSIS eOutcome section, filling in "Not Values" where data are 
       not available in the C-CDA document. -->
  <xsl:template match="hl7:encompassingEncounter">

    <!-- Variable to select procedures -->
    <xsl:variable name="procedures" select="/hl7:ClinicalDocument/hl7:component/hl7:structuredBody/hl7:component/hl7:section[hl7:templateId[starts-with(@root, '2.16.840.1.113883.10.20.22.2.7')]]/hl7:entry/*[not(@negationInd = 'true')]"/>
    
    <!-- Variable to select diagnoses (admission diagnoses, discharge diagnoses, and problems) -->
    <!-- If a diagnosis has a documented effectiveTime/low that is more than one day prior to 
         the date of effectiveTime/low of the encompassingEncounter, exclude it. -->
    <xsl:variable name="diagnoses" select="/hl7:ClinicalDocument/hl7:component/hl7:structuredBody/hl7:component/hl7:section[hl7:templateId/@root=('2.16.840.1.113883.10.20.22.2.43', '2.16.840.1.113883.10.20.22.2.24', '2.16.840.1.113883.10.20.22.2.5')]/hl7:entry/hl7:act/hl7:entryRelationship/hl7:observation[not(@negationInd = 'true') and hl7:effectiveTime/hl7:low/xs:date(n:date(@value)) >= current()/hl7:effectiveTime/hl7:low/xs:date(n:date(@value)) - xs:dayTimeDuration('P1D')]"/>
    
    <eOutcome>
      <!-- Dispositions: HL7 recommends using NUBC UB-04 FL17 Patient Status 
           (2.16.840.1.113883.3.88.12.80.33) but also allows other code sets, such as Discharge 
           Disposition (HL7) (2.16.840.1.113883.12.112). NEMSIS supports a subset of those code 
           sets. Map the code if it is supported by NEMSIS. This translation could be improved by 
           mapping non-NEMSIS-supported codes to NEMSIS-supported codes. For example, all codes in 
           the 30s could be mapped to "30", since they represent variations of "Still a Patient". -->
      <!-- ED Disposition -->
      <xsl:copy-of select="n:map('eOutcome.01', hl7:dischargeDispositionCode[$encounterType = 'EMER'], true())"/>
      <!-- Hospital Disposition -->
      <xsl:copy-of select="n:map('eOutcome.02', hl7:dischargeDispositionCode[not($encounterType = 'EMER')], true())"/>
      <!-- External Report ID: Encounter ID -->
      <!-- NEMSIS does not specify which of the several identifiers available in a C-CDA document 
           should be used for External Report ID/Number. This transformation uses 
           encompassingEncounter/id. Other options include:
           * ClinicalDocument/recordTarget/patientRole/id: Patient identifiers
           * ClinicalDocument/id: The clinical document instance identifier
           * ClinicalDocument/setId: The clinical document set identifier -->
      <xsl:apply-templates select="hl7:id[1]"/>
      <!-- ED Procedures -->
      <xsl:choose>
        <xsl:when test="$encounterType = 'EMER' and $procedures">
          <xsl:apply-templates select="$procedures">
            <xsl:with-param name="groupElement">eOutcome.EmergencyDepartmentProceduresGroup</xsl:with-param>
            <xsl:with-param name="procedureElement">eOutcome.09</xsl:with-param>
            <xsl:with-param name="dateTimeElement">eOutcome.19</xsl:with-param>
            </xsl:apply-templates>
        </xsl:when>
        <xsl:otherwise>
          <eOutcome.EmergencyDepartmentProceduresGroup>
            <eOutcome.09 xsi:nil="true" NV="7701003"/>
            <eOutcome.19 xsi:nil="true" NV="7701003"/>
          </eOutcome.EmergencyDepartmentProceduresGroup>
        </xsl:otherwise>
      </xsl:choose>
      <!-- ED Diagnoses -->
      <!-- This transformation de-duplicates diagnosis codes (if the same diagnosis code is 
           recorded more than once, it is only generated once in the output). -->
      <xsl:variable name="edDiagnoses">
        <xsl:copy-of select="n:map('eOutcome.10', $diagnoses[$encounterType = 'EMER'], true())"/>
      </xsl:variable>
      <xsl:copy-of select="$edDiagnoses/node()[not(. = preceding-sibling::*)]"/>
      <!-- Date/Time of Hospital Admission -->
      <xsl:copy-of select="n:map('eOutcome.11', hl7:effectiveTime/hl7:low[not($encounterType = 'EMER')], true())"/>
      <!-- Hospital Procedures -->
      <xsl:choose>
        <xsl:when test="not($encounterType = 'EMER') and $procedures">
          <xsl:apply-templates select="$procedures">
            <xsl:with-param name="groupElement">eOutcome.HospitalProceduresGroup</xsl:with-param>
            <xsl:with-param name="procedureElement">eOutcome.12</xsl:with-param>
            <xsl:with-param name="dateTimeElement">eOutcome.20</xsl:with-param>
            </xsl:apply-templates>
        </xsl:when>
        <xsl:otherwise>
          <eOutcome.HospitalProceduresGroup>
            <eOutcome.12 xsi:nil="true" NV="7701003"/>
            <eOutcome.20 xsi:nil="true" NV="7701003"/>
          </eOutcome.HospitalProceduresGroup>
        </xsl:otherwise>
      </xsl:choose>
      <!-- Hospital Diagnoses -->
      <!-- This transformation de-duplicates diagnosis codes (if the same diagnosis code is 
           recorded more than once, it is only generated once in the output). -->
      <xsl:variable name="hospitalDiagnoses">
        <xsl:copy-of select="n:map('eOutcome.13', $diagnoses[not($encounterType = 'EMER')], true())"/>
      </xsl:variable>
      <xsl:copy-of select="$hospitalDiagnoses/node()[not(. = preceding-sibling::*)]"/>
      <!-- Date/Time of Hospital Discharge -->
      <xsl:copy-of select="n:map('eOutcome.16', hl7:effectiveTime/hl7:high[not($encounterType = 'EMER')], true())"/>
      <!-- Date/Time of ED Admission -->
      <xsl:copy-of select="n:map('eOutcome.18', hl7:effectiveTime/hl7:low[$encounterType = 'EMER'], true())"/>
    </eOutcome>
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
    <xsl:variable name="digits" select="replace(@value, '(tel:)|(\+1)|([^\d])', '$2')"/>
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
    <!-- The 8th segment of the OID is the state ANSI code; see https://oidref.com/2.16.840.1.113883.4.3. -->
    <ePatient.20><xsl:number value="tokenize(@root, '.')[8]" format="01"/></ePatient.20>
    <ePatient.21><xsl:value-of select="@extension"/></ePatient.21>
  </xsl:template>

  <!-- Emergency Department Disposition -->
  <xsl:template match="hl7:dischargeDispositionCode[$encounterType = 'EMER'][matches(@code, '^(0?[1-79])|(2[01])|(30)|(43)|(5[01])|(6[1-6])|(70)$')]">
    <eOutcome.01><xsl:number value="@code" format="01"/></eOutcome.01>
  </xsl:template>

  <!-- Hospital Disposition -->
  <xsl:template match="hl7:dischargeDispositionCode[not($encounterType = 'EMER')][matches(@code, '^(0?[1-7])|(2[01])|(30)|(43)|(5[01])|(6[1-6])|(70)$')]">
    <eOutcome.02><xsl:number value="@code" format="01"/></eOutcome.02>
  </xsl:template>

  <!-- External Report ID -->
  <xsl:template match="hl7:id">
    <eOutcome.ExternalDataGroup>
      <!-- External Report ID/Number Type: Hospital-Receiving -->
      <eOutcome.03>4303005</eOutcome.03>
      <!-- External Report ID/Number -->
      <!-- Note: It may be desirable to include @root, in the format "{@root}^{@extension}", to
           generate an identifier that includes the Hospital's OID (to make it universally unique). -->
      <eOutcome.04><xsl:value-of select="@extension"/></eOutcome.04>
    </eOutcome.ExternalDataGroup>
  </xsl:template>

  <!-- Date/Time of Hospital Admission -->
  <xsl:template match="hl7:encompassingEncounter/hl7:effectiveTime/hl7:low[not($encounterType = 'EMER')]">
    <eOutcome.11><xsl:copy-of select="n:dateTime(@value)"/></eOutcome.11>
  </xsl:template>

  <!-- Date/Time of Emergency Department Admission -->
  <xsl:template match="hl7:encompassingEncounter/hl7:effectiveTime/hl7:low[$encounterType = 'EMER']">
    <eOutcome.18><xsl:copy-of select="n:dateTime(@value)"/></eOutcome.18>
  </xsl:template>

  <!-- Emergency Department or Hospital Procedure -->
  <!-- NEMSIS only supports ICD-10-PCS. If ICD-10-PCS code is not provided, a terminology service 
       may be used to translate to ICD-10-PCS. -->
  <xsl:template match="hl7:section[hl7:templateId[starts-with(@root, '2.16.840.1.113883.10.20.22.2.7')]]/hl7:entry/*[not(@negationInd = 'true')]">
    <xsl:param name="groupElement"/>
    <xsl:param name="procedureElement"/>
    <xsl:param name="dateTimeElement"/>
    <xsl:element name="{$groupElement}">
      <!-- ED/Hospital Procedure -->
      <xsl:copy-of select="n:mapTerminology($procedureElement, hl7:code, '2.16.840.1.113883.6.4')"/>
      <!-- Date/Time ED/Hospital Procedure Performed -->
      <!-- Select the date/time the procedure was performed (when single timestamp is provided) or 
           completed (high timestamp when low/high are provided). -->
      <xsl:element name="{$dateTimeElement}"><xsl:copy-of select="n:dateTime(hl7:effectiveTime/(@value, hl7:high/@value)[1])"/></xsl:element>
    </xsl:element>
  </xsl:template>

  <!-- ED Diagnosis -->
  <!-- NEMSIS only supports ICD-10-CM. If ICD-10-CM code is not provided, a terminology service 
       may be used to translate to ICD-10-CM. -->
  <xsl:template match="hl7:section[hl7:templateId/@root = ('2.16.840.1.113883.10.20.22.2.43', '2.16.840.1.113883.10.20.22.2.24', '2.16.840.1.113883.10.20.22.2.5')]/hl7:entry/hl7:act/hl7:entryRelationship/hl7:observation[$encounterType = 'EMER']">
    <xsl:copy-of select="n:mapTerminology('eOutcome.10', hl7:value, '2.16.840.1.113883.6.90')"/>
  </xsl:template>

  <!-- Hospital Diagnosis -->
  <!-- NEMSIS only supports ICD-10-CM. If ICD-10-CM code is not provided, a terminology service 
       may be used to translate to ICD-10-CM. -->
  <xsl:template match="hl7:section[hl7:templateId/@root = ('2.16.840.1.113883.10.20.22.2.43', '2.16.840.1.113883.10.20.22.2.24', '2.16.840.1.113883.10.20.22.2.5')]/hl7:entry/hl7:act/hl7:entryRelationship/hl7:observation[not($encounterType = 'EMER')]">
    <xsl:copy-of select="n:mapTerminology('eOutcome.13', hl7:value, '2.16.840.1.113883.6.90')"/>
  </xsl:template>

  <!-- Date/Time of Hospital Discharge -->
  <xsl:template match="hl7:encompassingEncounter/hl7:effectiveTime/hl7:high">
    <eOutcome.16><xsl:copy-of select="n:dateTime(@value)"/></eOutcome.16>
  </xsl:template>


  <!-- #Functions# -->

  <xsl:function name="n:map">
    <xsl:param name="nemsisElementName" required="yes" as="xs:string"/>
    <xsl:param name="hl7Element"/>
    <xsl:param name="nemsisRequired" as="xs:boolean"/>
    <xsl:variable name="result">
      <xsl:apply-templates select="$hl7Element"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$result/node()[node()|@*]">
        <xsl:copy-of select="$result"/>
      </xsl:when>
      <xsl:when test="$nemsisRequired">
        <xsl:element name="{$nemsisElementName}">
          <xsl:attribute name="xsi:nil">true</xsl:attribute>
          <xsl:attribute name="NV">7701003</xsl:attribute>
        </xsl:element>      
      </xsl:when>
    </xsl:choose>
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
      <!-- Otherwise, call the terminology service (extensible function is near the top of this XSLT) -->
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


  <!-- #Mapping Variables# -->

  <!-- Gender -->
  <!-- HL7 administrativeGenderCode, value set 2.16.840.1.113883.1.11.1 -->
  <xsl:variable name="gender">
    <code hl7="F" nemsis="9906001" hl7Desc="Female" nemsisDesc="Female"/>
    <code hl7="M" nemsis="9906003" hl7Desc="Male" nemsisDesc="Male"/>
    <code hl7="UN" nemsis="9906005" hl7Desc="Undifferentiated" nemsisDesc="Unknown (Unable to Determine)"/>
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
    <code hl7="AS" nemsis="" hl7Desc="answering service" nemsisDesc=""/>
    <code hl7="EC" nemsis="" hl7Desc="emergency contact" nemsisDesc=""/>
    <code hl7="HP" nemsis="9913003" hl7Desc="primary home" nemsisDesc="Home"/>
    <code hl7="HV" nemsis="9913003" hl7Desc="vacation home" nemsisDesc="Home"/>
    <code hl7="MC" nemsis="9913005" hl7Desc="mobile contact)" nemsisDesc="Mobile"/>
    <code hl7="PG" nemsis="9913007" hl7Desc="pager" nemsisDesc="Pager"/>
    <code hl7="WP" nemsis="9913009" hl7Desc="work place" nemsisDesc="Work"/>
  </xsl:variable>

  <!-- Email Address Type -->
  <!-- HL7 Telecom Use, value set 2.16.840.1.113883.11.20.9.20 -->
  <xsl:variable name="emailAddressType">
    <code hl7="AS" nemsis="" hl7Desc="answering service" nemsisDesc=""/>
    <code hl7="EC" nemsis="" hl7Desc="emergency contact" nemsisDesc=""/>
    <code hl7="HP" nemsis="9904001" hl7Desc="primary home" nemsisDesc="Personal"/>
    <code hl7="HV" nemsis="9904001" hl7Desc="vacation home" nemsisDesc="Personal"/>
    <code hl7="MC" nemsis="" hl7Desc="mobile contact)" nemsisDesc=""/>
    <code hl7="PG" nemsis="" hl7Desc="pager" nemsisDesc=""/>
    <code hl7="WP" nemsis="9904003" hl7Desc="work place" nemsisDesc="Work"/>
  </xsl:variable>


</xsl:stylesheet>