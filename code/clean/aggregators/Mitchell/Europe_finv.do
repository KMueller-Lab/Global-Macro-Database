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
* This Stata script opens and cleans data on investment from Mitchell IHS
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
global input "${data_raw}/aggregators/MITCHELL/Europe_NA"
global output "${data_temp}/MITCHELL/Europe_finv"

*===============================================================================
* 			Finv: Sheet2
*===============================================================================


clear
import_columns_first "${input}" "2"
qui ds year, not
local varlist `r(varlist)'
forvalues i = 1/3 {
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

* Keep only Finv columns
qui ds year, not
local vars_to_keep 
foreach var in `r(varlist)' {
	qui replace `var' = strlower(`var') in 3
    if `var'[3] == "current prices" & inlist(`var'[4], "CF") {
            local vars_to_keep `vars_to_keep' `var'
        }
}
qui keep year `vars_to_keep'

* Rename columns
qui ds year, not
foreach var in `r(varlist)' {
	local newname = `var'[1]
	cap ren `var' `newname'
}
ren AC UnitedKingdom

* Destring
qui drop if year == ""
destring_check

* Convert units
convert_units Italy 1815 1899 "B"

* Reshape and save
reshape_data inv
tempfile temp_c
save `temp_c', emptyok replace


*===============================================================================
* 			Finv: Sheet3
*===============================================================================
import_columns_first "${input}" "3"
qui ds year, not
local varlist `r(varlist)'
forvalues i = 1/3 {
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

* Keep only Finv columns
qui ds year, not
local vars_to_keep 
foreach var in `r(varlist)' {
	qui replace `var' = strlower(`var') in 3
    if `var'[3] == "current prices" & inlist(`var'[4], "CF") {
            local vars_to_keep `vars_to_keep' `var'
        }
}
qui keep year `vars_to_keep'

* Rename columns
qui ds year, not
foreach var in `r(varlist)' {
	local newname = `var'[1]
	cap ren `var' `newname'
}
ren BE UnitedKingdom

* Destring
qui drop if year == ""
destring_check

* Convert units
local countries Austria Italy Russia
foreach country of local countries {
	qui convert_units `country' 1900 1944 "B"
}

* Reshape and save
reshape_data inv

* Merge and save
save_merge `temp_c'

*===============================================================================
* 			Finv: Sheet4
*===============================================================================
import_columns_first "${input}" "4"
qui ds year, not
local varlist `r(varlist)'
forvalues i = 1/3 {
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

* Keep only Finv columns
qui ds year, not
local vars_to_keep 
foreach var in `r(varlist)' {
	qui replace `var' = strlower(`var') in 3
    if `var'[3] == "current prices" & inlist(`var'[4], "CF") {
            local vars_to_keep `vars_to_keep' `var'
        }
}
qui keep year `vars_to_keep'

* Rename columns
qui ds year, not
foreach var in `r(varlist)' {
	local newname = `var'[1]
	cap ren `var' `newname'
}
ren AC EastGermany
ren AE Germany
ren BO Russia
ren CE UnitedKingdom

* Destring
qui drop if year == ""
destring_check


* Reshape and save
reshape_data inv

* Merge and save
save_merge `temp_c'




*===============================================================================
* 			Finv: Sheet5
*===============================================================================
import_columns_first "${input}" "5"
qui ds year, not
local varlist `r(varlist)'
forvalues i = 1/3 {
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

* Keep only Finv columns
qui ds year, not
local vars_to_keep 
foreach var in `r(varlist)' {
	qui replace `var' = strlower(`var') in 3
    if `var'[3] == "current prices" & inlist(`var'[4], "CF") {
            local vars_to_keep `vars_to_keep' `var'
        }
}
qui keep year `vars_to_keep'

* Rename columns
qui ds year, not
foreach var in `r(varlist)' {
	local newname = `var'[1]
	cap ren `var' `newname'
}
ren AC EastGermany
ren AE Germany
ren AQ Ireland
ren BO Russia
ren CC UnitedKingdom

* Destring
qui drop if year == ""
destring_check


* Convert units to billions
local countries France Hungary Ireland Yugoslavia
foreach country of local countries {
	convert_units `country' 1945 1979 "Th"
}

* Convert now everything back to millions
qui ds year, not
foreach country in `r(varlist)' {
	qui convert_units `country' 1945 1979 "B"
}


* Reshape and save
reshape_data inv

* Merge and save
save_merge `temp_c'

* Drop USD values
replace inv = . if year >= 1999

* Fix additional units issues
replace inv = inv * 100 if year <= 1999 & countryname == "Austria"
replace inv = inv * 10  if year <= 1993 & countryname == "Austria"
replace inv = inv / 1000  if year <= 1937 & countryname == "Austria"
replace inv = inv * 1000  if year <= 1999 & countryname == "Belgium"
replace inv = inv * 1000  if year >= 1945 & inlist(countryname, "Denmark", "Finland", "Italy", "Netherlands", "Norway", "Portugal", "Spain", "Sweden", "UnitedKingdom")
replace inv = inv * 1000  if year <= 1979 & countryname == "France"
replace inv = inv * 1000  if year >= 1945 & countryname == "Italy"
replace inv = inv * 1000  if year <= 1999 & countryname == "Greece"
replace inv = inv * 1000  if year <= 1999 & countryname == "Switzerland"
replace inv = inv / 1000  if year <= 1972 & countryname == "Bulgaria"
replace inv = inv / (10^12) if countryname == "Germany" & year <= 1913
replace inv = inv * 1000  if year >= 1950 & countryname == "Hungary"
replace inv = inv / (10^24) / 4 if year <= 1940 & countryname == "Hungary"
replace inv = inv * 1000 if countryname == "Czechoslovakia"
replace inv = inv * 1000 if year >= 1980 & countryname == "France"
replace inv = inv * 1000 if year >= 1950 & countryname == "Germany"

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
