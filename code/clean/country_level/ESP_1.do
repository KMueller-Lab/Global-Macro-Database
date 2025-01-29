* ==============================================================================
* GLOBAL CREDIT DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* 
* Description: 
* This Stata script reads in and clean data for Spain statistical agency
*
* Author:
* Mohamed Lehbib
* National University of Singapore
*
* Created: 2024-11-05
*
* ==============================================================================

* ==============================================================================
* 	SET UP 
* ==============================================================================
* Clear
clear
global input "${data_raw}/country_level/ESP_1"
global output "${data_clean}/country_level/ESP_1"

* ==============================================================================
*	POP
* ==============================================================================

* Open
use "$input", clear

* Add year
gen year = substr(period, 1, 4)
destring year, replace 

* Extract indicators
gen indicator = "" 
replace indicator = "nGDP" if series_code == "CNTR4757"
replace indicator = "exports" if series_code == "CNTR4938"
replace indicator = "imports" if series_code == "CNTR4934"
replace indicator = "cons" if series_code == "CNTR4953"
replace indicator = "finv" if series_code == "CNTR4941"
replace indicator = "inv" if series_code == "CNTR4942"
drop if indicator == ""

* Keep 
keep period year value indicator

* Sum
sort indicator year period
by indicator year: egen new_value = sum(value)
by indicator year: keep if _n == 1
drop if year == 2024
drop period value

* Reshape 
greshape wide new_value, i(year) j(indicator)
ren new_value* *

* Add ratios to gdp variables
gen cons_GDP    = (cons / nGDP) * 100
gen imports_GDP = (imports / nGDP) * 100
gen exports_GDP = (exports / nGDP) * 100
gen finv_GDP    = (finv / nGDP) * 100
gen inv_GDP     = (inv / nGDP) * 100

* Add source identifier
qui ds year, not
foreach var in `r(varlist)'{
	ren `var' CS1_`var'
}

* Add ISO3 
gen ISO3 = "ESP"

* ==============================================================================
* 	Output
* ==============================================================================

* Order
order ISO3 year

* Sort
sort ISO3 year

* Check for duplicates
isid ISO3 year

* Save
save "${output}", replace
