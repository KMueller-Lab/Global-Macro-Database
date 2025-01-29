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
* This Stata script opens and cleans data on government revenue from Mitchell IHS
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
global input "${data_raw}/aggregators/MITCHELL/Europe_govrev"
global output "${data_temp}/MITCHELL/Europe_govrev"

*===============================================================================
* 			govrev: Sheet2
*===============================================================================
clear
import_columns "${input}" "2"

* Rename columns
ren UK UnitedKingdom
keep year Austria UnitedKingdom

* Destring
qui drop if year == ""
destring_check


* Convert units
convert_units UnitedKingdom 1750 1799 "Th"

* Reshape and save
reshape_data govrev
tempfile temp_c
save `temp_c', emptyok replace


*===============================================================================
* 			govrev: Sheet3
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
ren R Russia

* Destring
qui drop if year == ""
destring_check


* Convert units
convert_units UnitedKingdom 1800 1809 "Th"

* Reshape and append
reshape_data govrev
save_merge `temp_c'

*===============================================================================
* 			govrev: Sheet4
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
ren BD Russia

* Destring
qui drop if year == ""
destring_check


* Reshape and append
reshape_data govrev
save_merge `temp_c'


*===============================================================================
* 			govrev: Sheet5
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
ren BZ Russia
ren CW Serbia

* Destring
qui drop if year == ""
destring_check


* Convert units
convert_units Serbia 1942 1949 "B"
convert_units France 1945 1949 "B"
convert_units Italy  1946 1949 "B"
convert_units Spain  1947 1949 "B"

* Reshape and append
reshape_data govrev
save_merge `temp_c'

*===============================================================================
* 			govrev: Sheet6
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
ren BM Russia
ren Yugoslavia Serbia
ren WestGermany Germany

* Destring
qui drop if year == ""
destring_check


* Convert units
local countries Austria Belgium Finland France Germany Italy Romania Spain Serbia
foreach country of local countries {
	convert_units `country' 1950 2010 "B"
}

* Convert units
local countries Denmark Greece
foreach country of local countries {
	convert_units `country' 1970 2010 "B"
}

* Convert units
local countries Sweden Portugal Norway Netherlands Italy
foreach country of local countries {
	convert_units `country' 1975 2010 "B"
}
convert_units United 1980 2010 
 
* Reshape and append
reshape_data govrev
save_merge `temp_c'

*===============================================================================
* 			Convert units
*===============================================================================
qui greshape wide govrev, i(year) j(countryname) 
ren govrev* *
convert_currency Austria 1892 2
convert_currency Hungary 1892 2
convert_currency Russia 1839 1/4
convert_currency Austria 1923 1/10000
convert_currency Hungary 1924 1/12500
convert_currency Russia  1939 1/10000
convert_currency France  1959 1/100
replace UnitedKingdom = UnitedKingdom * 1000 if year >= 1980

* Reshape
reshape_data govrev

* Fix units
replace govrev = govrev / 100 if year <= 1962 & countryname == "Finland"
replace govrev = govrev / 10000 if countryname == "Romania"
replace govrev = govrev / 10000 if countryname == "Romania" & year <= 1943
replace govrev = govrev / 1000 if countryname == "Italy" & year >= 1999
replace govrev = govrev / 10000000 if countryname == "Bulgaria"
replace govrev = govrev / (10^12)   if countryname == "Germany" & year <= 1923
replace govrev = govrev * (10^-6) / 5 if countryname == "Greece" & year <= 1940
replace govrev = govrev * 1000 if  countryname == "Russia"



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
