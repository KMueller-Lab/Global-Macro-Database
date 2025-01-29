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
* This Stata script opens and cleans trade from Mitchell IHS
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
global input "${data_raw}/aggregators/MITCHELL/Oceania_trade"
global output "${data_temp}/MITCHELL/Oceania_trade"

*===============================================================================
* 			Imports: Sheet2
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

* Keep only imports
qui ds year, not
local vars_to_keep 
foreach var in `r(varlist)' {
	qui replace `var' = subinstr(`var', " ", "", .) in 2
	qui replace `var' = strlower(`var') in 2
	if `var'[2] == "imports" {
            local vars_to_keep `vars_to_keep' `var'
        }
}
qui keep year `vars_to_keep'

* Rename columns
qui ds year, not
foreach var in `r(varlist)' {
	qui replace `var' = subinstr(`var', " ", "", .) in 1
	local newname = `var'[1]
	cap ren `var' `newname'
}

* Destring
qui drop if year == ""
destring_check

* Convert units
local countries NewZealand Hawaii
foreach country of local countries {
	convert_units `country' 1825 1874 "Th"
}

* Reshape and save
reshape_data imports
tempfile temp_c
save `temp_c', emptyok replace


*===============================================================================
* 			Exports: Sheet2
*===============================================================================

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

* Keep only exports
qui ds year, not
local vars_to_keep 
foreach var in `r(varlist)' {
	qui replace `var' = subinstr(`var', " ", "", .) in 2
	qui replace `var' = strlower(`var') in 2
	if `var'[2] == "exports" {
            local vars_to_keep `vars_to_keep' `var'
        }
}
qui keep year `vars_to_keep'

* Rename columns
qui ds year, not
foreach var in `r(varlist)' {
	qui replace `var' = subinstr(`var', " ", "", .) in 1
	local newname = `var'[1]
	cap ren `var' `newname'
}

* Destring
qui drop if year == ""
destring_check


* Convert units
local countries NewZealand Hawaii
foreach country of local countries {
	convert_units `country' 1825 1874 "Th"
}

* Reshape and merge
reshape_data exports
qui merge 1:1 year countryname using `temp_c', assert(3) nogen
qui save `temp_c', replace

*===============================================================================
* 			Imports: Sheet3
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

* Keep only imports
qui ds year, not
local vars_to_keep 
foreach var in `r(varlist)' {
	qui replace `var' = subinstr(`var', " ", "", .) in 2
	qui replace `var' = strlower(`var') in 2
	if `var'[2] == "imports" {
            local vars_to_keep `vars_to_keep' `var'
        }
}
qui keep year `vars_to_keep'

* Rename columns
qui ds year, not
foreach var in `r(varlist)' {
	qui replace `var' = subinstr(`var', " ", "", .) in 1
	local newname = `var'[1]
	cap ren `var' `newname'
}

* Destring
qui drop if year == ""
destring_check

* Convert units
local countries Fiji FrenchPolynesia Samoa
foreach country of local countries {
	convert_units `country' 1875 1919 "Th"
}
convert_units NewZealand 1875 1904 "Th"
convert_units NewCaledonia 1875 1914 "Th"

* Reshape and save
reshape_data imports
gen exports = .
save_merge `temp_c'

*===============================================================================
* 			Exports: Sheet3
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

* Keep only imports
qui ds year, not
local vars_to_keep 
foreach var in `r(varlist)' {
	qui replace `var' = subinstr(`var', " ", "", .) in 2
	qui replace `var' = strlower(`var') in 2
	if `var'[2] == "exports" {
            local vars_to_keep `vars_to_keep' `var'
        }
}
qui keep year `vars_to_keep'

* Rename columns
qui ds year, not
foreach var in `r(varlist)' {
	qui replace `var' = subinstr(`var', " ", "", .) in 1
	local newname = `var'[1]
	cap ren `var' `newname'
}

* Destring
qui drop if year == ""
destring_check

* Convert units
local countries Fiji FrenchPolynesia Samoa
foreach country of local countries {
	convert_units `country' 1875 1919 "Th"
}
convert_units NewZealand 1875 1904 "Th"
convert_units NewCaledonia 1875 1914 "Th"

* Reshape and merge
reshape_data exports
qui merge 1:1 year countryname using `temp_c', assert(2 3) nogen
save `temp_c', replace 

*===============================================================================
* 			Imports: Sheet4
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

* Keep only imports
qui ds year, not
local vars_to_keep 
foreach var in `r(varlist)' {
	qui replace `var' = subinstr(`var', " ", "", .) in 2
	qui replace `var' = strlower(`var') in 2
	if `var'[2] == "imports" {
            local vars_to_keep `vars_to_keep' `var'
        }
}
qui keep year `vars_to_keep'

* Rename columns
qui ds year, not
foreach var in `r(varlist)' {
	qui replace `var' = subinstr(`var', " ", "", .) in 1
	local newname = `var'[1]
	cap ren `var' `newname'
}
ren WesternSamoa Samoa

