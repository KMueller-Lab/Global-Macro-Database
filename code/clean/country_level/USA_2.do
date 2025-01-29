* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* Clean and add historical statistics for the United States
* 
* Description: 
* This Stata script reads in and clean historical statistics data
*
* Author:
* Mohamed Lehbib
* National University of Singapore
*
* Created: 2024-06-24
*
* URL: https://hsus.cambridge.org/HSUSWeb/toc/hsusHome.do (Archived: 2024-09-26)
* ==============================================================================

* ==============================================================================
* 	SET UP 
* ==============================================================================
clear
global input "${data_raw}/country_level/USA_2.xlsx"
global output "${data_clean}/country_level/USA_2.dta"

* ===============================================================================
* 	PROCESS
* ===============================================================================

* Open
qui import excel using "${input}", clear firstrow sheet(gov)

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

* Sort
sort year

* Create empty file to store the data
qui tempfile temp_master
qui save `temp_master', replace emptyok

* Loop over the next sheets and merge
local variable_list trade GDP ltrate CPI sav
foreach variable of local variable_list {
	
	* Open
	qui import excel using "${input}", clear firstrow sheet(`variable')
	
	* Destring
	qui destring *, replace 

	* Assert that all columns are numeric now
	qui ds, has(type string) 
	cap `r(varlist)'
	if _rc != 0 {
		di as error "Not all variables in the `variable' sheet are numeric."
		exit 198
	}
	else {
		di as txt "All variables are numeric."
	}
	
	* Sort
	sort year
	
	* Save and merge
	qui tempfile temp_`variable'
	qui save `temp_`variable'', replace emptyok
	qui merge 1:1 year using `temp_master', nogen
	qui save `temp_master', replace	
}

* Convert units
replace pop = pop / 1000

* Rename
ren gov_debt govdebt
ren DEFICIT  govdef 
ren REVENUE  govrev

* Calculate ratios
gen govdebt_GDP = govdebt / nGDP
gen govdef_GDP  = govdef / nGDP
gen govrev_GDP  = govrev / nGDP
gen govexp_GDP  = govexp / nGDP

* Convert units
replace govexp = govexp / 1000
replace govrev = govrev / 1000
replace govdef = govdef / 1000
replace inv = inv * 1000
replace sav = sav * 1000

* Fix government debt units (Represents a factor of ten to other sources)
replace govdebt_GDP = govdebt_GDP / 10

* Add country's ISO3
gen ISO3 = "USA"

* Derive inflation rate
sort ISO3 year
encode ISO3, gen(id)
xtset id year
by id: gen infl = (CPI - L.CPI) / L.CPI * 100 if L.CPI != .
drop id

* Add ratios to gdp variables
gen inv_GDP     = (inv / nGDP) * 100

* Add source identifier
qui ds ISO3 year, not
foreach var  in `r(varlist)'{
	ren `var' CS2_`var'
}

* Drop
drop CS2_nGDP_pc CS2_GBPfx

* ===============================================================================
*	OUTPUT
* ===============================================================================

* Sort
sort year

* Order
order ISO3 year

* Check for duplicates
isid ISO3 year

* Save
save "${output}", replace
