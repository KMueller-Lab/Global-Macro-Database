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
global input "${data_raw}/aggregators/MITCHELL/Latam_NA"
global output "${data_temp}/MITCHELL/Latam_rGDP"

*===============================================================================
* 			rGDP: Sheet 2
*===============================================================================
clear
import_columns_first "${input}" "2"

* Keep columns
keep year C
ren C Brazil

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
	if `var'[3] != "current prices" &  inlist(`var'[4], "gdp") {
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
local countries Argentina Chile
foreach country of local countries {
	convert_units `country' 1900 1934 "B"
}

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
	if `var'[3] != "current prices" &  inlist(`var'[4], "gdp") {
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
local countries Argentina Chile Paraguay Venezuela Ecuador
foreach country of local countries {
	convert_units `country' 1935 1969 "B"
}

replace Argentina = Argentina * 100 if year >= 1965
replace Uruguay = Uruguay * 1000 if year >= 1960

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
	if `var'[3] != "current prices" &  inlist(`var'[4], "gdp") {
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
local countries Bolivia Brazil Colombia Ecuador Paraguay Uruguay Venezuela
foreach country of local countries {
	convert_units `country' 1970 1993 "B"
}

replace Argentina = Argentina * 100000 

* Reshape
reshape_data rGDP

* Save
save_merge `temp_c'

* Rename
ren rGDP rGDP_LCU

* Drop data after 1993
drop if year >= 1993

* Convert units
replace rGDP_LCU = rGDP_LCU * 1000 if year >= 1965 & countryname == "Chile"
replace rGDP_LCU = rGDP_LCU * 1000 if year >= 1970 & countryname == "Chile"
replace rGDP_LCU = rGDP_LCU * 1000 if year <= 1969 & countryname == "Colombia"
replace rGDP_LCU = rGDP_LCU / 1000 if year <= 1975 & year >= 1970 & countryname == "Brazil"
replace rGDP_LCU = rGDP_LCU * 1000 if year >= 1980 & countryname == "Peru"
replace rGDP_LCU = rGDP_LCU * 10 if year <= 1935 & countryname == "Argentina"

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
