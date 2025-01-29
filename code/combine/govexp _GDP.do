* ==============================================================================
* GLOBAL MACRO PROJECT
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* Constructing government expenditures (in % GDP)
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

gmdaddnote_source WDI_ARC  "Data refers to general government." govexp_GDP
gmdaddnote_source WDI 	   "Data refers to general government." govexp_GDP
gmdaddnote_source JST 	   "Data refers to central government." govexp_GDP
gmdaddnote_source FZ	   "Data refers to general government." govexp_GDP
gmdaddnote_source NBS	   "Data refers to both central and general governments." govexp_GDP
gmdaddnote_source CEPAC    "Data refers to general government." govexp_GDP
gmdaddnote_source IMF_WEO  "Data refers to general government." govexp_GDP
gmdaddnote_source IMF_FPP  "Data refers to general government." govexp_GDP
gmdaddnote_source IMF_GFS  "Data refers to central government." govexp_GDP
gmdaddnote_source MD       "Data refers to central government." govexp_GDP
gmdaddnote_source OECD_EO  "Data refers to general government." govexp_GDP
gmdaddnote_source AMF 	   "Data refers to general government." govexp_GDP
gmdaddnote_source AFRISTAT "Data refers to general government." govexp_GDP
gmdaddnote_source AFDB 	   "Data refers to general government." govexp_GDP
gmdaddnote_source BCEAO    "Data refers to general government." govexp_GDP
gmdaddnote_source ADB 	   "Data refers to general government." govexp_GDP
gmdaddnote_source AHSTAT   "Data refers to central government." govexp_GDP
gmdaddnote_source HFS 	   "Data refers to central government." govexp_GDP
gmdaddnote_source Mitchell "Data refers to central government." govexp_GDP
gmdaddnote_source EUS 	   "Data refers to general government." govexp_GDP
gmdaddnote_source JERVEN   "Data refers to general government." govexp_GDP
gmdaddnote_source FLORA    "Data refers to general government." govexp_GDP
gmdaddnote_source  MD  "Data refers to central government." govexp_GDP
gmdaddnote_source CS1_GBR  "Data refers to general government." govexp_GDP
gmdaddnote_source CS1_IDN  "Data refers to general government." govexp_GDP
gmdaddnote_source CS1_POL  "Data refers to general government." govexp_GDP
gmdaddnote_source CS1_CAN  "Data refers to central government." govexp_GDP
gmdaddnote_source CS1_USA  "Data refers to central government." govexp_GDP
gmdaddnote_source CS1_SWE  "Data refers to central government." govexp_GDP
gmdaddnote_source CS1_ZAF  "Data refers to central government." govexp_GDP
gmdaddnote_source CS2_ISL  "Data refers to general government." govexp_GDP
gmdaddnote_source CS2_AUS  "Data refers to general government." govexp_GDP
gmdaddnote_source CS2_NOR  "Data refers to general government." govexp_GDP

* ==============================================================================
* Specify country specific priority ordering.
* ==============================================================================
* Set up the priority list
splice, priority(IMF_WEO EUS AFRISTAT AMF BCEAO WDI OECD_EO CS1 CS2 JST CEPAC ADB AFDB IMF_FPP Mitchell AHSTAT FLORA MD NBS) generate(govexp_GDP) varname(govexp_GDP) method("none") base_year(2018)



