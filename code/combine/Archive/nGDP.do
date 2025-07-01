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
splice, priority(OECD_EO EUS AMECO WDI UN BCEAO FRANC_ZONE AMF ADB AFDB FAO WDI_ARC OECD_QNA IMF_WEO IMF_IFS CEPAC IMF_GDD CS1 CS2 CS3 MW JST AHSTAT Mitchell BORDO JO MOXLAD NBS GNA HFS FZ Davis IMF_WEO_forecast) generate(nGDP) varname(nGDP) base_year(2019) method("chainlink")

