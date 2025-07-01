* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* Constructing M0 data
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
splice, priority(AFRISTAT BCEAO IMF_MFS ADB CS1 CS2 CS3 AHSTAT JST NBS Mitchell CEPAC HFS FZ IHD) generate(M0) varname(M0) base_year(2018) method("chainlink")



