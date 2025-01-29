* ==============================================================================
* GLOBAL MACRO PROJECT
* by Karsten Müller, Chenzi Xu, Ziliang Chen, Mohamed Lehbib
* ==============================================================================
*
* Construct real consumption series 
* 
* Author:
* Karsten Müller
* National University of Singapore
*
* Created: 2025-01-20
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
splice, priority(IMF_IFS WDI UN BARRO) generate(rcons) varname(rcons) method("chainlink") base_year(2019)



 