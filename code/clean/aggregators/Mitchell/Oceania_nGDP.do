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
* This Stata script opens and cleans the government expenditure data from Mitchell IHS
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
global input "${data_raw}/aggregators/MITCHELL/Oceania_NA"
global output "${data_temp}/MITCHELL/Oceania_nGDP"

*===============================================================================
* 			nGDP: Sheet 2
*===============================================================================
import_columns "${input}" "2"

* Destring
qui drop if year == ""
destring_check


* Convert units
convert_units Australia 1789 1824 "Th"

* Reshape
reshape_data nGDP

* Save
tempfile temp_c
save `temp_c', emptyok replace


*===============================================================================
* 			nGDP: Sheet 3
*===============================================================================
import_columns "${input}" "3"

* Destring
qui drop if year == ""
destring_check


* Reshape
reshape_data nGDP

* Save
save_merge `temp_c'

*===============================================================================
* 			nGDP: Sheet 4
*===============================================================================
import_columns "${input}" "4"

* Destring
qui drop if year == ""
destring_check

keep year Australia

* Reshape
reshape_data nGDP

* Save
save_merge `temp_c'

*===============================================================================
* 			nGDP: Sheet 5
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
	qui replace `var' = subinstr(`var', " ", "", .) in 1
    if `var'[3] == "Current Prices" & inlist(`var'[4], "GDP", "GNP", "API/NNP") {
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

* Destring
qui drop if year == ""
destring_check


* Reshape
reshape_data nGDP

* Save
save_merge `temp_c'

*===============================================================================
* 			nGDP: Sheet 6
*===============================================================================
import_columns_first "${input}" "6"

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
	qui replace `var' = subinstr(`var', " ", "", .) in 1
    if `var'[3] == "Current Prices" & inlist(`var'[4], "GDP", "GNP", "API/NNP", "NNP/GDP") {
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

* Destring
qui drop if year == ""
destring_check


* Convert units
convert_units Australia 1965 2010 "B"

* Reshape
reshape_data nGDP

* Save
save_merge `temp_c'


*===============================================================================
* 			Convert currencies
*===============================================================================
sort countryname year
qui greshape wide nGDP, i(year) j(countryname) string
qui ren nGDP* *

* Converting to billions and then back to millions because most countries are in billions
convert_currency Australia  1900 2
convert_currency NewZealand	1959 2

* Reshape into long
reshape_data nGDP

* Rename
ren nGDP nGDP_LCU


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


*===============================================================================
* 			Adjust breaks and save
*===============================================================================
* Adjust the breaks
*adjust_breaks nGDP_LCU

* Save
save "${output}", replace

