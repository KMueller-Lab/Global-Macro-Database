* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* 
* Description: 
* This Stata script reads in and clean historical data for Switzerland
*
* Author:
* Mohamed Lehbib
* National University of Singapore
*
* Created: 2024-10-02
*
* URL: https://hsso.ch/en/2012/q
* ==============================================================================

* ==============================================================================
* 	SET UP 
* ==============================================================================
clear
global input "${data_raw}/country_level/CHE_2"
global output "${data_clean}/country_level/CHE_2"

* ===============================================================================
*	NATIONAL ACCOUNTS
* ===============================================================================

* Open
import excel using "${input}", clear sheet("national_accounts") first

* Save
tempfile temp_master
save `temp_master', replace emptyok

* ===============================================================================
*	RATES
* ===============================================================================

* Open
import excel using "${input}", clear sheet("rates") first

* Save and merge
tempfile temp_c
save `temp_c', replace emptyok
merge 1:1 year using `temp_master', nogen
save `temp_master', replace


* Add source identifier
qui ds year, not
foreach var in `r(varlist)'{
	ren `var' CS2_`var'
}

* Add country's ISO3
gen ISO3 = "CHE"

* Convert units
replace CS2_pop = CS2_pop / 1000

* ===============================================================================
* 	Output
* ===============================================================================

* Order
order ISO3 year

* Sort
sort ISO3 year

* Check for duplicates
isid ISO3 year

* Save
save "${output}", replace