* Destring
qui drop if year == ""
destring_check

* Convert units
convert_units Fiji 1920 1949 "Th"
convert_units Samoa  1920 1959 "Th"

* Reshape and save
reshape_data imports
gen exports = .
save_merge `temp_c'


*===============================================================================
* 			Exports: Sheet4
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

* Keep only imports
qui ds year, not
local vars_to_keep 
foreach var in `r(varlist)' {
	qui replace `var' = subinstr(`var', " ", "", .) in 2
	qui replace `var' = strlower(`var') in 2
	if `var'[2] == "exports" {
            local vars_to_keep `vars_to_keep' `var'
        }
}
qui keep year `vars_to_keep'

* Rename columns
qui ds year, not
foreach var in `r(varlist)' {
	qui replace `var' = subinstr(`var', " ", "", .) in 1
	local newname = `var'[1]
	cap ren `var' `newname'
}
ren WesternSamoa Samoa

* Destring
qui drop if year == ""
destring_check

* Convert units
convert_units Fiji 1920 1949 "Th"
convert_units Samoa  1920 1959 "Th"

* Reshape and merge
reshape_data exports
qui merge 1:1 year countryname using `temp_c', nogen
save `temp_c', replace 


*===============================================================================
* 			Imports: Sheet5
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

* Keep only imports
qui ds year, not
local vars_to_keep 
foreach var in `r(varlist)' {
	qui replace `var' = subinstr(`var', " ", "", .) in 2
	qui replace `var' = strlower(`var') in 2
	if `var'[2] == "imports" {
            local vars_to_keep `vars_to_keep' `var'
        }
}
qui keep year `vars_to_keep'

* Rename columns
qui ds year, not
foreach var in `r(varlist)' {
	qui replace `var' = subinstr(`var', " ", "", .) in 1
	local newname = `var'[1]
	cap ren `var' `newname'
}

* Destring
qui drop if year == ""
destring_check

* Reshape and save
reshape_data imports
gen exports = .
save_merge `temp_c'      


*===============================================================================
* 			Exports: Sheet5
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

* Keep only imports
qui ds year, not
local vars_to_keep 
foreach var in `r(varlist)' {
	qui replace `var' = subinstr(`var', " ", "", .) in 2
	qui replace `var' = strlower(`var') in 2
	if `var'[2] == "exports" {
            local vars_to_keep `vars_to_keep' `var'
        }
}
qui keep year `vars_to_keep'

* Rename columns
qui ds year, not
foreach var in `r(varlist)' {
	qui replace `var' = subinstr(`var', " ", "", .) in 1
	local newname = `var'[1]
	cap ren `var' `newname'
}

* Destring
qui drop if year == ""
destring_check

* Reshape and merge
reshape_data exports
qui merge 1:1 year countryname using `temp_c', nogen
save `temp_c', replace 

* Drop USD units
drop if countryname == "Samoa"              & year >= 1993
drop if countryname == "Australia" 		    & year >= 1997
drop if countryname == "Fiji" 		        & year >= 1997
drop if countryname == "FrenchPolynesia" 	& year >= 1997
drop if countryname == "NewCaledonia"       & year >= 1997
drop if countryname == "NewZealand" 		& year >= 1997
drop if countryname == "PapuaNewGuinea" 	& year >= 1997

*===============================================================================
* 			Convert currencies
*===============================================================================

* Australia
replace exports = exports * 2 if year <= 1959 & countryname == "Australia"
replace imports = imports * 2 if year <= 1959 & countryname == "Australia"

* New Zealand
replace exports = exports * 2 if year <= 1959 & countryname == "NewZealand"
replace imports = imports * 2 if year <= 1959 & countryname == "NewZealand"

* Fiji
replace exports = exports * 2 if year <= 1964 & countryname == "Fiji"
replace imports = imports * 2 if year <= 1964 & countryname == "Fiji"

* French Polynesia 
replace exports = exports / 5.5 if year <= 1949 & countryname == "FrenchPolynesia"
replace imports = imports / 5.5 if year <= 1949 & countryname == "FrenchPolynesia"

* New Caledonia
replace exports = exports / 5.5 if year <= 1949 & countryname == "NewCaledonia"
replace imports = imports / 5.5 if year <= 1949 & countryname == "NewCaledonia"

* Samoa
replace exports = exports / 25.4377 if year <= 1914 & countryname == "Samoa"
replace imports = imports / 25.4377 if year <= 1914 & countryname == "Samoa"
replace exports = exports * 2 if year <= 1959 & countryname == "Samoa"
replace imports = imports * 2 if year <= 1959 & countryname == "Samoa"

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
