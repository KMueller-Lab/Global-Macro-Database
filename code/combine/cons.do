* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Ziliang Chen, Mohamed Lehbib
* ==============================================================================
*
* Construct consumption 
* 
* Author:
* Karsten Müller
* National University of Singapore
*
* Created: 2024-10-17
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
splice, priority(OECD_EO EUS AMECO WDI UN BCEAO AMF WDI_ARC OECD_QNA IMF_IFS CEPAC CS1 CS2 CS3 AHSTAT HFS) generate(cons) varname(cons) method("chainlink") base_year(2018)



 