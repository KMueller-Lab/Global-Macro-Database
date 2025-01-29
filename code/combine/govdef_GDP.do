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
splice, priority(IMF_WEO IMF_GFS EUS OECD_EO AMF BCEAO FRANC_ZONE IMF_FPP CEPAC ADB AFDB CS1 CS2 FZ Mitchell) generate(govdef_GDP) varname(govdef_GDP) base_year(2018) method("none")



