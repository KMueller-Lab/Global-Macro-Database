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
global input "${data_raw}/aggregators/PWT/PWT.dta"
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
qui replace PWT_USDfx = 75.75 if inrange(year, 1958, 1959) & ISO3 == "IRN" 
gmdaddnote_source PWT  "Use the official exchange rate data from the IMF for 1958 and 1959." USDfx

* Drop Liberia USDfx (Not pegged anymore to USD)
qui replace PWT_USDfx = . if ISO3 == "LBR" & year >= 1998 
gmdaddnote_source PWT  "Dropped value after 1998 because that is when the peg ended." USDfx

* Drop Zimbabwe USDfx (Not pegged to USD)
qui replace PWT_USDfx = . if ISO3 == "ZWE" 
gmdaddnote_source PWT  "Dropped because the currency was never pegged to USD." USDfx

* Fix Sierra Leone units
qui replace PWT_USDfx = PWT_USDfx / 1000 if ISO3 == "SLE" & year <= 2021 
gmdaddnote_source PWT  "Values converted to current currency before 2021." USDfx

* Drop Venezuela (Incorrect values) after 2014
qui replace PWT_USDfx = . if ISO3 == "VEN" & year >= 2014
gmdaddnote_source PWT  "Incorrect values after 2014 compared to other sources after 2014." USDfx

* Indonesia's exchange rate is not correct before 1965
qui replace PWT_USDfx = . if ISO3 == "IDN" & year <= 1965
gmdaddnote_source PWT  "Incorrect values before 1965 compared to other sources before 1965." USDfx


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
