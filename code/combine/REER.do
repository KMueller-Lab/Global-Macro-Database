* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* CONSTRUCTING REAL EFFECTIVE EXCHANGE RATE SERIES
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

splice, priority(WDI WDI_ARC BRUEGEL BIS EUS IMF_IFS OECD_MEI OECD_EO AMECO LUND CS1) generate(REER) varname(REER) base_year(2010) method("chainlink")

* Assert that the REER is equal to 100 in 2010
count if year == 2010 & REER != 100
if r(N) > 0 {
    display as error "Error: Not all values are 100 in 2010"
    list country your_column if year == 2010 & your_column != 100
    exit 198
}
