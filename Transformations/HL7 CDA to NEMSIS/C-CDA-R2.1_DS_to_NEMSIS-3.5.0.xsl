<?xml version="1.0" encoding="UTF-8"?>

<!--

XML Stylesheet Language Transformation (XSLT) to transform from HL7 C-CDA v2.1 Discharge Summary 
to NEMSIS EMSDataSet v3.5.0

This product is provided by the NEMSIS TAC, without charge, to facilitate a data mapping between 
HL7 C-CDA and NEMSIS v3.5.0. This stylesheet transforms a Clinical Document from a hospital,
provided in HL7 C-CDA 2.1 format, into a partial NEMSIS v3.5.0 EMSDataSet XML document containing 
an eOutcome data section representing the information from the hospital's care of the patient.

The document to be transformed may represent a hospital emergency department or inpatient encounter.

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

  <!-- If you have access to a terminology mapping service, edit terminologyService.xsl to 
       implement API calls. -->
  <xsl:import href="includes/terminologyService.xsl"/>
  <xsl:import href="includes/functions.xsl"/>
  <xsl:import href="includes/mappings.xsl"/>
  <xsl:import href="includes/ePatient.xsl"/>

  <xsl:output method="xml" encoding="UTF-8" indent="yes"/>

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

  <!-- Patient: includes/ePatient.xsl -->

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
        <xsl:when test="$procedures[$encounterType = 'EMER']">
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
        <xsl:choose>
          <xsl:when test="$diagnoses[$encounterType = 'EMER']">
            <xsl:apply-templates select="$diagnoses">
              <xsl:with-param name="diagnosisElement">eOutcome.10</xsl:with-param>
              </xsl:apply-templates>
          </xsl:when>
          <xsl:otherwise>
            <eOutcome.10 xsi:nil="true" NV="7701003"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:copy-of select="$edDiagnoses/node()[not(. = preceding-sibling::*)]"/>
      <!-- Date/Time of Hospital Admission -->
      <xsl:copy-of select="n:map('eOutcome.11', hl7:effectiveTime/hl7:low[not($encounterType = 'EMER')], true())"/>
      <!-- Hospital Procedures -->
      <xsl:choose>
        <xsl:when test="$procedures[not($encounterType = 'EMER')]">
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
        <xsl:choose>
          <xsl:when test="$diagnoses[not($encounterType = 'EMER')]">
            <xsl:apply-templates select="$diagnoses">
              <xsl:with-param name="diagnosisElement">eOutcome.13</xsl:with-param>
              </xsl:apply-templates>
          </xsl:when>
          <xsl:otherwise>
            <eOutcome.13 xsi:nil="true" NV="7701003"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:copy-of select="$hospitalDiagnoses/node()[not(. = preceding-sibling::*)]"/>
      <!-- Date/Time of Hospital Discharge -->
      <xsl:copy-of select="n:map('eOutcome.16', hl7:effectiveTime/hl7:high[not($encounterType = 'EMER')], true())"/>
      <!-- Date/Time of ED Admission -->
      <xsl:copy-of select="n:map('eOutcome.18', hl7:effectiveTime/hl7:low[$encounterType = 'EMER'], true())"/>
    </eOutcome>
  </xsl:template>


  <!-- #Elements# -->

  <!-- Emergency Department or Inpatient Disposition -->
  <xsl:template match="hl7:dischargeDispositionCode[matches(@code, '^(0?[1-79])|(2[01])|(30)|(43)|(5[01])|(6[1-6])|(70)$')]">
    <xsl:number value="@code" format="01"/>
  </xsl:template>

  <!-- External Report ID -->
  <xsl:template match="hl7:encompassingEncounter/hl7:id">
    <xsl:if test="@extension">
    <eOutcome.ExternalDataGroup>
      <!-- External Report ID/Number Type: Hospital-Receiving -->
      <eOutcome.03>4303005</eOutcome.03>
      <!-- External Report ID/Number -->
      <!-- Note: It may be desirable to include @root, in the format "{@root}^{@extension}", to
           generate an identifier that includes the Hospital's OID (to make it universally unique). -->
      <eOutcome.04><xsl:value-of select="@extension"/></eOutcome.04>
    </eOutcome.ExternalDataGroup>
    </xsl:if>
  </xsl:template>

  <!-- Date/Time of Hospital or Emergency Department Admission -->
  <xsl:template match="hl7:encompassingEncounter/hl7:effectiveTime/hl7:low">
    <xsl:value-of select="n:dateTime(@value)"/>
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

  <!-- Emergency Department or Hospital Diagnosis -->
  <!-- NEMSIS only supports ICD-10-CM. If ICD-10-CM code is not provided, a terminology service 
       may be used to translate to ICD-10-CM. -->
  <xsl:template match="hl7:observation[hl7:templateId[starts-with(@root, '2.16.840.1.113883.10.20.22.4.4')]]">
    <xsl:param name="diagnosisElement"/>
    <xsl:copy-of select="n:mapTerminology($diagnosisElement, hl7:value, '2.16.840.1.113883.6.90')"/>
  </xsl:template>

  <!-- Date/Time of Hospital Discharge -->
  <xsl:template match="hl7:encompassingEncounter/hl7:effectiveTime/hl7:high">
        <xsl:value-of select="n:dateTime(@value)"/>
  </xsl:template>


</xsl:stylesheet>