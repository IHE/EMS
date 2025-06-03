<?xml version="1.0" encoding="UTF-8"?>

<!--

Mappings

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

  <xsl:key name="code" match="*" use="@hl7"/>


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