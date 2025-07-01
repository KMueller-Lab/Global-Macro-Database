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
splice, priority(OECD_EO EUS AMECO WDI UN FAO BCEAO WDI_ARC OECD_QNA IMF_IFS CS1 CS2 CS3 AHSTAT Mitchell JO HFS) generate(finv) varname(finv) base_year(2018) method("chainlink")



