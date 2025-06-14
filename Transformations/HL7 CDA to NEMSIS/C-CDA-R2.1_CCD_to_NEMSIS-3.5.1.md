# HL7 C-CDA R2.1 Continuity of Care Document to NEMSIS v3.5.1 Outcome Transformation

This transformation is used to transform content from an [HL7 C-CDA R2.1 Continuity of Care Document](https://www.hl7.org/ccdasearch/templates/2.16.840.1.113883.10.20.22.1.2.html) document representing hospital emergency department and inpatient encounters that occurred as a result of an EMS transport into the [eOutcome](https://nemsis.org/media/nemsis_v3/release-3.5.1/DataDictionary/PDFHTML/EMSDEMSTATE/sections/eOutcome.002.xml) section of a NEMSIS v3.5.1 EMSDataSet document.

## Files

* **[C-CDA-R2.1_CCD_to_NEMSIS-3.5.1.xsl](C-CDA-R2.1_CCD_to_NEMSIS-3.5.1.xsl)**
  * The XML Style Sheet Language Transformation (XSLT) file. It also imports XSLT files from `includes`.
* **[C-CDA-R2.1_CCD_to_NEMSIS-3.5.1_In.xml](C-CDA-R2.1_CCD_to_NEMSIS-3.5.1_In.xml)**
  * Sample Continuity of Care Document representing a hospital emergency department encounter following EMS transport.
* **[C-CDA-R2.1_CCD_to_NEMSIS-3.5.1_Out.xml](C-CDA-R2.1_CCD_to_NEMSIS-3.5.1_Out.xml)**
  * Sample NEMSIS output resulting from applying the transformation to the sample emergency department Continuity of Care Document.

## Transformation Notes

This product is provided by the NEMSIS TAC, without charge, to facilitate a data mapping between HL7 C-CDA and NEMSIS v3.5.1. This stylesheet transforms a Clinical Document from a hospital, provided in HL7 C-CDA 2.1 format, into a partial NEMSIS v3.5.1 EMSDataSet XML document containing an eOutcome data section representing the information from the hospital's care of the patient.

The resulting document is not valid per the NEMSIS 3.5.1 XSD. Its purpose is to convey hospital patient care information in the NEMSIS eOutcome section.

This stylesheet assumes the document to be transformed is a C-CDA v2.1 Continuity of Care Document containing a hospital emergency department or inpatient encounter or both.

### Parameters

* **startDateTime** (optional)
  Format: `YYYYMMDD` or `YYYYMMDDHHMM` or `YYYYMMDDHHMMSS`
  For best results, call this stylesheet with a value for this parameter, which should represent the date/time EMS transferred patient care to the hospital. This stylesheet will select the first emergency department encounter and the first inpatient encounter that occurred after the requested date/time to populate the NEMSIS eOutcome elements. If this parameter is not provided, the stylesheet will use `serviceEvent/effectiveTime/low` from the CCD instead. Depending on how the CCD was generated, it may include encounters that occurred earlier or later than the time frame relevant to the EMS incident.

### ePatient

This generates a complete NEMSIS ePatient section, filling in "Not Values" where data are not available in the C-CDA document.

* **ePatient.PatientNameGroup**
  If a Legal name is provided, use that; otherwise, use the first name entry for the patient.
  * **ePatient.02 - Last Name**
  * **ePatient.03 - First Name**
  * **ePatient.04 - Middle Initial/Name**
  * **ePatient.23 - Name Suffix**
* **Home Address**
  * Use the first address that represents a "home" address, if available. Otherwise, use the first address that represents an "other" address, if available. Otherwise, use the first address that has no use specified. Do not use "work" or "bad" addresses.
  * **ePatient.06 - Patient's Home City**
  Translate text to GNIS.
  * **ePatient.07 - Patient's Home County**
  Not available in C-CDA.
  * **ePatient.08 - Patient's Home State**
  HL7 Value Set for State has no authoritative source. NEMSIS specifies specifies ANSI INCITS 38-2009 two-digit numeric codes. This transformation will use two-digit codes (assumed to be ANSI codes) or map from postal abbreviations.
  * **ePatient.09 - Patient's Home ZIP Code**
  NEMSIS only supports postal codes matching US, Canada, or Mexico patterns. If the value is valid for NEMSIS, use it.
  * **ePatient.10 - Patient's Country of Residence**
  HL7 Value Set for Country has no authoritative source. NEMSIS specifies ISO 3166 and requires exactly two characters. If the value is valid for NEMSIS, use it.
  * **ePatient.12 - Social Security Number**
* **ePatient.13 - Gender**
* **ePatient.14 - Race**
  C-CDA `raceCode` and `ethnicityCode` both map to this element. Additional races (`sdtc:raceCode`) that are supported by NEMSIS are also mapped, but codes that are more specific are not mapped (the complete list for `sdtc:raceCode` has over 490 items).
* **ePatient.17 - Date of Birth**
* **ePatient.18 - Patient's Phone Number**
* **ePatient.19 - Patient's Email Address**
* **ePatient.20 - State Issuing Driver's License**
* **ePatient.21 - Driver's License Number**
* **ePatient.24 - Patient's Preferred Language(s)**
  If language code has a dash (for regional subtags), use only the portion before the dash. Map from ISO-639-1 (two-character codes) and ISO-639-2 (three-character codes, both "B" [bibliographic] and "T" [terminology] codes) to the codes that are supported by NEMSIS.
* **ePatient.25 - Sex**

### eOutcome

This transformation generates a complete NEMSIS `eOutcome` section, filling in "Not Values" where data are not available in the C-CDA document.

The **emergency department encounter** is the first encounter (chronologically) where `effectiveTime/low` is after `$startDateTime` and `code` contains one of several CPT codes that represent an emergency department visit. The **inpatient encounter** is the first encounter (chronologically) where `effectiveTime/low` is after `$startDateTime` and `code` contains one of several CPT codes that represent an inpatient visit. The codes are listed in the `$encType` variable in the transformation.

* **eOutcome.01 - Emergency Department Disposition**
  HL7 recommends using NUBC UB-04 FL17 Patient Status (2.16.840.1.113883.3.88.12.80.33) but also allows other code sets, such as Discharge Disposition (HL7) (2.16.840.1.113883.12.112). NEMSIS supports a subset of those code sets. Map the code if it is supported by NEMSIS. This translation could be improved by mapping non-NEMSIS-supported codes to NEMSIS-supported codes. For example, all codes in the 30s could be mapped to "30", since they represent variations of "Still a Patient".
* **eOutcome.02 - Hospital Disposition**
  See notes on `eOutcome.01`.
* **eOutcome.ExternalDataGroup**
  * **eOutcome.03 - External Report ID/Number Type**
    Coded to "Hospital-Receiving".
  * **eOutcome.04 - External Report ID/Number**
    NEMSIS does not specify which of the several identifiers available in a C-CDA document should be used for External Report ID/Number. This transformation uses `encounter/id/@extension`. Other options include:
    * `ClinicalDocument/recordTarget/patientRole/id`: Patient identifiers
    * `ClinicalDocument/id`: The clinical document instance identifier
    * `ClinicalDocument/setId`: The clinical document set identifier
    It may be desirable to include `@root`, in the format "`{@root}^{@extension}`", to generate an identifier that includes the Hospital's OID (to make it universally unique).
* **eOutcome.EmergencyDepartmentProceduresGroup**
  Process procedures where `entryRelationship/encounter/id` references the `id` of the emergency department encounter or where `effectiveTime` is within the `effectiveTime` of the emergency department encounter.
  * **eOutcome.09 - Emergency Department Procedures**
  NEMSIS only supports ICD-10-PCS, so only process procedures with ICD-10 codes provided, which may come from `code` or `code/translation`.
  * **eOutcome.19 - Date/Time Emergency Department Procedure Performed**
  Select the date/time the procedure was performed (when single timestamp is provided) or completed (`high` timestamp when `low`/`high` are provided).
* **eOutcome.10 - Emergency Department Diagnosis**
  Process Encounter Diagnoses from the emergency department encounter and Problems that were documented during the emergency department encounter.
  If a diagnosis does not have a documented `effectiveTime/low` that is within one day prior to the date of `effectiveTime/low` of the `encounter` (or later), exclude it.
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

As noted above, NEMSIS only supports ICD-10-CM for diagnoses and ICD-10-PCS for procedures. C-CDA documents often use SNOMED, HCPCS, and CPT and may not provide translations. This transformation uses a function named `n:terminology` in `includes/services.xsl` that can be extended to implement calls to a terminology service. If the transformation doesn't find a NEMSIS-supported code, it will pass the HL7 `code` or `value` node to the `n:terminology` function. If you have access to a terminology service, you can add code to the `n:terminology` function to implement an API call to the terminology service to request translation to the NEMSIS-supported code system and parse the response. The `n:terminology` function should return a simple string value representing the translated code. If the mapping is unsuccessful, the function should return nothing.

### Geographic Names Information System (GNIS) Mapping

As noted above, NEMSIS requires GNIS codes for `ePatient.06 - Patient's Home City`. C-CDA documents use text. This transformation uses a function named `n:gnisEncode` in `includes/services.xsl` that can be extended to implement calls to a GNIS lookup service. If the transformation doesn't find a NEMSIS-supported code, it omits `ePatient.06` in the output. This transformation provides a reference implementation of the function using the NEMSIS TAC GNIS web service. If you have access to a GNIS lookup service, you can modify code in the `n:gnisEncode` function to implement an API call to the terminology service to request translation of city/place names from text to the NEMSIS-supported GNIS code system and parse the response. The `n:gnisEncode` function should return a simple string value representing the translated code. If the mapping is unsuccessful, the function should return nothing.
