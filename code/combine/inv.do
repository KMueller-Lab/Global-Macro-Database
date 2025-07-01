* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* Constructing investment
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
* Specify country specific priority ordering.
* ==============================================================================

* Set up the priority list
splice, priority(OECD_EO EUS AMECO WDI UN BCEAO FRANC_ZONE AMF ADB WDI_ARC OECD_QNA IMF_WEO IMF_IFS CEPAC CS1 CS2 CS3 JST AHSTAT Mitchell JO HFS IMF_WEO_forecast) generate(inv) varname(inv) base_year(2018) method("chainlink")


