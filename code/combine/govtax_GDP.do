* ==============================================================================
* GLOBAL MACRO PROJECT
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* Constructing government taxes
* 
* Created: 
* 2024-06-28
* 
* Author:
* Mohamed Lehbib
* National University of Singapore
* 	
* ==============================================================================

* ==============================================================================
* Open the data
use "$data_final/clean_data_wide", clear

* ==============================================================================
* Add notes on definitional differences in government expenditure.
* ==============================================================================

gmdaddnote_source WDI_ARC  "Data refers to central government." govtax_GDP
gmdaddnote_source WDI 	   "Data refers to central government." govtax_GDP
gmdaddnote_source NBS	   "Data refers to both central and general governments." govtax_GDP
gmdaddnote_source IMF_GFS  "Data refers to central government." govtax_GDP
gmdaddnote_source OECD_EO  "Data refers to general government." govtax_GDP
gmdaddnote_source AMF 	   "Data refers to general government." govtax_GDP
gmdaddnote_source AFRISTAT "Data refers to general government." govtax_GDP
gmdaddnote_source BCEAO    "Data refers to general government." govtax_GDP
gmdaddnote_source ADB 	   "Data refers to general government." govtax_GDP
gmdaddnote_source AHSTAT   "Data refers to central government." govtax_GDP
gmdaddnote_source HFS 	   "Data refers to central government." govtax_GDP
gmdaddnote_source Mitchell "Data refers to central government." govtax_GDP
gmdaddnote_source EUS 	   "Data refers to general government." govtax_GDP
gmdaddnote_source JERVEN   "Data refers to general government." govtax_GDP
gmdaddnote_source MD  	   "Data refers to general government." govtax_GDP
gmdaddnote_source CS1_CAN "Data refers to central government." govtax_GDP
gmdaddnote_source CS1_PRT "Data refers to central government." govtax_GDP
gmdaddnote_source CS1_USA "Data refers to central government." govtax_GDP
gmdaddnote_source CS1_ZAF "Data refers to central government." govtax_GDP
gmdaddnote_source CS2_ISL "Data refers to general government." govtax_GDP


* ==============================================================================
* Specify country specific priority ordering.
* ==============================================================================

* Set up the priority list
splice, priority(AFRISTAT AMF BCEAO EUS OECD_EO WDI WDI_ARC CS1 CS2 NBS ADB AHSTAT Mitchell AHSTAT MD) generate(govtax_GDP) varname(govtax_GDP) method("none") base_year(2017)



