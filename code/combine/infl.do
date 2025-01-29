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
splice, priority(WB_CC ADB AMF BIS BCEAO IMF_WEO IMF_IFS EUS OECD_EO FRANC_ZONE OECD_KEI WDI CS1 CS2 AHSTAT JST MOXLAD JERVEN CEPAC BORDO MW Mitchell HFS NBS FZ IHD) generate(infl) varname(infl) base_year(2018) method("none")



