<?xml version="1.0" encoding="UTF-8"?>

<!--

Mappings

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
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:key name="code" match="*" use="@hl7"/>


  <!-- #Mapping Variables# -->

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

  <!-- Gender -->
  <!-- HL7 administrativeGenderCode, value set 2.16.840.1.113883.1.11.1 -->
  <xsl:variable name="gender">
    <code hl7="F" nemsis="9906001" hl7Desc="Female" nemsisDesc="Female"/>
    <code hl7="M" nemsis="9906003" hl7Desc="Male" nemsisDesc="Male"/>
    <code hl7="UN" nemsis="9906005" hl7Desc="Undifferentiated" nemsisDesc="Unknown (Unable to Determine)"/>
  </xsl:variable>

  <!-- Language -->
  <!-- HL7 Language, value set 2.16.840.1.113883.1.11.11526 -->
  <!-- This supports mapping from ISO-639-1 (two-character codes) and ISO-639-2 (three-character 
       codes, both "B" [bibliographic] and "T" [terminology] codes) to the codes that are supported 
       by NEMSIS. -->
  <xsl:variable name="language">
    <code hl7="am" nemsis="amh" hl7Desc="Amharic" nemsisDesc="Amharic"/>
    <code hl7="amh" nemsis="amh" hl7Desc="Amharic" nemsisDesc="Amharic"/>
    <code hl7="ar" nemsis="ara" hl7Desc="Arabic" nemsisDesc="Arabic"/>
    <code hl7="ara" nemsis="ara" hl7Desc="Arabic" nemsisDesc="Arabic"/>
    <code hl7="arm" nemsis="arm" hl7Desc="Armenian" nemsisDesc="Armenian"/>
    <code hl7="hy" nemsis="arm" hl7Desc="Armenian" nemsisDesc="Armenian"/>
    <code hl7="hye" nemsis="arm" hl7Desc="Armenian" nemsisDesc="Armenian"/>
    <code hl7="ben" nemsis="ben" hl7Desc="Bengali" nemsisDesc="Bengali"/>
    <code hl7="bn" nemsis="ben" hl7Desc="Bengali" nemsisDesc="Bengali"/>
    <code hl7="chi" nemsis="chi" hl7Desc="Chinese" nemsisDesc="Chinese"/>
    <code hl7="zh" nemsis="chi" hl7Desc="Chinese" nemsisDesc="Chinese"/>
    <code hl7="zho" nemsis="chi" hl7Desc="Chinese" nemsisDesc="Chinese"/>
    <code hl7="cpf" nemsis="cpf" hl7Desc="Creoles and pidgins, French-based" nemsisDesc="French Creole"/>
    <code hl7="crp" nemsis="crp" hl7Desc="Creoles and pidgins" nemsisDesc="Cajun (Creole and Pidgins)"/>
    <code hl7="ces" nemsis="cze" hl7Desc="Czech" nemsisDesc="Czech"/>
    <code hl7="cs" nemsis="cze" hl7Desc="Czech" nemsisDesc="Czech"/>
    <code hl7="cze" nemsis="cze" hl7Desc="Czech" nemsisDesc="Czech"/>
    <code hl7="da" nemsis="dan" hl7Desc="Danish" nemsisDesc="Danish"/>
    <code hl7="dan" nemsis="dan" hl7Desc="Danish" nemsisDesc="Danish"/>
    <code hl7="dut" nemsis="dut" hl7Desc="Dutch; Flemish" nemsisDesc="Dutch"/>
    <code hl7="nl" nemsis="dut" hl7Desc="Dutch; Flemish" nemsisDesc="Dutch"/>
    <code hl7="nld" nemsis="dut" hl7Desc="Dutch; Flemish" nemsisDesc="Dutch"/>
    <code hl7="en" nemsis="eng" hl7Desc="English" nemsisDesc="English"/>
    <code hl7="eng" nemsis="eng" hl7Desc="English" nemsisDesc="English"/>
    <code hl7="fi" nemsis="fin" hl7Desc="Finnish" nemsisDesc="Finnish"/>
    <code hl7="fin" nemsis="fin" hl7Desc="Finnish" nemsisDesc="Finnish"/>
    <code hl7="fr" nemsis="fre" hl7Desc="French" nemsisDesc="French"/>
    <code hl7="fra" nemsis="fre" hl7Desc="French" nemsisDesc="French"/>
    <code hl7="fre" nemsis="fre" hl7Desc="French" nemsisDesc="French"/>
    <code hl7="gem" nemsis="gem" hl7Desc="Germanic languages" nemsisDesc="Pennsylvania Dutch (Germanic Other)"/>
    <code hl7="de" nemsis="ger" hl7Desc="German" nemsisDesc="German"/>
    <code hl7="deu" nemsis="ger" hl7Desc="German" nemsisDesc="German"/>
    <code hl7="ger" nemsis="ger" hl7Desc="German" nemsisDesc="German"/>
    <code hl7="el" nemsis="gre" hl7Desc="Greek, Modern (1453-)" nemsisDesc="Greek"/>
    <code hl7="ell" nemsis="gre" hl7Desc="Greek, Modern (1453-)" nemsisDesc="Greek"/>
    <code hl7="gre" nemsis="gre" hl7Desc="Greek, Modern (1453-)" nemsisDesc="Greek"/>
    <code hl7="gu" nemsis="guj" hl7Desc="Gujarati" nemsisDesc="Gujarati"/>
    <code hl7="guj" nemsis="guj" hl7Desc="Gujarati" nemsisDesc="Gujarati"/>
    <code hl7="he" nemsis="heb" hl7Desc="Hebrew" nemsisDesc="Hebrew"/>
    <code hl7="heb" nemsis="heb" hl7Desc="Hebrew" nemsisDesc="Hebrew"/>
    <code hl7="hi" nemsis="hin" hl7Desc="Hindi" nemsisDesc="Hindi (Urdu)"/>
    <code hl7="hin" nemsis="hin" hl7Desc="Hindi" nemsisDesc="Hindi (Urdu)"/>
    <code hl7="hmn" nemsis="hmn" hl7Desc="Hmong; Mong" nemsisDesc="Miao (Hmong)"/>
    <code hl7="hr" nemsis="hrv" hl7Desc="Croatian" nemsisDesc="Croatian"/>
    <code hl7="hrv" nemsis="hrv" hl7Desc="Croatian" nemsisDesc="Croatian"/>
    <code hl7="hu" nemsis="hun" hl7Desc="Hungarian" nemsisDesc="Hungarian"/>
    <code hl7="hun" nemsis="hun" hl7Desc="Hungarian" nemsisDesc="Hungarian"/>
    <code hl7="ilo" nemsis="ilo" hl7Desc="Iloko" nemsisDesc="Ilocano"/>
    <code hl7="it" nemsis="itl" hl7Desc="Italian" nemsisDesc="Italian"/>
    <code hl7="ita" nemsis="itl" hl7Desc="Italian" nemsisDesc="Italian"/>
    <code hl7="ja" nemsis="jpn" hl7Desc="Japanese" nemsisDesc="Japanese"/>
    <code hl7="jpn" nemsis="jpn" hl7Desc="Japanese" nemsisDesc="Japanese"/>
    <code hl7="ko" nemsis="kor" hl7Desc="Korean" nemsisDesc="Korean"/>
    <code hl7="kor" nemsis="kor" hl7Desc="Korean" nemsisDesc="Korean"/>
    <code hl7="kro" nemsis="kro" hl7Desc="Kru languages" nemsisDesc="Kru"/>
    <code hl7="lit" nemsis="lit" hl7Desc="Lithuanian" nemsisDesc="Lithuanian"/>
    <code hl7="lt" nemsis="lit" hl7Desc="Lithuanian" nemsisDesc="Lithuanian"/>
    <code hl7="mal" nemsis="mal" hl7Desc="Malayalam" nemsisDesc="Malayalam"/>
    <code hl7="ml" nemsis="mal" hl7Desc="Malayalam" nemsisDesc="Malayalam"/>
    <code hl7="mkh" nemsis="mkh" hl7Desc="Mon-Khmer languages" nemsisDesc="Mon-Khmer (Cambodian)"/>
    <code hl7="nav" nemsis="nav" hl7Desc="Navajo; Navaho" nemsisDesc="Navaho"/>
    <code hl7="nv" nemsis="nav" hl7Desc="Navajo; Navaho" nemsisDesc="Navaho"/>
    <code hl7="nn" nemsis="nno" hl7Desc="Norwegian Nynorsk; Nynorsk, Norwegian" nemsisDesc="Norwegian"/>
    <code hl7="nno" nemsis="nno" hl7Desc="Norwegian Nynorsk; Nynorsk, Norwegian" nemsisDesc="Norwegian"/>
    <code hl7="pa" nemsis="pan" hl7Desc="Panjabi; Punjabi" nemsisDesc="Panjabi"/>
    <code hl7="pan" nemsis="pan" hl7Desc="Panjabi; Punjabi" nemsisDesc="Panjabi"/>
    <code hl7="fa" nemsis="per" hl7Desc="Persian" nemsisDesc="Persian"/>
    <code hl7="fas" nemsis="per" hl7Desc="Persian" nemsisDesc="Persian"/>
    <code hl7="per" nemsis="per" hl7Desc="Persian" nemsisDesc="Persian"/>
    <code hl7="pl" nemsis="pol" hl7Desc="Polish" nemsisDesc="Polish"/>
    <code hl7="pol" nemsis="pol" hl7Desc="Polish" nemsisDesc="Polish"/>
    <code hl7="por" nemsis="por" hl7Desc="Portuguese" nemsisDesc="Portuguese"/>
    <code hl7="pt" nemsis="por" hl7Desc="Portuguese" nemsisDesc="Portuguese"/>
    <code hl7="ro" nemsis="rum" hl7Desc="Romanian; Moldavian; Moldovan" nemsisDesc="Romanian"/>
    <code hl7="ron" nemsis="rum" hl7Desc="Romanian; Moldavian; Moldovan" nemsisDesc="Romanian"/>
    <code hl7="rum" nemsis="rum" hl7Desc="Romanian; Moldavian; Moldovan" nemsisDesc="Romanian"/>
    <code hl7="ru" nemsis="rus" hl7Desc="Russian" nemsisDesc="Russian"/>
    <code hl7="rus" nemsis="rus" hl7Desc="Russian" nemsisDesc="Russian"/>
    <code hl7="sgn" nemsis="sgn" hl7Desc="Sign Languages" nemsisDesc="Sign Languages"/>
    <code hl7="sk" nemsis="slo" hl7Desc="Slovak" nemsisDesc="Slovak"/>
    <code hl7="slk" nemsis="slo" hl7Desc="Slovak" nemsisDesc="Slovak"/>
    <code hl7="slo" nemsis="slo" hl7Desc="Slovak" nemsisDesc="Slovak"/>
    <code hl7="sm" nemsis="smo" hl7Desc="Samoan" nemsisDesc="Samoan"/>
    <code hl7="smo" nemsis="smo" hl7Desc="Samoan" nemsisDesc="Samoan"/>
    <code hl7="es" nemsis="spa" hl7Desc="Spanish; Castilian" nemsisDesc="Spanish"/>
    <code hl7="spa" nemsis="spa" hl7Desc="Spanish; Castilian" nemsisDesc="Spanish"/>
    <code hl7="sr" nemsis="srp" hl7Desc="Serbian" nemsisDesc="Serbo-Croatian"/>
    <code hl7="srp" nemsis="srp" hl7Desc="Serbian" nemsisDesc="Serbo-Croatian"/>
    <code hl7="sv" nemsis="swe" hl7Desc="Swedish" nemsisDesc="Swedish"/>
    <code hl7="swe" nemsis="swe" hl7Desc="Swedish" nemsisDesc="Swedish"/>
    <code hl7="syr" nemsis="syr" hl7Desc="Syriac" nemsisDesc="Syriac"/>
    <code hl7="tai" nemsis="tai" hl7Desc="Tai languages" nemsisDesc="Formosan"/>
    <code hl7="tgl" nemsis="tgl" hl7Desc="Tagalog" nemsisDesc="Tagalog"/>
    <code hl7="tl" nemsis="tgl" hl7Desc="Tagalog" nemsisDesc="Tagalog"/>
    <code hl7="th" nemsis="tha" hl7Desc="Thai" nemsisDesc="Thai (Laotian)"/>
    <code hl7="tha" nemsis="tha" hl7Desc="Thai" nemsisDesc="Thai (Laotian)"/>
    <code hl7="tr" nemsis="tur" hl7Desc="Turkish" nemsisDesc="Turkish"/>
    <code hl7="tur" nemsis="tur" hl7Desc="Turkish" nemsisDesc="Turkish"/>
    <code hl7="uk" nemsis="ukr" hl7Desc="Ukrainian" nemsisDesc="Ukrainian"/>
    <code hl7="ukr" nemsis="ukr" hl7Desc="Ukrainian" nemsisDesc="Ukrainian"/>
    <code hl7="vi" nemsis="vie" hl7Desc="Vietnamese" nemsisDesc="Vietnamese"/>
    <code hl7="vie" nemsis="vie" hl7Desc="Vietnamese" nemsisDesc="Vietnamese"/>
    <code hl7="yi" nemsis="yid" hl7Desc="Yiddish" nemsisDesc="Yiddish"/>
    <code hl7="yid" nemsis="yid" hl7Desc="Yiddish" nemsisDesc="Yiddish"/>
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

  <!-- Race -->
  <!-- HL7 raceCode, value set 2.16.840.1.113883.3.2074.1.1.3 -->
  <xsl:variable name="race">
    <code hl7="1002-5" nemsis="2514001" hl7Desc="American Indian or Alaska Native" nemsisDesc="American Indian or Alaska Native"/>
    <code hl7="2028-9" nemsis="2514003" hl7Desc="Asian" nemsisDesc="Asian"/>
    <code hl7="2054-5" nemsis="2514005" hl7Desc="Black or African American" nemsisDesc="Black or African American"/>
    <code hl7="2076-8" nemsis="2514009" hl7Desc="Native Hawaiian or Other Pacific Islander" nemsisDesc="Native Hawaiian or Other Pacific Islander"/>
    <code hl7="2106-3" nemsis="2514011" hl7Desc="White" nemsisDesc="White"/>
  </xsl:variable>

  <!-- Sex -->
  <!-- HL7 Sex, value set 2.16.840.1.113762.1.4.1240.3 -->
  <!-- HL7 ONC Administrative Sex, value set 2.16.840.1.113762.1.4.1 -->
  <xsl:variable name="sex">
    <code hl7="F" nemsis="9919001" hl7Desc="Female" nemsisDesc="Female"/>
    <code hl7="M" nemsis="9919003" hl7Desc="Male" nemsisDesc="Male"/>
    <code hl7="asked-declined" nemsis="8801019" hl7Desc="Asked But Declined" nemsisDesc="Refused"/>
    <code hl7="184115007" nemsis="9919005" hl7Desc="Patient sex unknown (finding)" nemsisDesc="Unknown"/>
    <code hl7="248152002" nemsis="9919001" hl7Desc="Female (finding)" nemsisDesc="Female"/>
    <code hl7="248153007" nemsis="9919003" hl7Desc="Male (finding)" nemsisDesc="Male"/>
  </xsl:variable>

  <!-- State -->
  <!-- HL7  StateValueSet, value set 2.16.840.1.113883.3.88.12.80.1 -->
  <!-- No authoritative source in HL7; using postal abbreviations. -->
  <xsl:variable name="state">
    <code hl7="AL" nemsis="01" hl7desc="Alabama" nemsisDesc="Alabama"/>
    <code hl7="AK" nemsis="02" hl7desc="Alaska" nemsisDesc="Alaska"/>
    <code hl7="AZ" nemsis="04" hl7desc="Arizona" nemsisDesc="Arizona"/>
    <code hl7="AR" nemsis="05" hl7desc="Arkansas" nemsisDesc="Arkansas"/>
    <code hl7="CA" nemsis="06" hl7desc="California" nemsisDesc="California"/>
    <code hl7="CO" nemsis="08" hl7desc="Colorado" nemsisDesc="Colorado"/>
    <code hl7="CT" nemsis="09" hl7desc="Connecticut" nemsisDesc="Connecticut"/>
    <code hl7="DE" nemsis="10" hl7desc="Delaware" nemsisDesc="Delaware"/>
    <code hl7="DC" nemsis="11" hl7desc="District of Columbia" nemsisDesc="District of Columbia"/>
    <code hl7="FL" nemsis="12" hl7desc="Florida" nemsisDesc="Florida"/>
    <code hl7="GA" nemsis="13" hl7desc="Georgia" nemsisDesc="Georgia"/>
    <code hl7="HI" nemsis="15" hl7desc="Hawaii" nemsisDesc="Hawaii"/>
    <code hl7="ID" nemsis="16" hl7desc="Idaho" nemsisDesc="Idaho"/>
    <code hl7="IL" nemsis="17" hl7desc="Illinois" nemsisDesc="Illinois"/>
    <code hl7="IN" nemsis="18" hl7desc="Indiana" nemsisDesc="Indiana"/>
    <code hl7="IA" nemsis="19" hl7desc="Iowa" nemsisDesc="Iowa"/>
    <code hl7="KS" nemsis="20" hl7desc="Kansas" nemsisDesc="Kansas"/>
    <code hl7="KY" nemsis="21" hl7desc="Kentucky" nemsisDesc="Kentucky"/>
    <code hl7="LA" nemsis="22" hl7desc="Louisiana" nemsisDesc="Louisiana"/>
    <code hl7="ME" nemsis="23" hl7desc="Maine" nemsisDesc="Maine"/>
    <code hl7="MD" nemsis="24" hl7desc="Maryland" nemsisDesc="Maryland"/>
    <code hl7="MA" nemsis="25" hl7desc="Massachusetts" nemsisDesc="Massachusetts"/>
    <code hl7="MI" nemsis="26" hl7desc="Michigan" nemsisDesc="Michigan"/>
    <code hl7="MN" nemsis="27" hl7desc="Minnesota" nemsisDesc="Minnesota"/>
    <code hl7="MS" nemsis="28" hl7desc="Mississippi" nemsisDesc="Mississippi"/>
    <code hl7="MO" nemsis="29" hl7desc="Missouri" nemsisDesc="Missouri"/>
    <code hl7="MT" nemsis="30" hl7desc="Montana" nemsisDesc="Montana"/>
    <code hl7="NE" nemsis="31" hl7desc="Nebraska" nemsisDesc="Nebraska"/>
    <code hl7="NV" nemsis="32" hl7desc="Nevada" nemsisDesc="Nevada"/>
    <code hl7="NH" nemsis="33" hl7desc="New Hampshire" nemsisDesc="New Hampshire"/>
    <code hl7="NJ" nemsis="34" hl7desc="New Jersey" nemsisDesc="New Jersey"/>
    <code hl7="NM" nemsis="35" hl7desc="New Mexico" nemsisDesc="New Mexico"/>
    <code hl7="NY" nemsis="36" hl7desc="New York" nemsisDesc="New York"/>
    <code hl7="NC" nemsis="37" hl7desc="North Carolina" nemsisDesc="North Carolina"/>
    <code hl7="ND" nemsis="38" hl7desc="North Dakota" nemsisDesc="North Dakota"/>
    <code hl7="OH" nemsis="39" hl7desc="Ohio" nemsisDesc="Ohio"/>
    <code hl7="OK" nemsis="40" hl7desc="Oklahoma" nemsisDesc="Oklahoma"/>
    <code hl7="OR" nemsis="41" hl7desc="Oregon" nemsisDesc="Oregon"/>
    <code hl7="PA" nemsis="42" hl7desc="Pennsylvania" nemsisDesc="Pennsylvania"/>
    <code hl7="RI" nemsis="44" hl7desc="Rhode Island" nemsisDesc="Rhode Island"/>
    <code hl7="SC" nemsis="45" hl7desc="South Carolina" nemsisDesc="South Carolina"/>
    <code hl7="SD" nemsis="46" hl7desc="South Dakota" nemsisDesc="South Dakota"/>
    <code hl7="TN" nemsis="47" hl7desc="Tennessee" nemsisDesc="Tennessee"/>
    <code hl7="TX" nemsis="48" hl7desc="Texas" nemsisDesc="Texas"/>
    <code hl7="UT" nemsis="49" hl7desc="Utah" nemsisDesc="Utah"/>
    <code hl7="VT" nemsis="50" hl7desc="Vermont" nemsisDesc="Vermont"/>
    <code hl7="VA" nemsis="51" hl7desc="Virginia" nemsisDesc="Virginia"/>
    <code hl7="WA" nemsis="53" hl7desc="Washington" nemsisDesc="Washington"/>
    <code hl7="WV" nemsis="54" hl7desc="West Virginia" nemsisDesc="West Virginia"/>
    <code hl7="WI" nemsis="55" hl7desc="Wisconsin" nemsisDesc="Wisconsin"/>
    <code hl7="WY" nemsis="56" hl7desc="Wyoming" nemsisDesc="Wyoming"/>
    <code hl7="AS" nemsis="60" hl7desc="American Samoa" nemsisDesc="American Samoa"/>
    <code hl7="FM" nemsis="64" hl7desc="Federated States of Micronesia" nemsisDesc="Federated States of Micronesia"/>
    <code hl7="GU" nemsis="66" hl7desc="Guam" nemsisDesc="Guam"/>
    <code hl7="MH" nemsis="68" hl7desc="Marshall Islands" nemsisDesc="Marshall Islands"/>
    <code hl7="MP" nemsis="69" hl7desc="Northern Mariana Islands" nemsisDesc="Northern Mariana Islands"/>
    <code hl7="PW" nemsis="70" hl7desc="Palau" nemsisDesc="Palau"/>
    <code hl7="PR" nemsis="72" hl7desc="Puerto Rico" nemsisDesc="Puerto Rico"/>
    <code hl7="UM" nemsis="74" hl7desc="US Minor Outlying Islands" nemsisDesc="US Minor Outlying Islands"/>
    <code hl7="VI" nemsis="78" hl7desc="US Virgin Islands" nemsisDesc="US Virgin Islands"/>
  </xsl:variable>


</xsl:stylesheet>