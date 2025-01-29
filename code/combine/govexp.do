* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* Constructing government expenditures
* 
* Created: 
* 2024-06-28
* 
* Author:
* Mohamed Lehbib
* National University of Singapore
* 	
* ==============================================================================

* Open the data
use "$data_final/clean_data_wide", clear

* ==============================================================================
* Add notes on definitional differences in government expenditure.
* ==============================================================================

gmdaddnote_source WDI_ARC  "Data refers to general government." govexp
gmdaddnote_source WDI 	   "Data refers to general government." govexp
gmdaddnote_source JST 	   "Data refers to central government." govexp
gmdaddnote_source FZ	   "Data refers to general government." govexp
gmdaddnote_source NBS	   "Data refers to both central and general governments." govexp
gmdaddnote_source CEPAC    "Data refers to general government." govexp
gmdaddnote_source IMF_WEO  "Data refers to general government." govexp
gmdaddnote_source MD       "Data refers to central government." govexp
gmdaddnote_source OECD_EO  "Data refers to general government." govexp
gmdaddnote_source AMF 	   "Data refers to general government." govexp
gmdaddnote_source AFRISTAT "Data refers to general government." govexp
gmdaddnote_source AFDB 	   "Data refers to general government." govexp
gmdaddnote_source BCEAO    "Data refers to general government." govexp
gmdaddnote_source ADB 	   "Data refers to general government." govexp
gmdaddnote_source AHSTAT   "Data refers to central government." govexp
gmdaddnote_source HFS 	   "Data refers to central government." govexp
gmdaddnote_source Mitchell "Data refers to central government." govexp
gmdaddnote_source EUS 	   "Data refers to general government." govexp
gmdaddnote_source CS1_GBR  "Data refers to general government." govexp
gmdaddnote_source CS1_LBR  "Data refers to central government." govexp
gmdaddnote_source CS1_POL  "Data refers to general government." govexp
gmdaddnote_source CS1_CAN  "Data refers to central government." govexp
gmdaddnote_source CS1_PRT  "Data refers to central government." govexp
gmdaddnote_source CS1_CHN  "Data refers to general government." govexp
gmdaddnote_source CS1_USA  "Data refers to central government." govexp
gmdaddnote_source CS1_SWE  "Data refers to central government." govexp
gmdaddnote_source CS1_ZAF  "Data refers to central government." govexp
gmdaddnote_source CS2_ISL  "Data refers to general government." govexp
gmdaddnote_source CS2_AUS  "Data refers to general government." govexp
gmdaddnote_source CS2_NOR  "Data refers to general government." govexp


* ==============================================================================
* Specify country specific priority ordering.
* ==============================================================================
* Set up the priority list
splice, priority(IMF_WEO EUS AFRISTAT AMF BCEAO IMF_GFS WDI OECD_EO CS1 CS2 JST NBS CEPAC ADB AFDB Mitchell HFS AHSTAT) generate(govexp) varname(govexp) method("chainlink") base_year(2018)



