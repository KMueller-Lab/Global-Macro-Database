* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* CLEAN DATA FOR Iceland 
* 
* Description: 
* This Stata script reads in and cleans historical Icelandic data from Hagskinna
*
* Author:
* Mohamed Lehbib
* National University of Singapore
*
* Created: 2024-07-08
*
* URL: https://baekur.is/bok/8f318e69-dc49-4a9f-a8ec-805b2352bad0
* ==============================================================================

* ==============================================================================
* 	SET UP 
* ==============================================================================

clear
global input "${data_raw}/country_level/ISL_2.xlsx"
global output "${data_clean}/country_level/ISL_2"

* ==============================================================================
* 	PROCESS
* ==============================================================================
* Open
import excel using "${input}", clear sheet(cbrate)

* Extract the end of period for each year or the latest available month
drop in 1/4
replace A = strtrim(A)
gen year = substr(A, -4, .)
gen month = substr(substr(A, strpos(A, ".") + 1, .), 1, strpos(substr(A, strpos(A, ".") + 1, .), ".") - 1)

* Destring 
destring year month B, replace

* Sort
sort year month

* Keep the last period
by year: keep if _n == _N

* Rename
ren B cbrate

* Drop
drop A month

* Order 
order year 

* Create empty file to store the data
tempfile temp_master
save `temp_master', replace emptyok

* Loop over the next sheets and merge
local variable_list Gov gov_debt CPI rates USDfx national_accounts Trade Money
foreach variable of local variable_list {

	* Open
	import excel using "${input}", clear sheet(`variable')
	
	* Identify the row that has the year and drop everything before it
	generate target_row = (A == "year")
	gen rn = _n
	gen dn = rn if A == "year"
	su dn
	local dd = `r(max)' - 1
	drop in 1/`dd'
	drop target_row rn dn 
	
	* Drop columns with no data
	missings dropvars, force
	
	* Rename columns with the first row content
	qui ds
	foreach var in `r(varlist)'{
		local varname = `var'[1]
		rename `var' `varname'
	}
	drop in 1
	
	* Destring
	destring *, replace
	
	* Assert that all variables are numeric
	ds, has(type string) 
	cap `r(varlist)'
	if _rc != 0 {
		di as error "Not all variables in the `variable' sheet are numeric."
		exit 198
	}
	else {
		di as txt "All variables are numeric."
	}
	
	* Order 
	order year
	
	* Sort
	sort year	
	
	* Save and merge
	tempfile temp_`variable'
	save `temp_`variable'', replace emptyok
	merge 1:1 year using `temp_master', nogen
	save `temp_master', replace	
	
}

* Convert GDP values into new currency
replace nGDP = nGDP / 100 if year <= 1945 
replace rGDP = rGDP / 100 if year <= 1945 

* Convert into new currency
qui ds M0 M1 M2 M3 USDfx gov_debt
foreach var in `r(varlist)'{
	qui replace `var' = `var' / 100 if year <= 1980 
}

* Convert trade variables
replace exports  = exports  / 100000 if year < 1945
replace imports  = imports  / 100000 if year < 1945

* Convert units for government finances variables
qui ds central* local* 
foreach var in `r(varlist)'{
	replace `var' = `var' / 100000 if year <= 1945  
}

* Calculate general government revenue
replace REVENUE = central_gov_REVENUE + local_gov_revenue if REVENUE == .
replace REVENUE = central_gov_REVENUE if REVENUE == .

* Calculate general government expenditure
replace govexp = central_govexp + local_gov_exp if govexp == .
replace govexp = central_govexp if govexp == .

* Calculate general government deficit
replace DEFICIT = central_gov_DEFICIT + local_gov_balance if DEFICIT == .

* Caclulate general government taxes
gen govtax = direct_taxes + indirect_taxes
replace govtax = central_gov_direct_taxes + central_gov_ftrade_taxes + central_gov_other_taxes if govtax == .

* Rename
ren REVENUE  govrev
ren DEFICIT  govdef
ren gov_debt govdebt

* Calculate GDP ratios
qui ds gov*
foreach var in `r(varlist)'{
	gen `var'_GDP = `var' / nGDP * 100
}

* Drop central government and local government variables
drop central* local* direct_taxes indirect_taxes

* Caclulate investment as the sum of gross fixed capital formation and Increases in Stocks 
gen inv = finv + temp_inv
drop temp_inv

* Add country's ISO3 code
gen ISO3 = "ISL"

* Add ratios to gdp variables
gen cons_GDP    = (cons / nGDP) * 100
gen imports_GDP = (imports / nGDP) * 100
gen exports_GDP = (exports / nGDP) * 100
gen finv_GDP    = (finv / nGDP) * 100
gen inv_GDP     = (inv / nGDP) * 100

* Add source identifier
qui ds year ISO3, not
foreach var in `r(varlist)'{
	ren `var' CS2_`var'
}

* Convert units
replace CS2_govexp = CS2_govexp * (10^3) if year >= 1980
replace CS2_govrev = CS2_govrev * (10^3) if year >= 1980
replace CS2_govtax = CS2_govtax * (10^3) if year >= 1980

* ==============================================================================
* 	OUTPUT
* ==============================================================================
* Order
order ISO3 year

* Sort
sort year

* Check for duplicates
isid year ISO3 

* Save
save "${output}", replace
