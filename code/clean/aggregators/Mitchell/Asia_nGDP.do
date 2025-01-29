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
* This Stata script opens and cleans the GDP data from Mitchell IHS
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
global input "${data_raw}/aggregators/MITCHELL/Asia_NA"
global output "${data_temp}/MITCHELL/Asia_nGDP"

*===============================================================================
* 			nGDP: Sheet 2
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
	qui replace `var' = strlower(`var') in 4
	qui replace `var' = strlower(`var') in 3
	if `var'[3] == "current prices" &  inlist(`var'[4], "gdp", "gnp", "nnp", "ndp") {
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
reshape_data nGDP

* Save
tempfile temp_c
save `temp_c', emptyok replace

*===============================================================================
* 			nGDP: Sheet 3
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
	if `var'[3] == "current prices" &  inlist(`var'[4], "gdp", "gnp", "nnp", "ndp") {
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
local countries Bangladesh China HongKong India Iran Nepal Pakistan Philippines SaudiArabia Taiwan Thailand Japan SouthKorea
foreach country of local countries {
	convert_units `country' 1945 2010 "B"
}
convert_units Indonesia 1965 1978 "B"
convert_units Indonesia 1979 2010 "Tri"
convert_units Israel 	1950 1980 "Th"
convert_units Japan		1960 2010 "B"
convert_units SouthKorea 1980 2010 "B"
convert_units Lebanon   1988 2010 "B"
convert_units Turkey 	1950 1998 "B"

local countries Malaysia Myanmar Singapore SriLanka Syria
foreach country of local countries {
	convert_units `country' 1975 2010 "B"
}

* Reshape
reshape_data nGDP

* Save
save_merge `temp_c'

* Rename
ren nGDP nGDP_LCU

* Convert units
replace nGDP_LCU = nGDP_LCU * (10^-6) if year <= 1998 & countryname == "Turkey"
replace nGDP_LCU = nGDP_LCU * (10^-3) if year <= 1939 & countryname == "Indonesia"
replace nGDP_LCU = nGDP_LCU * (10^-4) if year <= 1939 & countryname == "Taiwan"
replace nGDP_LCU = nGDP_LCU / 4 if year <= 1939 & countryname == "Taiwan"


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
