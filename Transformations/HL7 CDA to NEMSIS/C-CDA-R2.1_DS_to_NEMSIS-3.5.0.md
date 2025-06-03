# HL7 C-CDA R2.1 Discharge Summary to NEMSIS v3.5.0 Outcome Transformation

This transformation is used to transform content from an [HL7 C-CDA R2.1 Discharge Summary](https://www.hl7.org/ccdasearch/templates/2.16.840.1.113883.10.20.22.1.8.html) document representing a hospital emergency department or inpatient encounter that occurred as a result of an EMS transport into the [eOutcome](https://nemsis.org/media/nemsis_v3/release-3.5.0/DataDictionary/PDFHTML/EMSDEMSTATE/sections/eOutcome.002.xml) section of a NEMSIS v3.5.0 EMSDataSet document.

## Files

* **[C-CDA-R2.1_DS_to_NEMSIS-3.5.0.xsl](C-CDA-R2.1_DS_to_NEMSIS-3.5.0.xsl)**
  * The XML Style Sheet Language Transformation (XSLT) file. It also imports XSLT files from `includes`.
* **[C-CDA-R2.1_DS_to_NEMSIS-3.5.0_ED_In.xml](C-CDA-R2.1_DS_to_NEMSIS-3.5.0_ED_In.xml)**
  * Sample Discharge Summary document representing a hospital emergency department encounter following EMS transport.
* **[C-CDA-R2.1_DS_to_NEMSIS-3.5.0_ED_Out.xml](C-CDA-R2.1_DS_to_NEMSIS-3.5.0_ED_Out.xml)**
  * Sample NEMSIS output resulting from applying the transformation to the sample emergency department Discharge Summary document.
* **[C-CDA-R2.1_DS_to_NEMSIS-3.5.0_Inpatient_In.xml](C-CDA-R2.1_DS_to_NEMSIS-3.5.0_Inpatient_In.xml)**
  * Sample Discharge Summary document representing a hospital inpatient encounter following EMS transport.
* **[C-CDA-R2.1_DS_to_NEMSIS-3.5.0_Inpatient_Out.xml](C-CDA-R2.1_DS_to_NEMSIS-3.5.0_Inpatient_Out.xml)**
  * Sample NEMSIS output resulting from applying the transformation to the sample inpatient Discharge Summary document.

## Transformation Notes

This product is provided by the NEMSIS TAC, without charge, to facilitate a data mapping between HL7 C-CDA and NEMSIS v3.5.0. This stylesheet transforms a Clinical Document from a hospital, provided in HL7 C-CDA 2.1 format, into a partial NEMSIS v3.5.0 EMSDataSet XML document containing an eOutcome data section representing the information from the hospital's care of the patient.

The resulting document is not valid per the NEMSIS 3.5.0 XSD. Its purpose is to convey hospital patient care information in the NEMSIS eOutcome section.

This stylesheet assumes the document to be transformed is a C-CDA v2.1 Discharge Summary representing a hospital emergency department or inpatient encounter.

### ePatient

To assist patient identification and record matching, this transformation generates an incomplete NEMSIS `ePatient` section. It only includes some elements.

* **ePatient.PatientNameGroup**
  If a Legal name is provided, use that; otherwise, use the first name entry for the patient.
  * **ePatient.02 - Last Name**
  * **ePatient.03 - First Name**
  * **ePatient.04 - Middle Initial/Name**
* **ePatient.13 - Gender**
* **ePatient.14 - Race**
  C-CDA `raceCode` and `ethnicityCode` both map to this element. Additional races (`sdtc:raceCode`) that are supported by NEMSIS are also mapped, but codes that are more specific are not mapped (the complete list for `sdtc:raceCode` has over 490 items).
* **ePatient.17 - Date of Birth**
* **ePatient.18 - Patient's Phone Number**
  NEMSIS only supports US phone numbers.
* **ePatient.19 - Patient's Email Address**
* **ePatient.20 - State Issuing Driver's License**
* **ePatient.21 - Driver's License Number**

Patient's Home Address, City, State, ZIP Code, and Country could also be mapped, but they are not implemented in this transformation. City would need to be mapped from text to GNIS code. State would need to be mapped from postal abbreviation to ANSI code.

### eOutcome

This transformation generates a complete NEMSIS `eOutcome` section, filling in "Not Values" where data are not available in the C-CDA document.

Determine the encounter type from `ClinicalDocument/componentOf/encompassingEncounter/code/@code`. The value `EMER` is considered an emergency department encounter; any other value is considered an inpatient encounter. This affects which of several data elements in the `eOutcome` section are populated by the transformation.

* **eOutcome.01 - Emergency Department Disposition**
  HL7 recommends using NUBC UB-04 FL17 Patient Status (2.16.840.1.113883.3.88.12.80.33) but also allows other code sets, such as Discharge Disposition (HL7) (2.16.840.1.113883.12.112). NEMSIS supports a subset of those code sets. Map the code if it is supported by NEMSIS. This translation could be improved by mapping non-NEMSIS-supported codes to NEMSIS-supported codes. For example, all codes in the 30s could be mapped to "30", since they represent variations of "Still a Patient".
* **eOutcome.02 - Hospital Disposition**
  See notes on `eOutcome.01`.
* **eOutcome.ExternalDataGroup**
  * **eOutcome.03 - External Report ID/Number Type**
    Coded to "Hospital-Receiving".
  * **eOutcome.04 - External Report ID/Number**
    NEMSIS does not specify which of the several identifiers available in a C-CDA document should be used for External Report ID/Number. This transformation uses `encompassingEncounter/id/@extension`. Other options include:
    * `ClinicalDocument/recordTarget/patientRole/id`: Patient identifiers
    * `ClinicalDocument/id`: The clinical document instance identifier
    * `ClinicalDocument/setId`: The clinical document set identifier
    It may be desirable to include `@root`, in the format "`{@root}^{@extension}`", to generate an identifier that includes the Hospital's OID (to make it universally unique).
* **eOutcome.EmergencyDepartmentProceduresGroup**
  * **eOutcome.09 - Emergency Department Procedures**
  NEMSIS only supports ICD-10-PCS, so only process procedures with ICD-10 codes provided, which may come from `code` or `code/translation`.
  * **eOutcome.19 - Date/Time Emergency Department Procedure Performed**
  Select the date/time the procedure was performed (when single timestamp is provided) or completed (`high` timestamp when `low`/`high` are provided).
* **eOutcome.10 - Emergency Department Diagnosis**
  Process Admission Diagnoses, Discharge Diagnoses, and Problems.
  If a diagnosis does not have a documented `effectiveTime/low` that is within one day prior to the date of `effectiveTime/low` of the `encompassingEncounter` (or later), exclude it.
  NEMSIS only supports ICD-10-CM, so only process diagnoses with ICD-10 codes provided, which may come from `code` or `code/translation`.
  This transformation de-duplicates diagnosis codes (if the same diagnosis code is recorded more than once, it is only generated once in the output).
* **eOutcome.11 - Date/Time of Hospital Admission**
* **eOutcome.HospitalProceduresGroup**
  See notes on `eOutcome.EmergencyDepartmentProceduresGroup`.
  * **eOutcome.12 - Hospital Procedures**
  * **eOutcome.20 - Date/Time Hospital Procedure Performed**
* **eOutcome.13 - Hospital Diagnosis**
  See notes on `eOutcome.10`.
* **eOutcome.16 - Date/Time of Hospital Discharge**
* **eOutcome.18 - Date/Time of Emergency Department Admission**

### Dates/Times

* Date: Only transform date values that are specified at least to the day.
* Date/Time: Only transform date/time values that are specified at least to the minute and have a timezone.

### Terminology Mapping

As noted above, NEMSIS only supports ICD-10-CM for diagnoses and ICD-10-PCS for procedures. C-CDA documents often use SNOMED, HCPCS, and CPT and may not provide translations. This transformation uses a function named `n:terminology` in `includes/terminologyService.xsl` that can be extended to implement calls to a terminology service. If the transformation doesn't find a NEMSIS-supported code, it will pass the HL7 `code` or `value` node to the `n:terminology` function. If you have access to a terminology service, you can add code to the `n:terminology` function to implement an API call to the terminology service to request translation to the NEMSIS-supported code system and parse the response. The `n:terminology` function should return a simple string value representing the translated code. If the mapping is unsuccessful, the function should return nothing.