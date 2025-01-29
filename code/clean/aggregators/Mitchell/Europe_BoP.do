* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* CLEAN MITCHELL INTERNATIONAL HISTORICAL STATISTICS DATA
* 
* Author:
* Mohamed Lehbib
* National University of Singapore
*
* Created: 2024-08-27
*
* Description: 
* This Stata script opens and cleans the Balance of Payments data from Mitchell IHS
* 
* Data Source:
* MITCHELL HISTORICAL STATISTICS
*
* ==============================================================================

* ==============================================================================
* Set up
* ==============================================================================

* Clear data 
clear

* Define globals 
global input "${data_raw}/aggregators/MITCHELL/Europe_BoP"
global output "${data_temp}/MITCHELL/Europe_BoP"

*===============================================================================
* 			BOP: Sheet2
*===============================================================================
clear
import_columns_first "${input}" "2"
qui ds year, not
local varlist `r(varlist)'
forvalues i = 1/2 {
    local newname = ""
    foreach var in `varlist' {
        if strlen(`var'[`i']) != 0 {
            local newname = `var'[`i']
        }
        if strlen(`var'[`i']) == 0 & "`newname'" != "" {
            qui replace `var' = "`newname'" in `i'
        }
    }
}

* Keep only overall current balance
qui ds year, not
local vars_to_keep 
foreach var in `r(varlist)' {
	if `var'[3] == "OCB" {
            local vars_to_keep `vars_to_keep' `var'
        }
}
qui keep year `vars_to_keep'

* Rename columns
qui ds year, not
foreach var in `r(varlist)' {
	qui replace `var' = strlower(`var') in 2
	local newname = `var'[1]
	cap ren `var' `newname'
}
ren AI UnitedKingdom

* Destring
qui drop if year == ""
destring_check

* Convert currency
convert_currency France 1914 1/100

* Reshape and save
reshape_data CA
tempfile temp_c
save `temp_c', emptyok replace

*===============================================================================
* 			BOP: Sheet3
*===============================================================================
import_columns_first "${input}" "3"
qui ds year, not
local varlist `r(varlist)'
forvalues i = 1/2 {
    local newname = ""
    foreach var in `varlist' {
        if strlen(`var'[`i']) != 0 {
            local newname = `var'[`i']
        }
        if strlen(`var'[`i']) == 0 & "`newname'" != "" {
            qui replace `var' = "`newname'" in `i'
        }
    }
}

* Keep only overall current balance
qui ds year, not
local vars_to_keep 
foreach var in `r(varlist)' {
	if `var'[3] == "OCB" {
            local vars_to_keep `vars_to_keep' `var'
        }
}
qui keep year `vars_to_keep'

* Rename columns
qui ds year, not
foreach var in `r(varlist)' {
	qui replace `var' = strlower(`var') in 2
	local newname = `var'[1]
	cap ren `var' `newname'
}
ren BD Ireland
ren CS UnitedKingdom

* Destring
qui drop if year == ""
destring_check

* Convert currency
convert_currency France 1944 1/100
convert_currency Finland 1948 1/100

* Reshape and save
reshape_data CA

* Add column for countries with data in USD
gen CA_USD = CA if inlist(countryname, "France", "Greece") & year >= 1945
replace CA_USD = CA if countryname == "Spain"
replace CA = . if CA_USD != .

* Save and merge
merge 1:1 countryname year using `temp_c', nogen
save `temp_c', replace

*===============================================================================
* 			BOP: Sheet4
*===============================================================================
import_columns_first "${input}" "4"
qui ds year, not
local varlist `r(varlist)'
forvalues i = 1/2 {
    local newname = ""
    foreach var in `varlist' {
        if strlen(`var'[`i']) != 0 {
            local newname = `var'[`i']
        }
        if strlen(`var'[`i']) == 0 & "`newname'" != "" {
            qui replace `var' = "`newname'" in `i'
        }
    }
}

* Keep only overall current balance
qui ds year, not
local vars_to_keep 
foreach var in `r(varlist)' {
	if `var'[3] == "OCB" {
            local vars_to_keep `vars_to_keep' `var'
        }
}
qui keep year `vars_to_keep'

* Rename columns
qui ds year, not
foreach var in `r(varlist)' {
	qui replace `var' = strlower(`var') in 2
	local newname = `var'[1]
	cap ren `var' `newname'
}
ren AO Germany
ren BC Ireland
ren DG UnitedKingdom

* Destring
qui drop if year == ""
destring_check

* Convert units
replace Germany = Germany * 1000

* Reshape and save
reshape_data CA_USD 

* Save and merge
merge 1:1 countryname year using `temp_c', nogen
save `temp_c', replace

*===============================================================================
* 			BOP: Sheet5
*===============================================================================
import_columns_first "${input}" "5"
qui ds year, not
local varlist `r(varlist)'
forvalues i = 1/2 {
    local newname = ""
    foreach var in `varlist' {
        if strlen(`var'[`i']) != 0 {
            local newname = `var'[`i']
        }
        if strlen(`var'[`i']) == 0 & "`newname'" != "" {
            qui replace `var' = "`newname'" in `i'
        }
    }
}

* Keep only overall current balance
qui ds year, not
local vars_to_keep 
foreach var in `r(varlist)' {
	if `var'[2] == "OCB" {
            local vars_to_keep `vars_to_keep' `var'
        }
}
qui keep year `vars_to_keep'

* Rename columns
qui ds year, not
foreach var in `r(varlist)' {
	qui replace `var' = strlower(`var') in 2
	local newname = `var'[1]
	cap ren `var' `newname'
}

* Destring
qui drop if year == ""
destring_check

* Reshape and save
reshape_data CA_USD 

* Save and merge
merge 1:1 countryname year using `temp_c', nogen
save `temp_c', replace


*===============================================================================
* 			BOP: Sheet6
*===============================================================================
import_columns_first "${input}" "6"
qui ds year, not
local varlist `r(varlist)'
forvalues i = 1/2 {
    local newname = ""
    foreach var in `varlist' {
        if strlen(`var'[`i']) != 0 {
            local newname = `var'[`i']
        }
        if strlen(`var'[`i']) == 0 & "`newname'" != "" {
            qui replace `var' = "`newname'" in `i'
        }
    }
}

* Keep only overall current balance
qui ds year, not
local vars_to_keep 
foreach var in `r(varlist)' {
	if `var'[2] == "OCB" {
            local vars_to_keep `vars_to_keep' `var'
        }
}
qui keep year `vars_to_keep'

* Rename columns
qui ds year, not
foreach var in `r(varlist)' {
	qui replace `var' = strlower(`var') in 2
	local newname = `var'[1]
	cap ren `var' `newname'
}

* Destring
qui drop if year == ""
destring_check

* Reshape and save
reshape_data CA_USD 

* Save and merge
merge 1:1 countryname year using `temp_c', nogen
save `temp_c', replace

* Convert units
replace CA = CA / (10^12) if countryname == "Germany" & year <= 1913
replace CA = CA / 1000000  if countryname == "Bulgaria"  


*===============================================================================
* 			Final set up
*===============================================================================
* Sort
sort countryname year

* Order
order countryname year

* Check for duplicates
isid countryname year

* Save
save "${output}", replace

