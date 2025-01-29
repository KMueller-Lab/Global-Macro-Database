* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* CLEAN DATA FOR AUSTRALIA 
* 
* Description: 
* This Stata script reads in and cleans data from Measuring Worth.
*
* Author:
* Karsten Müller
* National University of Singapore
*
* Created: 2024-04-21
*
* ==============================================================================

* ==============================================================================
* SET UP 
* ==============================================================================

* Clear data 
clear 

* Define input and output files
global input "${data_raw}/country_level/AUS_1.csv"
global output "${data_clean}/country_level/AUS_1.dta"

* ==============================================================================
* CLEAN DATA 
* ==============================================================================
* Open  
insheet using "${input}", clear 

* Drop unnecessary rows 
drop in 1/4

* Replace commas, destring 
foreach var in v2 v3 v4 v6 v7 v8 v10 {
	replace `var' = subinstr(`var',",","",.)
}
destring *, replace 

* Multiply Australian pounds with 2 to make dollars (irrevocable exchange rate)
replace v3 = v3 * 2

* Combine nominal GDP series 
replace v2 = v3 if v2 == .



* Rename 
ren v1 year 
ren v2 CS1_nGDP
ren v4 CS1_rGDP_USD 
ren v5 CS1_deflator
ren v7 CS1_rGDP_pc_USD
ren v8 CS1_pop 
ren v9 CS1_CPI 

* Set CPI and deflator to missing if exactly 0 
foreach var in CPI deflator {
	replace CS1_`var' = . if CS1_`var' == 0
}



* Convert population to millions
replace CS1_pop = CS1_pop/1000000

* A country's ISO3 code
gen ISO3 = "AUS"
keep ISO3 year CS1_*

* Derive inflation rate
sort ISO3 year
encode ISO3, gen(id)
xtset id year
by id: gen CS1_infl = (CS1_CPI - L.CS1_CPI) / L.CS1_CPI * 100 if L.CS1_CPI != .
drop id

* ==============================================================================
* 	Output
* ==============================================================================
* Sort
sort ISO3 year

* Order
order ISO3 year

* Check for duplicates
isid ISO3 year

* Save 
save "${output}", replace
