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
global input "${data_raw}/aggregators/MITCHELL/Asia_trade"
global output "${data_temp}/MITCHELL/Asia_trade"

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
drop in 1

* Destring
qui drop if year == ""
destring_check

* Convert units
local countries Cyprus Sabah Sarawak 
foreach country of local countries {
	convert_units `country' 1860 1904 "Th"
}
convert_units Japan 1860 1889 "Th"

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
drop in 1

* Destring
qui drop if year == ""
destring_check

* Convert units
local countries Cyprus Sabah Sarawak 
foreach country of local countries {
	convert_units `country' 1860 1904 "Th"
}
convert_units Japan 1860 1889 "Th"

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
drop in 1

* Destring
qui drop if year == ""
destring_check

* Convert units
local countries Brunei Cyprus Sabah Sarawak SouthYemen
foreach country of local countries {
	convert_units `country' 1905 1944 "Th"
}

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
drop in 1

* Destring
qui drop if year == ""
destring_check

* Convert units
local countries Brunei Cyprus Sabah Sarawak SouthYemen
foreach country of local countries {
	convert_units `country' 1905 1944 "Th"
}


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
drop in 1

* Destring
qui drop if year == ""
destring_check

* Convert units
convert_units Brunei 1945 1995 "Th"
convert_units China  1945 1995 "B"

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
drop in 1

* Destring
qui drop if year == ""
destring_check

* Convert units
*convert_units Brunei 1945 1995 "Th" // Probably a mistake in Mitchell, units is in millions already.
convert_units China  1945 1995 "B"

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
drop in 1

* Destring
qui drop if year == ""
destring_check

* Convert units
convert_units Lebanon 1945 1974 "Th"
local countries India HongKong
foreach country of local countries {
	convert_units `country' 1980 1996 "B"
}
convert_units Iran 1965 1995 "B"
convert_units Japan 1950 1996 "B"
convert_units Lebanon 1950 1973 "B"

local countries SaudiArabia Thailand
foreach country of local countries {
	convert_units `country' 1975 1996 "B"
}
convert_units Turkey 1975 1993 "B"

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

* Convert units
convert_units Lebanon 1945 1974 "Th"
local countries India HongKong
foreach country of local countries {
	convert_units `country' 1980 1996 "B"
}
convert_units Iran 1965 1995 "B"
convert_units Japan 1950 1996 "B"
convert_units Lebanon 1950 1973 "B"

local countries SaudiArabia Thailand
foreach country of local countries {
	convert_units `country' 1975 1996 "B"
}
convert_units Turkey 1975 1993 "B"


* Reshape and merge
reshape_data exports
qui merge 1:1 year countryname using `temp_c', nogen
save `temp_c', replace 


* Add USD values
gen imports_USD = .
gen exports_USD = .
replace imports_USD = imports if year >= 1997 & inlist(countryname, "Afghanistan", "Bahrain", "Bangladesh", "Cambodia", "China", "Cyprus", "HongKong", "India", "Japan")
replace imports_USD = imports if year >= 1997 & inlist(countryname, "Kuwait", "Malaya", "Oman", "Pakistan", "SaudiArabia", "Singapore", "SriLanka", "Syria", "Thailand")
replace imports_USD = imports if year >= 1997 & inlist(countryname, "Jordan", "Yemen", "Macau")
replace imports_USD = imports if year >= 1996 & inlist(countryname, "Brunei", "Iran", "Qatar")
replace imports_USD = imports if year >= 1994 & inlist(countryname, "Turkey", "UnitedArabEmirates")
replace imports_USD = imports if year >= 1994 & countryname == "Nepal"
replace imports_USD = imports if year >= 1959 & year <= 1974 & countryname == "Vietnam"
replace imports_USD = imports if year >= 1980 & countryname == "Vietnam"
replace imports_USD = imports if year >= 1975 & inlist(countryname, "Lebanon", "Laos", "Indonesia")
replace imports_USD = imports if year >= 1950 & countryname == "Philippines"
replace imports_USD = imports if year >= 1948 & countryname == "Israel"
replace imports_USD = imports if year >= 1945 & countryname == "SouthKorea"

replace exports_USD = exports if year >= 1997 & inlist(countryname, "Afghanistan", "Bahrain", "Bangladesh", "Cambodia", "China", "Cyprus", "HongKong", "India", "Japan")
replace exports_USD = exports if year >= 1997 & inlist(countryname, "Kuwait", "Malaya", "Oman", "Pakistan", "SaudiArabia", "Singapore", "SriLanka", "Syria", "Thailand")
replace exports_USD = exports if year >= 1997 & inlist(countryname, "Jordan", "Yemen", "Macau")
replace exports_USD = exports if year >= 1996 & inlist(countryname, "Brunei", "Iran", "Qatar")
replace exports_USD = exports if year >= 1994 & inlist(countryname, "Turkey", "UnitedArabEmirates")
replace exports_USD = exports if year >= 1994 & countryname == "Nepal"
replace exports_USD = exports if year >= 1959 & year <= 1974 & countryname == "Vietnam"
replace exports_USD = exports if year >= 1980 & countryname == "Vietnam"
replace exports_USD = exports if year >= 1975 & inlist(countryname, "Lebanon", "Laos", "Indonesia")
replace exports_USD = exports if year >= 1950 & countryname == "Philippines"
replace exports_USD = exports if year >= 1948 & countryname == "Israel"
replace exports_USD = exports if year >= 1945 & countryname == "SouthKorea"

* Fix units
replace imports = imports * (10^-3) if countryname == "Afghanistan"
replace exports = exports * (10^-3) if countryname == "Afghanistan"

* Convert Turkey currency
replace imports = imports / 1000000 if countryname == "Turkey"
replace exports = exports / 1000000 if countryname == "Turkey"

* Convert Taiwan currency
replace imports = imports * 1000 if countryname == "Taiwan" & year >= 1970
replace exports = exports * 1000 if countryname == "Taiwan" & year >= 1970

replace imports = imports * (10^-4) if countryname == "Taiwan" & year < 1945
replace exports = exports * (10^-4) if countryname == "Taiwan" & year < 1945

replace imports = imports / 4 if countryname == "Taiwan" & year < 1945
replace exports = exports / 4 if countryname == "Taiwan" & year < 1945

* Fix units
replace imports = imports * (10^-3) if countryname == "Laos"
replace exports = exports * (10^-3) if countryname == "Laos"


replace imports = . if imports_USD != .
replace exports = . if exports_USD != .

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
