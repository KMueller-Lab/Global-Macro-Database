* ==============================================================================
* GLOBAL MACRO PROJECT
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* Constructing government debt
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
* Add notes on definitional differences in government debt.
* ==============================================================================

gmdaddnote_source WDI_ARC "Data refers to central government." govdebt_GDP
gmdaddnote_source WDI 	  "Data refers to central government." govdebt_GDP
gmdaddnote_source JST 	  "Data refers to both central and general governments." govdebt_GDP
gmdaddnote_source FZ	  "Data refers to general government." govdebt_GDP
gmdaddnote_source NBS	  "Data refers to both central and general governments." govdebt_GDP
gmdaddnote_source CEPAC   "Data refers to external debt." govdebt_GDP
gmdaddnote_source IMF_WEO "Data refers to general government." govdebt_GDP
gmdaddnote_source IMF_HDD "Data refers to general government." govdebt_GDP
gmdaddnote_source IMF_FPP "Data refers to general government." govdebt_GDP
gmdaddnote_source IMF_GDD "Data refers to central government." govdebt_GDP
gmdaddnote_source OECD_EO "Data refers to general government." govdebt_GDP

* ==============================================================================
* Specify country specific priority ordering.
* ==============================================================================

* Set up the priority list
splice, priority(IMF_GDD IMF_FPP AFRISTAT OECD_EO IMF_WEO CS1 CS2 JST FZ IMF_HDD RR_debt  NBS CEPAC BORDO WDI WDI_ARC IMF_WEO_forecast) generate(govdebt_GDP) varname(govdebt_GDP) base_year(2018) method("none")


* ==============================================================================
* Derive government debt levels using our spliced ratio series and GDP
* ==============================================================================

use "$data_final/chainlinked_govdebt_GDP", clear

* Merge GDP series 
merge 1:1 ISO3 year using "$data_final/chainlinked_nGDP", nogen keepus(nGDP) 

* Compute the level series 
gen GMD_estimated_govdebt = (govdebt_GDP * nGDP) / 100
keep ISO3 year GMD_estimated_govdebt

* Add raw data of government revenue
merge 1:1 ISO3 year using "$data_final/clean_data_wide", nogen

* Splice government revenue series and use our GMD_estimated as the first priority
splice, priority(GMD_estimated IMF_GDD AFRISTAT OECD_EO IMF_WEO CS1 CS2 JST FZ NBS CEPAC BORDO WDI WDI_ARC HFS IMF_WEO_forecast) generate(govdebt) varname(govdebt) base_year(2018) method("none")




