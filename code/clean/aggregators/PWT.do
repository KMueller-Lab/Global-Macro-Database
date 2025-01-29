* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* Description: 
* This Stata script reads in and cleans data from the Penn World Tables 9.1.
*
* Author:
* Karsten Müller
* National University of Singapore
*
* Created: 2024-04-21
*
* ==============================================================================

* ==============================================================================
* 	SET UP 
* ==============================================================================

* Clear panel 
clear

* Define input and output files
global input "${data_raw}/aggregators/PWT/pwt1001.dta"
global output "${data_clean}/aggregators/PWT/PWT.dta"

* ==============================================================================
* 	PROCESS
* ==============================================================================

* Open 
use "${input}", clear

* Renaming 
ren countrycode ISO3
ren pop 	PWT_pop
ren rgdpna 	PWT_rGDP_USD
ren xr 		PWT_USDfx


* Drop second China code 
* Note: nominal GDP data appears to be equivalent to the one with the code "CHN"
drop if ISO3 == "CH2"

* Keep relevant variables 
keep ISO3 year PWT_*

* Fix Iran USDfx (wrong values)
gmdfixunits PWT_USDfx if inrange(year, 1958, 1959) & ISO3 == "IRN", replace(75.75)

* Drop Liberia USDfx (Not pegged anymore to USD)
gmdfixunits PWT_USDfx if ISO3 == "LBR", missing

* Drop Zimbabwe USDfx (Not pegged to USD)
gmdfixunits PWT_USDfx if ISO3 == "ZWE", missing

* Fix Sierra Leone units
gmdfixunits PWT_USDfx if ISO3 == "SLE", multiply(1000)

* Drop Venezuela (Incorrect values) after 2014
gmdfixunits PWT_USDfx if ISO3 == "VEN" & year >= 2014, missing

* Indonesia's exchange rate is not correct before 1965
gmdfixunits PWT_USDfx if ISO3 == "IDN" & year <= 1965, missing


* ==============================================================================
* 	OUTPUT
* ==============================================================================
* Order
order ISO3 year

* Sort
sort ISO3 year

* Check for duplicates
isid ISO3 year

* Output
save "${output}", replace
