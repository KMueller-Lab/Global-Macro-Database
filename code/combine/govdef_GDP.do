* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* CONSTRUCING GOVERNMENT DEFICIT TO GDP
* 
* Created: 
* 2024-06-28
* 
* Author:
* Mohamed Lehbib
* National University of Singapore
* 	
* ==============================================================================

* Clear the panel
clear

* Create temporary file to store the data
tempfile temp_master
save `temp_master', replace emptyok

* Open the data
use "$data_final/clean_data_wide", clear

* ==============================================================================
* Specify country specific priority ordering.
* ==============================================================================
* Set up the priority list
splice, priority(EUS OECD_EO AMF BCEAO IMF_WEO FRANC_ZONE IMF_GFS IMF_FPP CEPAC ADB AFDB CS1 CS2 FZ Mitchell IMF_WEO_forecast) generate(govdef_GDP) varname(govdef_GDP) base_year(2018) method("none")


* ==============================================================================
* Derive government deficit levels using our spliced ratio series and GDP
* ==============================================================================

use "$data_final/chainlinked_govdef_GDP", clear

* Merge GDP series 
merge 1:1 ISO3 year using "$data_final/chainlinked_nGDP", nogen keepus(nGDP) 

* Compute the level series 
gen GMD_estimated_govdef = (govdef_GDP * nGDP) / 100
keep ISO3 year GMD_estimated_govdef

* Add raw data of government revenue
merge 1:1 ISO3 year using "$data_final/clean_data_wide", nogen

* Splice government revenue series and use our GMD_estimated as the first priority
splice, priority(GMD_estimated EUS OECD_EO AMF BCEAO IMF_WEO FRANC_ZONE CEPAC ADB AFDB CS1 CS2 FZ  HFS IMF_WEO_forecast) generate(govdef) varname(govdef) base_year(2018) method("none")

















