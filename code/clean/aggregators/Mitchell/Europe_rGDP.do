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
* This Stata script opens and cleans data on real GDP from Mitchell IHS
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
global output "${data_temp}/MITCHELL/Europe_rGDP"
*===============================================================================
* 			Real GDP: Sheet2
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

* Keep only nominal GDP columns
qui ds year, not
local vars_to_keep 
foreach var in `r(varlist)' {
	qui replace `var' = strlower(`var') in 3
    if `var'[3] == "constant prices" & inlist(`var'[4], "GDP", "GNP", "NNP") {
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
ren AD UnitedKingdom

* Destring
qui drop if year == ""
destring_check

* Convert units
convert_units Italy 1815 1899 "B"

* Reshape and save
reshape_data rGDP
tempfile temp_c
save `temp_c', emptyok replace


*===============================================================================
* 			Real GDP: Sheet3
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

* Keep only nominal GDP columns
qui ds year, not
local vars_to_keep 
foreach var in `r(varlist)' {
	qui replace `var' = strlower(`var') in 3
    if `var'[3] == "constant prices" & inlist(`var'[4], "GDP", "GNP", "NNP") {
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
ren BF UnitedKingdom

* Destring
qui drop if year == ""
replace Hungary = "" if Hungary == "million pengos"
replace Russia = "" if Russia == "1937 prices"
destring_check

* Convert units
local countries Austria Belgium Bulgaria Greece Italy Russia Spain Yugoslavia
foreach country of local countries {
	qui convert_units `country' 1900 1944 "B"
}

* Reshape and save
reshape_data rGDP

* Merge and save
save_merge `temp_c'

*===============================================================================
* 			Real GDP: Sheet4
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

* Keep only nominal GDP columns
qui ds year, not
local vars_to_keep 
foreach var in `r(varlist)' {
	qui replace `var' = strlower(`var') in 3
    if `var'[3] == "constant prices" & inlist(`var'[4], "GDP", "GNP", "NNP", "NMP") {
            local vars_to_keep `vars_to_keep' `var'
        }
}
qui keep year H Z AV AZ BP BT CB `vars_to_keep'

* Rename columns
qui ds year, not
foreach var in `r(varlist)' {
	local newname = `var'[1]
	cap ren `var' `newname'
}
ren AF Germany
ren BP Russia
ren CF UnitedKingdom

* Destring
qui drop if year == ""
destring_check

* Convert units to billions
local countries Yugoslavia
foreach country of local countries {
	convert_units `country' 1945 1979 "Th"
}

* Convert now everything back to millions
qui su year
qui ds year, not
foreach country in `r(varlist)' {
	qui convert_units `country' 1945 1979 "B"
}

* Convert Italy to millions
convert_units Italy 1946 1979 "B"

* Reshape and save
reshape_data rGDP

* Merge and save
save_merge `temp_c'


*===============================================================================
* 			Real GDP: Sheet5
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

* Keep only nominal GDP columns
qui ds year, not
local vars_to_keep 
foreach var in `r(varlist)' {
	qui replace `var' = strlower(`var') in 3
    if `var'[3] == "constant prices" & inlist(`var'[4], "GDP", "GNP", "NMP", "NNP") {
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
ren AF Germany
ren AR Ireland
ren CD UnitedKingdom

* Destring
drop in 31/32
qui drop if year == ""
destring_check


* Convert units to billions
local countries Hungary Ireland
foreach country of local countries {
	convert_units `country' 1945 1979 "Th"
}

* Convert now everything back to millions
qui ds year, not
foreach country in `r(varlist)' {
	qui convert_units `country' 1980 1998 "B"
}

* Convert Italy to millions
convert_units Italy 1980 1998 "B"

* Reshape and save
reshape_data rGDP

* Merge and save
save_merge `temp_c'

* Rename
ren rGDP rGDP_LCU

* Drop data after 1993
drop if year >= 1994

* Drop Poland in 1947 because of a chainlinking issue down the line that can't be solved when sources change
replace rGDP_LCU = . if countryname == "Poland" & inrange(year, 1947, 1948)
replace rGDP_LCU = . if countryname == "Hungary" & year < 1925

* Fix units
replace rGDP_LCU = rGDP_LCU * 1000 if countryname == "Finland" & year <= 1944

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

* Adjust breaks
adjust_breaks

* Sort
sort countryname year

* Order
order countryname year

* Check for duplicates
isid countryname year

* Save
save "${output}", replace

