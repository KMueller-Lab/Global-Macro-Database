* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* CONSTRUCT UNEMPLOYMENT RATE SERIES
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
splice, priority(EUS OECD_EO OECD_KEI ADB AMECO ILO AFDB IMF_WEO IMF_IFS CS1 CS2 AHSTAT JST HFS IMF_WEO_forecast) generate(unemp) varname(unemp) base_year(2018)  method("none")


