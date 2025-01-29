* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* Constructing government revenues
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
* Add notes on definitional differences in government revenue.
* ==============================================================================

gmdaddnote_source WDI_ARC  "Data refers to general government." govrev
gmdaddnote_source WDI 	   "Data refers to general government." govrev
gmdaddnote_source JST 	   "Data refers to central government." govrev
gmdaddnote_source FZ	   "Data refers to general government." govrev
gmdaddnote_source NBS	   "Data refers to both central and general governments." govrev
gmdaddnote_source CEPAC    "Data refers to general government." govrev
gmdaddnote_source IMF_WEO  "Data refers to general government." govrev
gmdaddnote_source IMF_GFS  "Data refers to central government." govrev
gmdaddnote_source OECD_EO  "Data refers to general government." govrev
gmdaddnote_source AMF 	   "Data refers to general government." govrev
gmdaddnote_source AFRISTAT "Data refers to general government." govrev
gmdaddnote_source AFDB 	   "Data refers to general government." govrev
gmdaddnote_source BCEAO    "Data refers to general government." govrev
gmdaddnote_source ADB 	   "Data refers to general government." govrev
gmdaddnote_source AHSTAT   "Data refers to central government." govrev
gmdaddnote_source HFS 	   "Data refers to central government." govrev
gmdaddnote_source Mitchell "Data refers to central government." govrev
gmdaddnote_source EUS 	   "Data refers to general government." govrev
gmdaddnote_source JERVEN   "Data refers to general government." govrev

* ==============================================================================
* Specify country specific priority ordering.
* ==============================================================================
* Set up the priority list
splice, priority(IMF_WEO  AMF BCEAO AFRISTAT IMF_GFS EUS OECD_EO WDI AFDB ADB CS1 CS2 JST CEPAC AHSTAT JERVEN Mitchell HFS NBS FZ) generate(govrev) varname(govrev) base_year(2018) method("chainlink")



