* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* CLEAN OECD HOUSE PRICE DATA 
* 
* Description: 
* This Stata script reads in and cleans house price data from the OECD.
*
* Author:
* Karsten Müller
* National University of Singapore
*
* URL:
* https://data.oecd.org/price/housing-prices.htm (Archived on: 2024-07-22)
*
* ==============================================================================

* ==============================================================================
* 	SET UP 
* ==============================================================================

* Define input and output files
clear
global input "${data_raw}/aggregators/OECD/OECD_HPI.dta"
global output "${data_clean}/aggregators/OECD/OECD_HPI.dta"

* ==============================================================================
* 	PROCESS
* ==============================================================================

* Open 
use "${input}", clear

* Rename
ren cou 	ISO3
ren period  year
ren value   OECD_

* Drop regional aggregates
drop if inlist(ISO3, "EA", "EA17", "OECD")

* Keep relevant variables
keep ISO3 year OECD_ ind

* Reshape 
greshape wide OECD_, i(ISO3 year) j(ind)

* Rename
ren OECD_RHP OECD_rHPI

* Keep relevant variables
keep ISO3 year OECD_HPI OECD_rHPI

* ==============================================================================
* 	OUTPUT
* ==============================================================================
* Sort
sort ISO3 year

* Order
order ISO3 year 

* Check for duplicates
isid year ISO3 

* Save
save "${output}", replace
