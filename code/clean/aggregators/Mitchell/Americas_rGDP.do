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
* This Stata script opens and cleans the real GDP data from Mitchell IHS
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
global input "${data_raw}/aggregators/MITCHELL/Americas_NA"
global output "${data_temp}/MITCHELL/Americas_rGDP"

*===============================================================================
* 			rGDP: Sheet 2
*===============================================================================
import_columns_first "${input}" "2"

* Keep columns
keep year C

* Rename columns
ren C USA

* Destring
qui drop if year == ""
destring_check

* Reshape
reshape_data rGDP

* Save
tempfile temp_c
save `temp_c', emptyok replace

*===============================================================================
* 			rGDP: Sheet 3
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
	qui replace `var' = strtrim(strlower(`var')) in 4
	qui replace `var' = strtrim(strlower(`var')) in 3
	if `var'[3] != "current prices" &  inlist(`var'[4], "gdp", "gnp", "nnp", "ndp") {
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
reshape_data rGDP

* Save
save_merge `temp_c'

*===============================================================================
* 			rGDP: Sheet4
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
	qui replace `var' = strtrim(strlower(`var')) in 4
	qui replace `var' = strtrim(strlower(`var')) in 3
	if `var'[3] != "current prices" &  inlist(`var'[4], "gdp", "gnp", "nnp", "ndp") {
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
drop Mexico
ren Z Mexico

* Destring
qui drop if year == ""
destring_check

* Reshape
reshape_data rGDP

* Save
save_merge `temp_c'


*===============================================================================
* 			rGDP: Sheet5
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
	qui replace `var' = strtrim(strlower(`var')) in 4
	qui replace `var' = strtrim(strlower(`var')) in 3
	if `var'[3] != "current prices" &  inlist(`var'[4], "gdp", "gnp", "nnp", "ndp") {
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
local countries Canada USA
foreach country of local countries {
	convert_units `country' 1950 2010 "B"
}
convert_units Mexico 1950 1993 "B"
convert_units CostaRica 1980 2010 "B"
replace Nicaragua = Nicaragua * 1000 if year >= 1979

* Reshape
reshape_data rGDP

* Save
save_merge `temp_c'

* Rename
ren rGDP rGDP_LCU

* Drop data after 1993
drop if year >= 1993

* Convert units
replace rGDP_LCU = rGDP_LCU * 1000 if year >= 1865 & year <= 1949 & countryname == "USA"
replace rGDP_LCU = rGDP_LCU * 1000 if year >= 1985 & countryname == "Mexico"

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
