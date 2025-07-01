* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* CONSTRUCING INFLATION
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
splice, priority(CS3 OECD_EO WB_CC ADB AMF BIS BCEAO EUS FRANC_ZONE OECD_KEI WDI WDI_ARC IMF_WEO IMF_IFS CS1 CS2 AHSTAT JST MOXLAD JERVEN CEPAC CLIO RR BORDO MW Mitchell HFS NBS FZ IHD IMF_WEO_forecast) generate(infl) varname(infl) base_year(2018) method("none")



