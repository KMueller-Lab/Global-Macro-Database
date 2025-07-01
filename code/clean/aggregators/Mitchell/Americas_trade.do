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
* This Stata script opens and cleans the trade data from Mitchell IHS
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
global input "${data_raw}/aggregators/MITCHELL/Americas_trade"
global output "${data_temp}/MITCHELL/Americas_trade"

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
local countries Barbados Jamaica Mexico Trinidad
foreach country of local countries {
	convert_units `country' 1790 1839 "Th"
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

* Keep only imports
qui ds year, not
local vars_to_keep 
foreach var in `r(varlist)' {
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
local countries Barbados Jamaica Mexico Trinidad
foreach country of local countries {
	convert_units `country' 1790 1839 "Th"
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
local countries Barbados ElSalvador Guatemala Jamaica  Nicaragua Trinidad 
foreach country of local countries {
	convert_units `country' 1840 1884 "Th"
}
convert_units Mexico 1840 1871 "Th"

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
local countries Barbados ElSalvador Guatemala Jamaica Nicaragua Trinidad
foreach country of local countries {
	convert_units `country' 1840 1884 "Th"
}
convert_units Mexico 1840 1871 "Th"

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
local countries Barbados Jamaica Honduras Trinidad
foreach country of local countries {
	convert_units `country' 1885 1929 "Th"
}

convert_units ElSalvador 1885 1900 "Th"
convert_units Guatemala  1885 1919 "Th"
convert_units Nicaragua  1885 1924 "Th"

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
local countries Barbados Jamaica Honduras Trinidad
foreach country of local countries {
	convert_units `country' 1885 1929 "Th"
}
convert_units ElSalvador 1885 1900 "Th"
convert_units Guatemala  1885 1919 "Th"
convert_units Nicaragua  1885 1924 "Th"

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
ren AH Trinidad

* Destring
qui drop if year == ""
destring_check

* Convert units
convert_units Barbados   1930 1939 "Th"
convert_units Honduras   1930 1938 "Th"
convert_units Jamaica    1930 1949 "Th"
convert_units Trinidad   1930 1944 "Th"

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
ren AI Trinidad

* Destring
qui drop if year == ""
destring_check

* Convert units
convert_units Barbados   1930 1939 "Th"
convert_units Honduras   1930 1938 "Th"
convert_units Jamaica    1930 1949 "Th"
convert_units Trinidad   1930 1944 "Th"

* Reshape and merge
reshape_data exports
qui merge 1:1 year countryname using `temp_c', nogen
save `temp_c', replace 

*===============================================================================
* 			Imports: Sheet6
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

* Keep only imports
qui ds year, not
local vars_to_keep 
foreach var in `r(varlist)' {
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
ren AF Trinidad

* Destring
qui drop if year == ""
destring_check

* Convert units
convert_units Mexico 1980 2010 "B"

* Reshape and save
reshape_data imports
gen exports = .
save_merge `temp_c'



*===============================================================================
* 			Exports: Sheet6
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

* Keep only imports
qui ds year, not
local vars_to_keep 
foreach var in `r(varlist)' {
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
ren AG Trinidad

* Destring
qui drop if year == ""
destring_check

* Convert units
convert_units Mexico 1980 2010 "B"

* Reshape and merge
reshape_data exports
qui merge 1:1 year countryname using `temp_c', nogen
save `temp_c', replace 

* Fix Trinidad's name
replace countryname = "TrinidadandTobago" if countryname == "Trinidad"

* Add USD units
gen exports_USD = .
gen imports_USD = .

* Dominican republic
replace exports_USD = exports if countryname == "DominicanRepublic" & year >= 1989
replace imports_USD = imports if countryname == "DominicanRepublic" & year >= 1989

* Nicaragua
replace exports_USD = exports if countryname == "Nicaragua" & year >= 1988
replace imports_USD = imports if countryname == "Nicaragua" & year >= 1988

* Honduras
replace exports_USD = exports if countryname == "Honduras" & year >= 1989
replace imports_USD = imports if countryname == "Honduras" & year >= 1989

* Mexico
replace exports_USD = exports if countryname == "Mexico" & year >= 1994
replace imports_USD = imports if countryname == "Mexico" & year >= 1994

* Jamaica
replace exports_USD = exports if countryname == "Jamaica" & year >= 1998
replace imports_USD = imports if countryname == "Jamaica" & year >= 1998

* Costa Rica
replace exports_USD = exports if countryname == "CostaRica" & year >= 1938
replace imports_USD = imports if countryname == "CostaRica" & year >= 1938

* Guatemala
replace exports_USD = exports if countryname == "Guatemala" & year >= 1975
replace imports_USD = imports if countryname == "Guatemala" & year >= 1975

* Trinidad
replace exports_USD = exports if countryname == "TrinidadandTobago" & year >= 1998
replace imports_USD = imports if countryname == "TrinidadandTobago" & year >= 1998

* United States
replace exports_USD = exports if countryname == "USA"
replace imports_USD = imports if countryname == "USA"


* Drop USD values in LCU columns
replace exports = . if exports_USD != .
replace imports = . if imports_USD != .



*===============================================================================
* 			Convert currencies
*===============================================================================

replace exports = exports * 2 if countryname == "Jamaica" & year <= 1949
replace imports = imports * 2 if countryname == "Jamaica" & year <= 1949

replace exports = exports * 10 if countryname == "Nicaragua" & year <= 1973
replace imports = imports * 10 if countryname == "Nicaragua" & year <= 1973

replace imports = imports / 100 if countryname == "Guadeloupe" & year <= 1957
replace exports = exports / 100 if countryname == "Guadeloupe" & year <= 1957

replace imports = imports / 100 if countryname == "Martinique" & year <= 1957
replace exports = exports / 100 if countryname == "Martinique" & year <= 1957

replace exports = exports / 1000 if countryname == "Mexico"
replace imports = imports / 1000 if countryname == "Mexico" 

replace imports = imports / 5000 if year <= 1990 & countryname == "Nicaragua"
replace imports = imports / 1000000 if countryname == "Nicaragua"
replace imports = imports / 12.5 if year <= 1912 & countryname == "Nicaragua"

replace exports = exports / 5000 if year <= 1990 & countryname == "Nicaragua"
replace exports = exports / 1000000 if countryname == "Nicaragua"
replace exports = exports / 12.5 if year <= 1912 & countryname == "Nicaragua"

replace exports = exports / 8.5 if countryname == "ElSalvador" & year <= 1999
replace imports = imports / 8.5 if countryname == "ElSalvador" & year <= 1999


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

