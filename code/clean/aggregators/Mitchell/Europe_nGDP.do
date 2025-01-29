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
* This Stata script opens and cleans data on nominal GDP from Mitchell IHS
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
global output "${data_temp}/MITCHELL/Europe_nGDP"
*===============================================================================
* 			NOMINAL GDP: Sheet2
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
    if `var'[3] == "current prices" & inlist(`var'[4], "GDP", "GNP", "NNP") {
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
ren AB UnitedKingdom

* Destring
qui drop if year == ""
destring_check


* Convert units
convert_units Italy 1815 1899 "B"

* Reshape and save
reshape_data nGDP
tempfile temp_c
save `temp_c', emptyok replace


*===============================================================================
* 			NOMINAL GDP: Sheet3
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
    if `var'[3] == "current prices" & inlist(`var'[4], "GDP", "GNP", "NNP") {
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
ren BD UnitedKingdom

* Destring
qui drop if year == ""
destring_check


* Convert units
qui su year
local countries Austria Belgium Bulgaria Greece Italy Russia Spain Yugoslavia
foreach country of local countries {
	convert_units `country' 1900 1944 "B"
}

* Reshape and save
reshape_data nGDP

* Merge and save
save_merge `temp_c'

*===============================================================================
* 			NOMINAL GDP: Sheet4
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
    if `var'[3] == "current prices" & inlist(`var'[4], "GDP", "GNP", "NNP", "NMP") {
            local vars_to_keep `vars_to_keep' `var'
        }
}
qui keep year F J X AT AX BN BR BZ `vars_to_keep'

* Rename columns
qui ds year, not
foreach var in `r(varlist)' {
	local newname = `var'[1]
	cap ren `var' `newname'
}
ren AB EastGermany
ren AD Germany
ren BN Russia
ren CD UnitedKingdom

* Destring
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
	qui convert_units `country' 1945 1979 "B"
}

* Convert Italy to millions
convert_units Italy 1945 1979 "B"
convert_units Yugoslavia 1945 1979 "B"

* Reshape and save
reshape_data nGDP

* Merge and save
save_merge `temp_c'


*===============================================================================
* 			NOMINAL GDP: Sheet5
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
    if `var'[3] == "current prices" & inlist(`var'[4], "GDP", "GNP", "NMP", "NNP") {
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
ren AB EastGermany
ren AD Germany
ren AP Ireland
ren BN Russia
ren CB UnitedKingdom

* Destring
qui replace Yugoslavia = "1147787" if Yugoslavia == "1,147, 787"

* Destring
qui drop if year == ""
destring_check


* Convert units to billions
qui su year
local countries Hungary Ireland
foreach country of local countries {
	convert_units `country' 1980 2010 "Th"
}

* Convert now everything back to millions
qui su year
qui ds year, not
foreach country in `r(varlist)' {
	qui convert_units `country' 1980 2010 "B"
}

* Convert Italy to millions
convert_units Italy 1980 1998 "B"

* Reshape and save
reshape_data nGDP

* Merge and save
save_merge `temp_c'

* Rename
ren nGDP nGDP_LCU

* Drop data after 1998
drop if year >= 1998

* Change Czechoslovakia to Czech Republic after 1994
replace countryname = "CzechRepublic" if countryname == "Czechoslovakia" & year >= 1994

* Adjust units
replace nGDP_LCU = nGDP_LCU / 100 if year <= 1939 & countryname == "France"
replace nGDP_LCU = nGDP_LCU / 1000 if countryname == "Bulgaria"
replace nGDP_LCU = nGDP_LCU / 1000 if countryname == "Bulgaria" & year <= 1991
replace nGDP_LCU = nGDP_LCU * 1000 if countryname == "Hungary" & year >= 1950
replace nGDP_LCU = nGDP_LCU / 10 if year == 1960 & countryname == "Italy"
replace nGDP_LCU = nGDP_LCU / (10^12) if countryname == "Germany" & year <= 1913
replace nGDP_LCU = nGDP_LCU / 10000 if countryname == "Poland" & year <= 1990


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
