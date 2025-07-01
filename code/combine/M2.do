* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* CONSTRUCT M2 SERIES
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
splice, priority(AFRISTAT BCEAO AFDB IMF_MFS FRANC_ZONE ADB CS1 CS2 JST AHSTAT NBS Mitchell CEPAC HFS) generate(M2) varname(M2) base_year(2018) method("chainlink")
