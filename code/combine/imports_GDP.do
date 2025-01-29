* ==============================================================================
* GLOBAL MACRO PROJECT
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* CONSTRUCING imports series (in % of GDP)
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
splice, priority(WDI IMF_WEO OECD_EO EUS ADB AMF BCEAO UN IMF_IFS WDI_ARC AMECO UN CS1 CS2 CS3 JST AHSTAT ) generate(imports_GDP) varname(imports_GDP) base_year(2019) method("chainlink")

