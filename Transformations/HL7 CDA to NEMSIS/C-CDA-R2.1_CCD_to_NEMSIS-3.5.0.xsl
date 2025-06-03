<?xml version="1.0" encoding="UTF-8"?>

<!--

XML Stylesheet Language Transformation (XSLT) to transform from HL7 C-CDA v2.1 Continuity of Care 
Document to NEMSIS EMSDataSet v3.5.0

This product is provided by the NEMSIS TAC, without charge, to facilitate a data mapping between 
HL7 C-CDA and NEMSIS v3.5.0. This stylesheet transforms a Clinical Document from a hospital,
provided in HL7 C-CDA 2.1 format, into a partial NEMSIS v3.5.0 EMSDataSet XML document containing 
an eOutcome data section representing the information from the hospital's care of the patient.

The document to be transformed may contain multiple encounters, which may include a hospital 
emergency department encounter, inpatient encounter, or both.

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
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="hl7 n sdtc xs">

  <!-- If you have access to a terminology mapping service, edit terminologyService.xsl to 
       implement API calls. -->
  <xsl:import href="includes/terminologyService.xsl"/>
  <xsl:import href="includes/functions.xsl"/>
  <xsl:import href="includes/mappings.xsl"/>
  <xsl:import href="includes/ePatient.xsl"/>

  <xsl:output method="xml" encoding="UTF-8" indent="yes"/>

  <!-- Parameter: startDateTime (optional)
       Format: YYYYMMDD or YYYYMMDDHHMM or YYYYMMDDHHMMSS
       For best results, call this stylesheet with a value for this parameter, which should 
       represent the date/time EMS transferred patient care to the hospital. This stylesheet will 
       select the first emergency department encounter and the first inpatient encounter that 
       occurred after the requested date/time to populate the NEMSIS eOutcome elements. If this 
       parameter is not provided, the stylesheet will use serviceEvent/effectiveTime/low from the 
       CCD instead. Depending on how the CCD was generated, it may include encounters that occurred 
       earlier or later than the time frame relevant to the EMS incident.
   -->
  <xsl:param name="startDateTime"/>

  <xsl:variable name="startDateTimeIsValid" select="matches($startDateTime, '^\d{8,14}')"/>

  <xsl:variable name="start">
    <xsl:choose>
      <xsl:when test="$startDateTimeIsValid">
        <xsl:value-of select="$startDateTime"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="/hl7:ClinicalDocument/hl7:documentationOf/hl7:serviceEvent/hl7:effectiveTime/hl7:low/@value"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:key name="code" match="*" use="@hl7"/>


  <!-- #Root Template# -->

  <xsl:template match="/">
    <xsl:comment>
     This partial NEMSIS 3.5.0 document was generated from an HL7 C-CDA 2.1 Continuity of Care 
     Document via an XML Stylesheet Language Transformation (XSLT). It is not valid per the NEMSIS 
     3.5.0 XSD. Its purpose is to convey hospital patient care information in the NEMSIS eOutcome 
     section.
    </xsl:comment>
    <xsl:text>&#10;</xsl:text>
    <xsl:if test="not($startDateTime)">
      <xsl:comment>
        Warning: The startDateTime parameter was not provided. serviceEvent/effectiveTime/low will 
        be used instead.
      </xsl:comment>
    </xsl:if>
    <xsl:if test="$startDateTime and not($startDateTimeIsValid)">
      <xsl:comment>
        Warning: The startDateTime parameter is not valid (format should be YYYYMMDD or YYMMDDHHMM 
        or YYYYMMDDHHMMSS). serviceEvent/effectiveTime/low will be used instead.
      </xsl:comment>
    </xsl:if>
    <xsl:if test="not($startDateTimeIsValid) and xs:date(n:date($start)) &lt; current-date() - xs:yearMonthDuration('P1M')">
      <xsl:comment>
        Warning: The serviceEvent/effectiveTime/low is more than one month ago. This document may 
        include information from encounters that occured prior to the relevant EMS incident.
      </xsl:comment>
    </xsl:if>
    <xsl:if test="not(/hl7:ClinicalDocument/hl7:templateId/@root = '2.16.840.1.113883.10.20.22.1.2')">
      <xsl:comment>
        Warning: The source document does not appear to be an HL7 C-CDA 2.1 Continuity of Care 
        Document. Results may be incomplete or incorrect.
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
          <!-- serviceEvent > eOutcome -->
          <xsl:apply-templates select="hl7:documentationOf/hl7:serviceEvent"/>
        </PatientCareReport>
      </Header>
    </EMSDataSet>
  </xsl:template>


  <!-- #Sections# -->

  <!-- Patient: includes/ePatient.xsl -->

  <!-- Outcome -->
  <!-- This generates a complete NEMSIS eOutcome section, filling in "Not Values" where data are 
       not available in the C-CDA document. -->
  <xsl:template match="hl7:serviceEvent">

    <!-- Variable to select encounters within timeframe, sorted chronologically -->
    <xsl:variable name="encounters">
      <xsl:perform-sort select="/hl7:ClinicalDocument/hl7:component/hl7:structuredBody/hl7:component/hl7:section[hl7:templateId[starts-with(@root, '2.16.840.1.113883.10.20.22.2.22')]]/hl7:entry/hl7:encounter[hl7:effectiveTime/(hl7:low/@value, @value)[1] >= $start]">
        <xsl:sort select="hl7:effectiveTime/(hl7:low/@value, @value)[1]"/>
      </xsl:perform-sort>
    </xsl:variable>
    
    <!-- Variable to select first emergency department encounter -->
    <xsl:variable name="edEncounter" select="$encounters/hl7:encounter[key('code', hl7:code/@code, $encType/n:ed)][1]"/>
    
    <!-- Variable to select first inpatient encounter -->
    <xsl:variable name="inpatientEncounter" select="$encounters/hl7:encounter[key('code', hl7:code/@code, $encType/n:inpatient)][1]"/>

    <!-- Variable to select procedures -->
    <xsl:variable name="procedures" select="/hl7:ClinicalDocument/hl7:component/hl7:structuredBody/hl7:component/hl7:section[hl7:templateId[starts-with(@root, '2.16.840.1.113883.10.20.22.2.7')]]/hl7:entry/*[not(@negationInd = 'true')]"/>

    <!-- Note on procedures: This transformation selects procedures where entryRelationship/
         encounter/id references the id of the emergency department or inpatient encounter or 
         `effectiveTime` is within the `effectiveTime` of the emergency department or inpatient 
         encounter. -->

    <!-- Variable to select emergency department procedures -->
    <xsl:variable name="edProcedures" select="$procedures[hl7:entryRelationship/hl7:encounter/hl7:id/concat(@root,@extension) = $edEncounter/hl7:id/concat(@root, @extension) or (hl7:effectiveTime//@value >= $edEncounter/hl7:effectiveTime/hl7:low/@value and hl7:effectiveTime//@value &lt;= $edEncounter/hl7:effectiveTime/hl7:high/@value)]"/>

    <!-- Variable to select inpatient procedures -->
    <xsl:variable name="inpatientProcedures" select="$procedures[hl7:entryRelationship/hl7:encounter/hl7:id/concat(@root,@extension) = $inpatientEncounter/hl7:id/concat(@root,@extension) or (hl7:effectiveTime//@value >= $inpatientEncounter/hl7:effectiveTime/hl7:low/@value and hl7:effectiveTime//@value &lt;= $inpatientEncounter/hl7:effectiveTime/hl7:high/@value)]"/>

    <!-- Note on diagnoses: This transformation selects Encounter Diagnoses within each (ED and
         inpatient) encounter. It also selects entries from the Problem section. It does not select
         Indications from each encounter.-->

    <!-- Variable to select emergency department diagnoses -->
    <!-- If a diagnosis has a documented effectiveTime/low that is more than one day prior to 
         the date of effectiveTime/low of the encounter, exclude it. -->
    <xsl:variable name="edDiagnoses" select="$edEncounter/hl7:entryRelationship/hl7:act/hl7:entryRelationship/hl7:observation[not(@negationInd = 'true') and hl7:effectiveTime/hl7:low/xs:date(n:date(@value)) >= $edEncounter/hl7:effectiveTime/hl7:low/xs:date(n:date(@value)) - xs:dayTimeDuration('P1D')]"/>
    
    <!-- Variable to select inpatient diagnoses -->
    <!-- If a diagnosis has a documented effectiveTime/low that is more than one day prior to 
         the date of effectiveTime/low of the encounter, exclude it. -->
    <xsl:variable name="inpatientDiagnoses" select="$inpatientEncounter/hl7:entryRelationship/hl7:act/hl7:entryRelationship/hl7:observation[not(@negationInd = 'true') and hl7:effectiveTime/hl7:low/xs:date(n:date(@value)) >= $inpatientEncounter/hl7:effectiveTime/hl7:low/xs:date(n:date(@value)) - xs:dayTimeDuration('P1D')]"/>
    
    <!-- Variable to select problems documented during the emergency department encounter -->
    <!-- If a problem has a documented effectiveTime/low that is more than one day prior to 
         the date of effectiveTime/low of the encounter, exclude it. -->
         <xsl:variable name="edProblems" select="/hl7:ClinicalDocument/hl7:component/hl7:structuredBody/hl7:component/hl7:section[hl7:templateId[starts-with(@root, '2.16.840.1.113883.10.20.22.2.5')]]/hl7:entry/hl7:act/hl7:entryRelationship/hl7:observation[not(@negationInd = 'true') and hl7:effectiveTime/hl7:low/xs:date(n:date(@value)) >= $edEncounter/hl7:effectiveTime/hl7:low/xs:date(n:date(@value)) - xs:dayTimeDuration('P1D') and hl7:author/hl7:time/@value >= $edEncounter/hl7:effectiveTime/hl7:low/@value and hl7:author/hl7:time/@value &lt;= $edEncounter/hl7:effectiveTime/hl7:high/@value]"/>
    
    <!-- Variable to select problems documented during the inpatient encounter -->
    <!-- If a problem has a documented effectiveTime/low that is more than one day prior to 
         the date of effectiveTime/low of the encounter, exclude it. -->
         <xsl:variable name="inpatientProblems" select="/hl7:ClinicalDocument/hl7:component/hl7:structuredBody/hl7:component/hl7:section[hl7:templateId[starts-with(@root, '2.16.840.1.113883.10.20.22.2.5')]]/hl7:entry/hl7:act/hl7:entryRelationship/hl7:observation[not(@negationInd = 'true') and hl7:effectiveTime/hl7:low/xs:date(n:date(@value)) >= $inpatientEncounter/hl7:effectiveTime/hl7:low/xs:date(n:date(@value)) - xs:dayTimeDuration('P1D') and hl7:author/hl7:time/@value >= $inpatientEncounter/hl7:effectiveTime/hl7:low/@value and hl7:author/hl7:time/@value &lt;= $inpatientEncounter/hl7:effectiveTime/hl7:high/@value]"/>
    
    <eOutcome>
      <!-- Dispositions: HL7 recommends using NUBC UB-04 FL17 Patient Status 
           (2.16.840.1.113883.3.88.12.80.33) but also allows other code sets, such as Discharge 
           Disposition (HL7) (2.16.840.1.113883.12.112). NEMSIS supports a subset of those code 
           sets. Map the code if it is supported by NEMSIS. This translation could be improved by 
           mapping non-NEMSIS-supported codes to NEMSIS-supported codes. For example, all codes in 
           the 30s could be mapped to "30", since they represent variations of "Still a Patient". -->
      <!-- ED Disposition -->
      <xsl:copy-of select="n:map('eOutcome.01', $edEncounter/sdtc:dischargeDispositionCode, true())"/>
      <!-- Hospital Disposition -->
      <xsl:copy-of select="n:map('eOutcome.02', $inpatientEncounter/sdtc:dischargeDispositionCode, true())"/>
      <!-- External Report ID: Encounter ID -->
      <!-- NEMSIS does not specify which of the several identifiers available in a C-CDA document 
           should be used for External Report ID/Number. This transformation uses encounter/id. If 
           the CCD includes both ED and inpatient encounters, both are processed and two NEMSIS
           eOutcome.ExternalDataGroup elements are generated. Other options include:
           * ClinicalDocument/recordTarget/patientRole/id: Patient identifiers
           * ClinicalDocument/id: The clinical document instance identifier
           * ClinicalDocument/setId: The clinical document set identifier -->
           <xsl:apply-templates select="$edEncounter/hl7:id[1]"/>
           <xsl:apply-templates select="$inpatientEncounter/hl7:id[1]"/>
      <!-- ED Procedures -->
      <xsl:choose>
        <xsl:when test="$edProcedures">
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
      <xsl:variable name="edDiagnosesOutput">
        <xsl:choose>
          <xsl:when test="$edDiagnoses or $edProblems">
            <xsl:apply-templates select="$edDiagnoses | $edProblems">
              <xsl:with-param name="diagnosisElement">eOutcome.10</xsl:with-param>
              </xsl:apply-templates>
          </xsl:when>
          <xsl:otherwise>
            <eOutcome.10 xsi:nil="true" NV="7701003"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:copy-of select="$edDiagnosesOutput/node()[not(. = preceding-sibling::*)]"/>
      <!-- Date/Time of Hospital Admission -->
      <xsl:copy-of select="n:map('eOutcome.11', $inpatientEncounter/hl7:effectiveTime/hl7:low, true())"/>
      <!-- Hospital Procedures -->
      <xsl:choose>
        <xsl:when test="$inpatientProcedures">
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
      <xsl:variable name="hospitalDiagnosesOutput">
        <xsl:choose>
          <xsl:when test="$inpatientDiagnoses or $inpatientProblems">
            <xsl:apply-templates select="$inpatientDiagnoses | $inpatientProblems">
              <xsl:with-param name="diagnosisElement">eOutcome.13</xsl:with-param>
              </xsl:apply-templates>
          </xsl:when>
          <xsl:otherwise>
            <eOutcome.13 xsi:nil="true" NV="7701003"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:copy-of select="$hospitalDiagnosesOutput/node()[not(. = preceding-sibling::*)]"/>
      <!-- Date/Time of Hospital Discharge -->
      <xsl:copy-of select="n:map('eOutcome.16', $inpatientEncounter/hl7:effectiveTime/hl7:high, true())"/>
      <!-- Date/Time of ED Admission -->
      <xsl:copy-of select="n:map('eOutcome.18', $edEncounter/hl7:effectiveTime/hl7:low, true())"/>
    </eOutcome>
  </xsl:template>


  <!-- #Elements# -->

  <!-- Emergency Department or Inpatient Disposition -->
  <xsl:template match="sdtc:dischargeDispositionCode[matches(@code, '^(0?[1-79])|(2[01])|(30)|(43)|(5[01])|(6[1-6])|(70)$')]">
    <xsl:number value="@code" format="01"/>
  </xsl:template>

  <!-- External Report ID -->
  <xsl:template match="hl7:encounter/hl7:id">
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
  <xsl:template match="hl7:encounter/hl7:effectiveTime/hl7:low">
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
  <xsl:template match="hl7:encounter/hl7:effectiveTime/hl7:high">
    <xsl:value-of select="n:dateTime(@value)"/>
  </xsl:template>


  <!-- #Variables# -->
  
  <!-- Enounter Type Variable -->
  <xsl:variable name="encType">
    <ed>
      <code hl7="99281" hl7Desc="Emergency department visit for the evaluation and management of a patient that may not require the presence of a physician or other qualified health care professional"/>
      <code hl7="99282" hl7Desc="Emergency department visit for the evaluation and management of a patient, which requires a medically appropriate history and/or examination and straightforward medical decision making"/>
      <code hl7="99283" hl7Desc="Emergency department visit for the evaluation and management of a patient, which requires a medically appropriate history and/or examination and low level of medical decision making"/>
      <code hl7="99284" hl7Desc="Emergency department visit for the evaluation and management of a patient, which requires a medically appropriate history and/or examination and moderate level of medical decision making"/>
      <code hl7="99285" hl7Desc="Emergency department visit for the evaluation and management of a patient, which requires a medically appropriate history and/or examination and high level of medical decision making"/>
    </ed>
    <inpatient>
      <code hl7="99221" hl7Desc="Initial hospital inpatient or observation care, per day, for the evaluation and management of a patient, which requires a medically appropriate history and/or examination and straightforward or low level medical decision making. When using total time on the date of the encounter for code selection, 40 minutes must be met or exceeded."/>
      <code hl7="99222" hl7Desc="Initial hospital inpatient or observation care, per day, for the evaluation and management of a patient, which requires a medically appropriate history and/or examination and moderate level of medical decision making. When using total time on the date of the encounter for code selection, 55 minutes must be met or exceeded."/>
      <code hl7="99223" hl7Desc="Initial hospital inpatient or observation care, per day, for the evaluation and management of a patient, which requires a medically appropriate history and/or examination and high level of medical decision making. When using total time on the date of the encounter for code selection, 75 minutes must be met or exceeded."/>
      <code hl7="99231" hl7Desc="Subsequent hospital inpatient or observation care, per day, for the evaluation and management of a patient, which requires a medically appropriate history and/or examination and straightforward or low level of medical decision making. When using total time on the date of the encounter for code selection, 25 minutes must be met or exceeded."/>
      <code hl7="99232" hl7Desc="Subsequent hospital inpatient or observation care, per day, for the evaluation and management of a patient, which requires a medically appropriate history and/or examination and moderate level of medical decision making. When using total time on the date of the encounter for code selection, 35 minutes must be met or exceeded."/>
      <code hl7="99233" hl7Desc="Subsequent hospital inpatient or observation care, per day, for the evaluation and management of a patient, which requires a medically appropriate history and/or examination and high level of medical decision making. When using total time on the date of the encounter for code selection, 50 minutes must be met or exceeded."/>
      <code hl7="99234" hl7Desc="Hospital inpatient or observation care, for the evaluation and management of a patient including admission and discharge on the same date, which requires a medically appropriate history and/or examination and straightforward or low level of medical decision making. When using total time on the date of the encounter for code selection, 45 minutes must be met or exceeded."/>
      <code hl7="99235" hl7Desc="Hospital inpatient or observation care, for the evaluation and management of a patient including admission and discharge on the same date, which requires a medically appropriate history and/or examination and moderate level of medical decision making. When using total time on the date of the encounter for code selection, 70 minutes must be met or exceeded."/>
      <code hl7="99236" hl7Desc="Hospital inpatient or observation care, for the evaluation and management of a patient including admission and discharge on the same date, which requires a medically appropriate history and/or examination and high level of medical decision making. When using total time on the date of the encounter for code selection, 85 minutes must be met or exceeded."/>
      <code hl7="99238" hl7Desc="Hospital inpatient or observation discharge day management; 30 minutes or less on the date of the encounter"/>
      <code hl7="99239" hl7Desc="Hospital inpatient or observation discharge day management; more than 30 minutes on the date of the encounter"/>
      <code hl7="99252" hl7Desc="Inpatient or observation consultation for a new or established patient, which requires a medically appropriate history and/or examination and straightforward medical decision making. When using total time on the date of the encounter for code selection, 35 minutes must be met or exceeded."/>
      <code hl7="99253" hl7Desc="Inpatient or observation consultation for a new or established patient, which requires a medically appropriate history and/or examination and low level of medical decision making. When using total time on the date of the encounter for code selection, 45 minutes must be met or exceeded."/>
      <code hl7="99254" hl7Desc="Inpatient or observation consultation for a new or established patient, which requires a medically appropriate history and/or examination and moderate level of medical decision making. When using total time on the date of the encounter for code selection, 60 minutes must be met or exceeded."/>
      <code hl7="99255" hl7Desc="Inpatient or observation consultation for a new or established patient, which requires a medically appropriate history and/or examination and high level of medical decision making. When using total time on the date of the encounter for code selection, 80 minutes must be met or exceeded."/>
      <code hl7="99418" hl7Desc="Prolonged inpatient or observation evaluation and management service(s) time with or without direct patient contact beyond the required time of the primary service when the primary service level has been selected using total time, each 15 minutes of total time (List separately in addition to the code of the inpatient and observation Evaluation and Management service)"/>
      <code hl7="99460" hl7Desc="Initial hospital or birthing center care, per day, for evaluation and management of normal newborn infant"/>
      <code hl7="99462" hl7Desc="Subsequent hospital care, per day, for evaluation and management of normal newborn"/>
      <code hl7="99463" hl7Desc="Initial hospital or birthing center care, per day, for evaluation and management of normal newborn infant admitted and discharged on the same date"/>
      <code hl7="99468" hl7Desc="Initial inpatient neonatal critical care, per day, for the evaluation and management of a critically ill neonate, 28 days of age or younger"/>
      <code hl7="99469" hl7Desc="Subsequent inpatient neonatal critical care, per day, for the evaluation and management of a critically ill neonate, 28 days of age or younger"/>
      <code hl7="99471" hl7Desc="Initial inpatient pediatric critical care, per day, for the evaluation and management of a critically ill infant or young child, 29 days through 24 months of age"/>
      <code hl7="99472" hl7Desc="Subsequent inpatient pediatric critical care, per day, for the evaluation and management of a critically ill infant or young child, 29 days through 24 months of age"/>
      <code hl7="99475" hl7Desc="Initial inpatient pediatric critical care, per day, for the evaluation and management of a critically ill infant or young child, 2 through 5 years of age"/>
      <code hl7="99476" hl7Desc="Subsequent inpatient pediatric critical care, per day, for the evaluation and management of a critically ill infant or young child, 2 through 5 years of age"/>
      <code hl7="99477" hl7Desc="Initial hospital care, per day, for the evaluation and management of the neonate, 28 days of age or younger, who requires intensive observation, frequent interventions, and other intensive care services"/>
    </inpatient>
  </xsl:variable>


</xsl:stylesheet>