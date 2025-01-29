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
global input "${data_raw}/aggregators/MITCHELL/Africa_NA"
global output "${data_temp}/MITCHELL/Africa_rGDP"

*===============================================================================
* 			rGDP: Sheet 2
*===============================================================================
* Import
import_columns "${input}" "2"

* Destring
qui drop if year == ""
destring_check

* Keep relevant columns
qui keep year C 
ren C SouthAfrica

* Reshape
reshape_data rGDP

* Save
tempfile temp_c
save `temp_c', emptyok replace


*===============================================================================
* 			rGDP: Sheet 3
*===============================================================================
* Import
import_columns "${input}" "3"

* Destring
qui drop if year == ""
destring_check


* Keep relevant columns
qui keep year E
ren E Algeria

* Reshape
reshape_data rGDP

* Save
save_merge `temp_c'

*===============================================================================
* 			rGDP: Sheet 4
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
	qui replace `var' = subinstr(`var', " ", "", .) in 1
    if `var'[3] != "Current Prices" & `var'[4] == "GDP" {
            local vars_to_keep `vars_to_keep' `var'
        }
}
qui keep year AN `vars_to_keep'

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
reshape_data rGDP

* Save
save_merge `temp_c'

*===============================================================================
* 			rGDP: Sheet 7
*===============================================================================

import_columns_first "${input}" "7"

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
    if `var'[3] != "Current Prices" & `var'[4] == "GDP" {
            local vars_to_keep `vars_to_keep' `var'
        }
}
qui keep year BX T AB AJ AN AT  `vars_to_keep'

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
reshape_data rGDP

* Save
save_merge `temp_c'

*===============================================================================
* 			rGDP: Sheet 5
*===============================================================================
* Import
import_columns "${input}" "5"

* Destring
qui drop if year == ""
destring_check


* Keep relevant columns
qui keep year E
ren E Libya 

* Reshape
reshape_data rGDP

* Save
save_merge `temp_c'

*===============================================================================
* 			rGDP: Sheet 6
*===============================================================================
* Import
import_columns "${input}" "6"

* Destring
qui drop if year == ""
destring_check


* Keep relevant columns
qui keep year E
ren E Libya 

* Reshape
reshape_data rGDP

* Save
save_merge `temp_c'

*===============================================================================
* 			Convert the units
*===============================================================================
sort countryname year
qui greshape wide rGDP, i(year) j(countryname) string
qui ren rGDP* *

* Converting to billions and then back to millions because most countries are in billions
convert_units SouthAfrica 1911 1979 "Th"
convert_units Nigeria 1950 1973 "Th"
convert_units SierraLeone 1950 1998 "Th"
convert_units Zambia  1950 1992 "Th"
local countries Egypt Ethiopia Liberia Libya Malawi Mauritius Zimbabwe
foreach country of local countries {
	qui replace `country' = `country' / 1000
}
qui ds year, not
foreach var in `r(varlist)'{
	qui replace `var' = `var' * 1000
}

* Reshape into long
reshape_data rGDP

* Rename
ren rGDP rGDP_LCU

* Convert units
replace rGDP_LCU = rGDP_LCU / 1000 if countryname == "Tunisia"
replace rGDP_LCU = rGDP_LCU / 1000 if countryname == "Zambia" & year >= 1994
replace rGDP_LCU = rGDP_LCU / 1000 if countryname == "Ghana"
replace rGDP_LCU = rGDP_LCU / 1000000 if countryname == "Sudan"
replace rGDP_LCU = rGDP_LCU * 1000 if year >= 2000 & countryname == "Sudan"

replace rGDP_LCU = . if countryname == "Zaire" // Values differs widely from other sources


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
