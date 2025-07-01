* ==============================================================================
* GLOBAL MACRO PROJECT
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* Constructing investment series (in % of GDP)
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
splice, priority(OECD_EO EUS WDI ADB AMF BCEAO WDI_ARC AMECO IMF_WEO IMF_IFS UN CS1 CS2 CS3 AHSTAT JST JO CEPAC FRANC_ZONE Mitchell IMF_WEO_forecast) generate(inv_GDP) varname(inv_GDP) base_year(2018) method("chainlink")


