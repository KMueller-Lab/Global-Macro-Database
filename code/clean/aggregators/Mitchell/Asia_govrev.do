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
global input "${data_raw}/aggregators/MITCHELL/Asia_govrev"
global output "${data_temp}/MITCHELL/Asia_govrev"

*===============================================================================
* 			govrev: Sheet 2
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
convert_units Cyprus 1855 1904 "Th"

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

* Keep only total columns
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
convert_units StraitsSettlements 1855 1904 "Th"

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
local countries Cyprus Palestine
foreach country of local countries {
	convert_units `country' 1905 1944 "Th"
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

* Keep only total columns
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
replace SouthKorea = "" if SouthKorea == "thousand million won"
destring_check

* Convert units
convert_units Bangladesh 1945 2010 "B"
convert_units Iran 		1945 2010 "B"
convert_units Indonesia  1945 1979 "B"
convert_units Indonesia  1980 2010 "Tri"
convert_units India 		1960 2010 "B"
convert_units Israel		1985 2010 "B"
convert_units Japan		1945 1964 "B"
convert_units Japan		1965 2010 "Tri"
convert_units SouthKorea	1945 1978 "B"
convert_units SouthKorea	1980 2010 "Tri"
convert_units Malaysia	1975 2010 "B"
 
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

* Keep only government revenue columns
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
cap destring_check
destring Syria Turkey Vietnam, force replace 

* Convert units
local countries Pakistan Phillippines
foreach country of local countries {
	convert_units `country' 1970 2010 "B"
}
convert_units Singapore 1980 2010 "B"
convert_units SriLanka  1975 2010 "B"
convert_units Syria     1971 2010 "B"
convert_units Taiwan    1945 2010 "B"
convert_units Thailand  1962 2010 "B"
convert_units Turkey    1959 1988 "B"
convert_units Turkey    1989 2010 "Tri"
convert_units Vietnam   1954 2010 "B"

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
convert_currency Turkey 1984 1/1000
convert_currency Indonesia 1964 1/1000
convert_currency Israel 1964 1.1
convert_currency Israel 1974 1/1000
replace Vietnam = Vietnam / 1000

* Reshape
reshape_data govrev

* Convert units for Iran
replace govrev = govrev * 1000 if inrange(year, 1940, 1944) & countryname == "Iran"

* Convert units for Turkey
replace govrev = govrev / (10^6) if countryname == "Turkey"

* Convert units for Taiwan
replace govrev = govrev * (10^-4) if year <= 1939 & countryname == "Taiwan"
replace govrev = govrev / 4 if year <= 1939 & countryname == "Taiwan"

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
