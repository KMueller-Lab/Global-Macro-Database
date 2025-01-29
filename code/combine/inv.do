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
splice, priority(IMF_WEO EUS OECD_EO OECD_QNA AMF WDI UN IMF_IFS ADB BCEAO FRANC_ZONE WDI_ARC AMECO CS1 CS2 CS3 AHSTAT JST JO CEPAC HFS Mitchell) generate(inv) varname(inv) base_year(2018) method("chainlink")


