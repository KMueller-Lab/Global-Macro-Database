* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* Description: 
* This Stata script reads in and cleans Italian National Accounts data from 1861-2011
*
* Author:
* Mohamed Lehbib
* National University of Singapore
*
* Created: 2024-07-04
*
* URL: https://www.bancaditalia.it/pubblicazioni/quaderni-storia/2011-0018/index.html (Archived on: 2024-09-26)
* ==============================================================================

* ==============================================================================
* 	SET UP 
* ==============================================================================
clear
global input "${data_raw}/country_level/ITA_1.xlsx"
global output "${data_clean}/country_level/ITA_1"

* ===============================================================================
* 	PROCESS
* ===============================================================================

* Open
qui import excel using "${input}", clear firstrow sheet(ITA)

* Destring
qui destring *, replace 

* Assert that all columns are numeric now
ds, has(type string) 
cap `r(varlist)'
if _rc != 0 {
    di as error "Not all variables are numeric."
}
else {
    di as txt "All variables are numeric."
}

* Convert units
replace rGDP_pc = rGDP_pc * 1000
replace pop 		= pop / 1000

* Add ratios to gdp variables
gen cons_GDP    = (cons / nGDP) * 100
gen exports_GDP = (exports / nGDP) * 100
gen finv_GDP    = (finv / nGDP) * 100
gen inv_GDP     = (inv / nGDP) * 100

* Add country's ISO3
gen ISO3 = "ITA"

* Add source identifier
qui ds ISO3 year, not
foreach var  in `r(varlist)'{
	ren `var' CS1_`var'
}

* ===============================================================================
* 	OUTPUT
* ===============================================================================
* Sort
sort year

* Order
order ISO3 year

* Check for duplicates
isid ISO3 year

* Save
save "${output}", replace
