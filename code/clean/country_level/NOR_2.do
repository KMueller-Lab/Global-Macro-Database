* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* 
* Description: 
* This Stata script reads in and clean Historical monetary statistics for Norway 
*
* Author:
* Mohamed Lehbib
* National University of Singapore
*
* Created: 2024-07-08
* 
* URL: https://www.norges-bank.no/en/topics/Statistics/Historical-monetary-statistics/
* ==============================================================================

* ==============================================================================
* 	SET UP
* ==============================================================================
clear
global input "${data_raw}/country_level/NOR_2.xlsx"
global output "${data_clean}/country_level/NOR_2"

* ===============================================================================
* 	PROCESS 
* ===============================================================================

* Open
import excel using "${input}", clear firstrow sheet(cbrate)

* Keep only end-of-year observation
keep if strpos(month, ":12")

* Extract year
gen year = substr(month, 1, 4)
drop month

* Destring
destring *, replace 

* Assert that all columns are numeric now
qui ds, has(type string) 
cap `r(varlist)'
if _rc != 0 {
    di as error "Not all variables are numeric."
	exit 198
}
else {
    di as txt "All variables are numeric."
}

* Add ISO3 code
gen ISO3 = "NOR"

* Order 
order ISO3 year

* Sort
sort ISO3 year

* Create empty file to store the data
tempfile temp_master
save `temp_master', replace emptyok

* Loop over the next sheets and merge
local variable_list fx CPI gov ltrate strate HPI
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

	* Add ISO3 code
	gen ISO3 = "NOR"
	
	* Order 
	order ISO3 year
	
	* Sort
	sort ISO3 year	
	
	* Save and merge
	tempfile temp_`variable'
	qui save `temp_`variable'', replace emptyok
	qui merge 1:1 ISO3 year using `temp_master', nogen
	qui save `temp_master', replace	
}

* Create long term interest rate based on the quoted rate in Hamburg and fill-in missing data from other exchanges
replace Hamburg = Copenhagen if Hamburg == .
replace Hamburg = London if Hamburg == .
ren Hamburg ltrate

* Drop
drop London Copenhagen Paris Berlin Oslo

* Convert units
replace pop = pop / 1000000

* Derive inflation rate
sort ISO3 year
encode ISO3, gen(id)
xtset id year
by id: gen infl = (CPI - L.CPI) / L.CPI * 100 if L.CPI != .
drop id

* Add ratios to gdp variables
gen imports_GDP = (imports / nGDP) * 100
gen exports_GDP = (exports / nGDP) * 100
gen govexp_GDP = (govexp / nGDP) * 100

* Add source identifier
qui ds ISO3 year, not
foreach var  in `r(varlist)'{
	ren `var' CS2_`var'
}

* Drop
drop CS2_GBPfx CS2_DEMfx CS2_SEKfx CS2_FRFfx

* ===============================================================================
* 	OUTPUT
* ===============================================================================
* Order 
order ISO3 year

* Sort
sort ISO3 year	

* Check for duplicates
isid ISO3 year

* Save
save "${output}", replace
