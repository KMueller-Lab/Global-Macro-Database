* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* Constructing exports 
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
splice, priority(IMF_WEO OECD_EO IMF_IFS EUS UN WDI ADB AMF BCEAO JST Tena WDI_ARC AMECO CS1 CS2 CS3 AHSTAT Mitchell HFS NBS FZ TH_ID IHD) generate(exports) varname(exports) base_year(2019) method("chainlink")


