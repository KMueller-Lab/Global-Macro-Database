* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* CONSTRUCT FIXED CAPITAL FORMATION SERIES
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
splice, priority(BCEAO EUS WDI UN OECD_EO OECD_QNA IMF_IFS WDI_ARC FAO AMECO CS1 CS2 CS3 AHSTAT JO HFS Mitchell) generate(finv) varname(finv) base_year(2018) method("chainlink")

