* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* 
* Description: 
* This Stata script reads in and cleans historical economic data for Sweden
*
* Author:
* Zekai SHEN
* National University of Singapore
*
* Created: 2024-07-04
*
* URL: https://www.lusem.lu.se/organisation/department-economic-history/research-department-economic-history/databases-department-economic-history
* ==============================================================================

* ==============================================================================
* 	SET UP 
* ==============================================================================
clear
global input "${data_raw}/country_level/SWE_1.xlsx"
global output "${data_clean}/country_level/SWE_1"

* ===============================================================================
* 	PROCESS
* ===============================================================================

* Open
qui import excel using "${input}", clear firstrow sheet(gov)

* Destring
qui destring *, replace 

* process year
gen new_year = substr(year, 1, 2) + substr(year, -2, 2)
drop year
rename new_year year
qui destring *, replace 
replace year = 1754 if year == 1753 & govexp == 1620

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

* Add ISO3 code
gen ISO3 = "SWE"
	
* Sort
sort year

* Create empty file to store the data
tempfile temp_master
save `temp_master', replace emptyok

* Loop over the next sheets and merge
local variable_list fx CPI money national_accounts GDP
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
	gen ISO3 = "SWE"
	
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

* Convert the units
replace govexp   = govexp   / 1000
replace gov_debt = gov_debt / 1000
replace DEFICIT  = DEFICIT  / 1000
replace REVENUE  = REVENUE  / 1000
replace pop = pop / (10^6)

* Rename
ren DEFICIT govdef
ren REVENUE govrev
ren gov_debt govdebt

* Derive inflation rate
sort ISO3 year
encode ISO3, gen(id)
xtset id year
by id: gen infl = (CPI - L.CPI) / L.CPI * 100 if L.CPI != . 
drop id

* Add ratios to gdp variables
gen cons_GDP    = (cons / nGDP) * 100
gen imports_GDP = (imports / nGDP) * 100
gen exports_GDP = (exports / nGDP) * 100
gen finv_GDP    = (finv / nGDP) * 100
gen govrev_GDP = (govrev / nGDP) * 100
gen govexp_GDP = (govexp / nGDP) * 100
gen govdebt_GDP = (govdebt / nGDP) * 100


* Add the deflator
gen deflator = (nGDP / rGDP) * 100

* Rebase the GDP to 2010
qui gen  temp = deflator if year == 2010 
qui egen defl_2010 = max(temp) 
qui replace rGDP = (rGDP * defl_2010) / 100 
qui drop temp defl_2010	

* Update the deflator
replace deflator = (nGDP / rGDP) * 100

* Add source identifier
qui ds ISO3 year, not
foreach var  in `r(varlist)'{
	ren `var' CS1_`var'
}

* Drop
drop CS1_DMKfx CS1_GBPfx CS1_FRFfx

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
