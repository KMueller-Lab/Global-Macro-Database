* ==============================================================================
* GLOBAL MACRO PROJECT
* by Karsten Müller, Chenzi Xu, Ziliang Chen, Mohamed Lehbib
* ==============================================================================
*
* Construct consumption series (in % of GDP)
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
splice, priority(WDI IMF_IFS EUS OECD_EO WDI_ARC UN AMF BCEAO AMECO CS1 CS2 CS3 CEPAC  AHSTAT) generate(cons_GDP) varname(cons_GDP) method("chainlink") base_year(2018)



 