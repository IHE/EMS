# NEMSIS v3.5.1 Patient Care Report to C-CDA R2.1 Unstructured Document Transformation

This transformation is used to transform content from a [NEMSIS v3.5.1 EMSDataSet document](https://nemsis.org/media/nemsis_v3/release-3.5.1/DataDictionary/PDFHTML/EMSDEMSTATE/index.html) representing an EMS patient care report (PCR) into an [HL7 C-CDA R2.1 Unstructured Document](https://www.hl7.org/ccdasearch/templates/2.16.840.1.113883.10.20.22.1.10.html).

## Files

* **[NEMSIS-3.5.1_to_C-CDA-R2.1_UD.xsl](NEMSIS-3.5.1_to_C-CDA-R2.1_UD.xsl)**
  * The XML Style Sheet Language Transformation (XSLT) file.
* **[NEMSIS-3.5.1_to_C-CDA-R2.1_UD.xml](NEMSIS-3.5.1_to_C-CDA-R2.1_Config.xml)**
  * Configuration document to provide information about the EMS agency that is necessary in HL7 C-CDA documents but not present in NEMSIS documents.
* **[NEMSIS-3.5.1_to_C-CDA-R2.1_UD_In.xml](NEMSIS-3.5.1_to_C-CDA-R2.1_UD_In.xml)**
  * Sample NEMSIS EMSDataSet Document representing an EMS PCR.
* **[NEMSIS-3.5.1_to_C-CDA-R2.1_UD_Out.xml](NEMSIS-3.5.1_to_C-CDA-R2.1_UD_Out.xml)**
  * Sample HL7 C-CDA R2.1 Unstructured Document output resulting from applying the transformation to the sample NEMSIS EMSDataSet document.

## Transformation Notes

This product is provided by the NEMSIS TAC, without charge, to facilitate a data mapping between NEMSIS v3.5.1 and HL7 C-CDA. This stylesheet transforms a  PCR from an EMS crew, provided in NEMSIS v3.5.1 format, into an HL7 C-CDA R2.1 Clinical Document representing the information from EMS's care of the patient.

This stylesheet assumes the document to be transformed is a NEMSIS EMSDataSet Document containing a single PCR. If the document contains multiple PCRs, only the first PCR is transformed.

The unstructured document content must be provided in `eOther.FileGroup` in the NEMSIS XML document (see "Non-XML Body" below for more details).

### Parameters and Configuration

* **configUrl** (optional)
  Format: URL
  This transformation requires a configuration document containing information about the EMS agency that is not available in NEMSIS but mandatory in the HL7 C-CDA header. This parameter makes it possible to point to a file or other URL that contains the necessary information. If this parameter is not provided, the stylesheet will use the configuration in [NEMSIS-3.5.1_to_C-CDA-R2.1_Config.xml](NEMSIS-3.5.1_to_C-CDA-R2.1_Config.xml) located in the same location as this transformation file. The information in the document should be on a per-agency basis, replacing the sample data with actual information about the EMS agency. The data in `author` and `custodian` should comply with the HL7 C-CDA US Realm Header standard (2.16.840.1.113883.10.20.22.1.1) and can contain any content specified in the standard.

### ClinicalDocument

This transformation generates an HL7 C-CDA R2.1 Unstructured Document, filling in the following information.

* **id**
  Uses `@UUID`. `eRecord.01 Patient Care Report Number` could be used, but `@UUID` is guaranteed to be universally unique. This should be an id that changes each time the document is re-generated from the underlying data, but such information is not available in the NEMSIS document.
* **code**
  Uses LOINC code `67796-3` ("EMS patient care report").
  **confidentialityCode**
  `confidentialityCode` is not supported in NEMSIS. It is set to `N` ("normal").
* **effectiveTime**
  Uses the current date/time. The C-CDA US Realm Header specifies that effectiveTime "signifies the document creation time, when the document first came into being. Where the CDA document is a transform from an original document in some other format, the ClinicalDocument.effectiveTime is the time the original document is created. The time when the transform occurred is not currently represented in CDA." However, the NEMSIS document contains no information about when the original document was created or modified.
* **setId**
  Uses `@UUID`. `eRecord.01 Patient Care Report Number` could be used instead, but `@UUID` is guaranteed to be universally unique and unchanging.
* **versionNumber**
  Uses `UNK` ("Unknown"). There's not sufficient information in the NEMSIS document to know the `versionNumber`.
* **recordTarget/patientRole**: See "Patient" below.
* **author (person)**
  Uses the `author` information from the config file, with `date` added and set to the current date/time. The `date` should indicate when the information was documented by the author, but the NEMSIS document contains no information about when the original document was created or modified.
* **author (software)**
  If `authoringDevice` is not provided in the config, information from `author` in the config is used along with `eRecord.SoftwareApplicationGroup` in the NEMSIS document for `authoringDevice`.
* **custodian**
  Uses the `custodian` information from the config file.
* **documentationOf/serviceEvent**
* **componentOf/encompassingEncounter**
  For both `serviceEvent` and `encompassingEncounter`, the transformation uses the first recorded value from the following prioritized list for `effectiveTime/low`:
  * `eTimes.07 - Arrived at Patient Date/Time`
  * `eTimes.06 - Unit Arrived on Scene Date/Time`
  * `eTimes.05 - Unit En Route Date/Time`
  * `eTimes.04 - Dispatch Acknowledged Date/Time`
  * `eTimes.03 - Unit Notified by Dispatch Date/Time`

  For both `serviceEvent` and `encompassingEncounter`, the transformation uses the first recorded value from the following prioritized list for `effectiveTime/high`:
  * `eTimes.12 - Destination Patient Transfer of Care Date/Time`
  * `eTimes.11 - Patient Arrived at Destination Date/Time`
  * `eTimes.10 - Arrival at Destination Landing Area Date/Time`
  * `eTimes.08 - Transfer of EMS Patient Care Date/Time`
  * `eTimes.13 - Unit Back in Service Date/Time`
  * **code**
    Uses `FLD` ("field"). Even if the EMS incident location type was the patient's home or a healthcare facility, the transformation assumes that the patient was transported, so at least part, if not all, of the EMS encounter was in the field.
* **component/nonXMLBody**: See "Non-XML Body" below.

### Patient

* **id**
  The following IDs are used from the NEMSIS document:
  * `ePatient.01 - EMS Patient ID`
  * `ePatient.12 - Social Security Number`
  * `ePatient.21 - Driver's License Number`
* **addr**
  * **streetAddressLine**
  * **city**
    NEMSIS uses GNIS. HL7 uses text. The transformation uses a web service call to decode from GNIS. (See "Terminology Mapping" below.)
  * **state**
  * **postalCode**
  * **country**
* **telecom**
* **patient**
  * **name**
    * **given**
    * **family**
    * **suffix**
  * **administrativeGenderCode**
    NEMSIS transgender codes are mapped to HL7 code `UN` ("Undifferentiated").
  * **birthTime**
  * **raceCode**
    Select the first instance of `ePatient.14 - Race` (except "Hispanic or Latino", which maps to `ethnicGroupCode` in HL7).
  * **sdtc:raceCode**
  * **ethnicGroupCode**
    If "Hispanic or Latino" is recorded in `ePatient.14 - Race`, it is used. If at least one value is recorded `ePatient,.14 - Race` but not "Hispanic or Latino", assume "Not Hispanic or Latino". Otherwise, assume "No Information".
  * **languageCommunication**

### Non-XML Body

The unstructured document content must be provided in `eOther.FileGroup` in the NEMSIS document.

The transformation uses the first instance of `eOther.FileGroup` within `PatientCareReport/eOther` where `eOther.09 - External Electronic Document Type` is `4509027` ("ePCR").

`eOther.10 - File Attachment Type` should be a value on the HL7 `mediaType` list (see https://vsac.nlm.nih.gov/valueset/2.16.840.1.113883.11.20.7.1/expansion/Latest).

`eOther.11 - File Attachment Image` should be a base64-encoded viewable rendering of the PCR in the format indicated in `eOther.10 - File Attachment Type`.

### Terminology Mapping

The transformation includes a terminology function named `gnis` to look up NEMSIS GNIS place codes (used for city) and return the place name. If you have access to a GNIS lookup service, edit this function to implement API calls. The function should accept a GNIS place code and return the place name as a string. This reference implementation uses the NEMSIS GNIS web service.
