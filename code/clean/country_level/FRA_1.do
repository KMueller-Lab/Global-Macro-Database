* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* CLEAN MONETARY AGGREGATES DATA FROM BANQUE DE FRANCE
* 
* Author:
* Mohamed Lehbib
* National University of Singapore
*
* Created: 2024-07-23
*
* Description: 
* This Stata script processes and cleans data from Banque de France
* 
* Data source: Banque de France
* 
* ==============================================================================

* ==============================================================================
* 	SET UP
* ==============================================================================
* Define input and output file names
clear
global input "${data_raw}/country_level/FRA_1.dta"
global output "${data_clean}/country_level/FRA_1"

* ==============================================================================
* 	PROCESS
* ==============================================================================

* Open
use "${input}", clear

* Keep only relevant variables
keep period value BS_ITEM

* Adjust the variable name 
replace BS_ITEM = substr(BS_ITEM, 1, 2)

* Reshape
greshape wide value, i(period) j(BS_ITEM) string

* Generate the year and month
gen year  = substr(period, 1, 4)
gen month = substr(period, -2, .)
drop period

* Fix missing values
qui ds year, not
foreach var in `r(varlist)' {
	replace `var' = "" if `var' == "NA"
}

* Destring
destring *, replace

* Assert that all columns are numeric now
ds, has(type string) 
cap `r(varlist)'
if _rc != 0 {
    di as error "Not all variables are numeric."
}
else {
    di as txt "All variables are numeric."
}

* Aggregate
sort year month
by year: keep if _n == _N
drop month

* Rename
ren value* *

* ==============================================================================
* 	OUTPUT
* ==============================================================================
* Sort
sort year

* Add country's ISO3
gen ISO3 = "FRA"

* Order
order ISO3 year

* Check for duplicates
isid ISO3 year

* Rename columns correctly
qui ds ISO3 year, not
foreach var  in `r(varlist)'{
	ren `var' CS1_`var'
}

* Save
save "${output}", replace
