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
* This Stata script opens and cleans the government revenue data from Mitchell IHS
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
global input "${data_raw}/aggregators/MITCHELL/Americas_govrev"
global output "${data_temp}/MITCHELL/Americas_govrev"

*===============================================================================
* 			govrev: Sheet 2
*===============================================================================
clear
import_columns "${input}" "2"

* Destring
qui drop if year == ""
destring_check

* Reshape
reshape_data govrev

* Save
tempfile temp_c
save `temp_c', emptyok replace

*===============================================================================
* 			govrev: Sheet 3
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

* Keep only total revenue
qui ds year, not
local vars_to_keep 
foreach var in `r(varlist)' {
	qui replace `var' = strlower(`var') in 2
	if `var'[2] == "total" {
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

* Reshape
reshape_data govrev

* Save
save_merge `temp_c'

*===============================================================================
* 			govrev: Sheet 4
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

* Keep 
qui ds year, not
local vars_to_keep 
foreach var in `r(varlist)' {
	qui replace `var' = strlower(`var') in 2
	if `var'[2] == "total" {
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
local countries Barbados Jamaica Trinidad
foreach country of local countries {
	convert_units `country' 1825 1864 "Th"
}

* Reshape
reshape_data govrev

* Save
save_merge `temp_c'

*===============================================================================
* 			govrev: Sheet 5
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

* Keep only nominal GDP columns
qui ds year, not
local vars_to_keep 
foreach var in `r(varlist)' {
	qui replace `var' = strlower(`var') in 2
	if `var'[2] == "total" {
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
local countries Barbados Jamaica Trinidad
foreach country of local countries {
	convert_units `country' 1865 1904 "Th"
}

* Reshape
reshape_data govrev

* Save
save_merge `temp_c'

*===============================================================================
* 			govrev: Sheet 6
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

* Keep only nominal GDP columns
qui ds year, not
local vars_to_keep 
foreach var in `r(varlist)' {
	qui replace `var' = strlower(`var') in 2
	if `var'[2] == "total" {
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
ren V Trinidad

* Destring
qui drop if year == ""
destring_check

* Convert units
local countries Jamaica Trinidad
foreach country of local countries {
	convert_units `country' 1905 1949 "Th"
}
convert_units Barbados 1905 1945 "Th"

* Reshape
reshape_data govrev

* Save
save_merge `temp_c'
*===============================================================================
* 			govrev: Sheet 7
*===============================================================================

import_columns_first "${input}" "7"

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

* Keep only nominal GDP columns
qui ds year, not
local vars_to_keep 
foreach var in `r(varlist)' {
	qui replace `var' = strlower(`var') in 2
	if `var'[2] == "total" {
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
ren V Trinidad

* Destring
qui drop if year == ""
destring_check

* Convert units
convert_units Mexico 1965 2010 "B"
convert_units CostaRica 1985 2010 "B"
convert_units Canada 1998 2010 "B"
convert_units Nicaragua 1985 1987 "B"

* Reshape
reshape_data govrev

* Save
save_merge `temp_c'
*===============================================================================
* 			Convert currencies
*===============================================================================
qui greshape wide govrev, i(year) j(countryname)
ren govrev* * 

* Convert
convert_currency Nicaragua 1912 0.08
convert_currency Nicaragua 1987 0.0001
convert_currency Nicaragua 1989 0.2
convert_currency Jamaica 1968 2
convert_currency Guatemala 1923 1/60

* Convert El Salvador currency
replace ElSalvador = ElSalvador / 8.75 if year <= 2000

* Fix units
replace Cuba = Cuba / 1000 if year <= 1814
replace USA = USA * 1000 if year >= 1960
replace Mexico = Mexico / 1000
replace Nicaragua = Nicaragua / 1000 if year <= 1988
replace Nicaragua = Nicaragua / 1000000 if year <= 1988
replace Nicaragua = Nicaragua / 1000 if year == 1988

* Reshape wide
reshape_data govrev

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

