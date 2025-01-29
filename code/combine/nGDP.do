* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* CONSTRUCING NOMINAL GDP
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

* Open the data
use "$data_final/clean_data_wide", clear

* ==============================================================================
* Specify country specific priority ordering.
* ==============================================================================

* Set up the priority list
splice, priority(IMF_WEO AMF BCEAO FRANC_ZONE AFDB OECD_EO EUS WDI WDI_ARC UN OECD_QNA CEPAC ADB MW IMF_IFS IMF_GDD FAO AMECO CS1 CS2 CS3 JST AHSTAT Mitchell BORDO JO MOXLAD NBS GNA HFS FZ Davis) generate(nGDP) varname(nGDP) base_year(2019)  method("chainlink")

