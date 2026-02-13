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
* This Stata script opens and cleans the investment data from Mitchell IHS
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
global output "${data_temp}/MITCHELL/Africa_stocks"

*===============================================================================
* 			stocks: Sheet 3
*===============================================================================
import_columns "${input}" "3"

* Destring
qui drop if year == ""
destring_check

* Keep relevant columns
qui drop Algeria C E
ren D Algeria

* Reshape
reshape_data stocks
tempfile temp_c
save `temp_c', emptyok replace

*===============================================================================
* 			stocks: Sheet 4
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

* Keep
qui ds year, not
local vars_to_keep 
foreach var in `r(varlist)' {
	qui replace `var' = subinstr(`var', " ", "", .) in 1
    if `var'[3] == "Current Prices" & `var'[4] == "Stocks" {
            local vars_to_keep `vars_to_keep' `var'
        }
}
qui keep year  `vars_to_keep'

* Rename
qui ds year, not
foreach var in `r(varlist)' {
	local newname = `var'[1]
	cap ren `var' `newname'
}

* Destring
qui drop if year == ""
destring_check

* Reshape
reshape_data stocks

* Save
save_merge `temp_c'

*===============================================================================
* 			stocks: Sheet 7
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

* Keep
qui ds year, not
local vars_to_keep 
foreach var in `r(varlist)' {
	qui replace `var' = subinstr(`var', " ", "", .) in 1
    if `var'[3] == "Current Prices" & `var'[4] == "Stocks" {
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
qui replace Zaire = "" if Zaire == "— "
destring_check

* Reshape
reshape_data stocks

* Save
save_merge `temp_c'

*===============================================================================
* 			stocks: Sheet 5
*===============================================================================
* Import
import_columns "${input}" "5"

* Destring
qui drop if year == ""
destring_check

* Keep relevant columns
qui drop Libya C E
ren D Libya

* Reshape
reshape_data stocks

* Save
save_merge `temp_c'


*===============================================================================
* 			stocks: Sheet 6
*===============================================================================
* Import
import_columns "${input}" "6"

* Destring
qui drop if year == ""
destring_check

* Keep relevant columns
qui drop Libya C E F G
ren D Libya

* Reshape
reshape_data stocks

* Save
save_merge `temp_c'


*===============================================================================
* 			Convert the units
*===============================================================================
sort countryname year
qui greshape wide stocks, i(year) j(countryname) string
qui ren stocks* *

* Converting to billions and then back to millions because most countries are in billions
convert_units SouthAfrica 1911 1979 "Th"
convert_units Ghana 1950 1979 "Th"
convert_units SierraLeone 1950 1998 "Th"
convert_units Zambia  1950 1992 "Th"
local countries Egypt Lesotho Liberia Libya Malawi Mauritius
foreach country of local countries {
	qui replace `country' = `country' / 1000
}
qui ds year, not
foreach var in `r(varlist)'{
	qui replace `var' = `var' * 1000
}

* Reshape into long
reshape_data stocks

* Convert units
replace stocks = stocks / 1000 if year == 1993 & countryname == "Zambia"
replace stocks = stocks / 1000 if countryname == "Zambia"
replace stocks = stocks / 1000 if countryname == "Tunisia"
replace stocks = stocks / 1000 if countryname == "Sudan"
replace stocks = stocks / 1000 if countryname == "Sudan" &  year <= 1991
replace stocks = stocks / 10000 if countryname == "Ghana"

replace stocks = stocks / 100000 if year <= 1993 & countryname == "Zaire"
replace stocks = stocks / 1000 if countryname == "Zaire"
replace stocks = stocks / 1000 if year <= 1991 & countryname == "Zaire"
replace stocks = stocks / 1000 if year <= 1977 & countryname == "Zaire"

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

