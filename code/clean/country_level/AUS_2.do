* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* 
* Description: 
* This Stata script reads in and clean historical data for Australia from: Australians : a historical library, Volume 10
*
* Author:
* Mohamed Lehbib
* National University of Singapore
*
* Created: 2024-07-04
*
* URL: https://archive.org/details/australianshisto0010unse
* ==============================================================================

* ==============================================================================
* SET UP 
* ==============================================================================
clear
global input "${data_raw}/country_level/AUS_2.xlsx"
global output "${data_clean}/country_level/AUS_2"

*===============================================================================
*   			IMPORT AND MERGE DATA
*===============================================================================

* Open
import excel using "${input}", clear firstrow sheet(nGDP)

* Destring
destring *, replace 

* Assert that all columns are numeric now
ds, has(type string) 
cap `r(varlist)'
if _rc != 0 {
    di as error "Not all variables are numeric."
	exit 198
}
else {
    di as txt "All variables are numeric."
}



* Drop missing observations
missings dropobs, force

* Add ISO3 code
gen ISO3 = "AUS"

* Order 
order ISO3 year

* Sort
sort ISO3 year

* Create empty file to store the data
tempfile temp_master
save `temp_master', replace emptyok

* Loop over the next sheets and merge
local variable_list Money Gov
foreach variable of local variable_list {
	
	* Open
	import excel using "${input}", clear firstrow sheet(`variable')
	
	* Destring
	qui destring *, replace 

	* Assert that all columns are numeric now
	ds, has(type string) 
	cap `r(varlist)'
	if _rc != 0 {
		di as error "Not all variables in the `variable' sheet are numeric."
		exit 198
	}
	else {
		di as txt "All variables are numeric."
	}
	
	* Drop missing observations
	missings dropobs, force
	missings dropvars, force
	
	* Add ISO3 code
	gen ISO3 = "AUS"
	
	* Order 
	order ISO3 year
	
	* Sort
	sort ISO3 year	
	
	* Save and merge
	tempfile temp_`variable'
	save `temp_`variable'', replace emptyok
	merge 1:1 ISO3 year using `temp_master', nogen
	save `temp_master', replace	
}


* Calculate government revenue and taxes shares in GDP
gen govtax_GDP = TAXES/nGDP
gen govrev_GDP = REVENUE/nGDP
gen govdef_GDP = DEFICIT/nGDP

* Rename 
ren TAXES govtax
ren REVENUE govrev 
ren DEFICIT govdef 

* Fix units
replace govexp = govexp / 100
replace govrev = govrev / 100
replace govdef = govdef / 100
replace govtax = govtax / 100


* Add source identifier
qui ds ISO3 year, not
foreach var  in `r(varlist)'{
	ren `var' CS2_`var'
}

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
