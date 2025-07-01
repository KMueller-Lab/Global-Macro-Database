* ==============================================================================
* GLOBAL MACRO PROJECT
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* Constructing exports series (in % of GDP)
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
splice, priority(OECD_EO EUS UN WDI ADB AMF BCEAO JST WDI_ARC AMECO IMF_IFS IMF_WEO CS1 CS2 CS3 AHSTAT Mitchell NBS IMF_WEO_forecast) generate(exports_GDP) varname(exports_GDP) base_year(2019) method("chainlink")


