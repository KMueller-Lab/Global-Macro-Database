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
* This Stata script opens and cleans the government revenue data from Mitchell IHS
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
global input "${data_raw}/aggregators/MITCHELL/Latam_govrev"
global output "${data_temp}/MITCHELL/Latam_govrev"

*===============================================================================
* 			govrev: Sheet 2
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

* Keep 
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

* Destring
qui drop if year == ""
destring_check


* Convert units
convert_units Guyana 1823 1864 "Th"

* Reshape
reshape_data govrev

* Save
tempfile temp_c
save `temp_c', emptyok replace

*===============================================================================
* 			govrev: Sheet 3
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

* Keep  
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

* Destring
qui drop if year == ""
destring_check


* Convert units
convert_units Guyana 1865 1894 "Th"

* Reshape
reshape_data govrev

* Save
save_merge `temp_c'

*===============================================================================
* 			govrev: Sheet 4
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

* Keep  
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

* Destring
qui drop if year == ""
destring_check


* Reshape
reshape_data govrev

* Save
save_merge `temp_c'

*===============================================================================
* 			govrev: Sheet 5
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

* Keep only needed columns
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

* Destring
qui drop if year == ""
destring_check


* Convert units
convert_units Argentina 1955 1969 "B"
convert_units Argentina 1970 1978 "B"
convert_units Argentina 1979 1984 "Tri"
convert_units Argentina 1985 1988 "B"
convert_units Bolivia 1955 2010 "B"
convert_units Brazil 1955 1966  "B"
convert_units Brazil 1970 1988  "B"
convert_units Brazil 1990 1992 "Th"
convert_units Chile  1950 1954 "B"
convert_units Chile  1970 2010 "B"
convert_units Colombia 1975 2010 "B"
convert_units Paraguay 1975 2010 "B"
convert_units Ecuador 1975 1993 "B"
convert_units Peru 1965 1984 "B"
convert_units Peru 1985 1987 "B"
convert_units Peru 1988 2010 "Th"
convert_units Uruguay 1965 1974 "B"
convert_units Uruguay 1980 2010 "B"
convert_units Venezuela 1975 2010 "B"


* Reshape
reshape_data govrev

* Save
save_merge `temp_c'


*===============================================================================
* 			Convert currencies
*===============================================================================
qui greshape wide govrev, i(year) j(countryname)
ren govrev* * 

* Convert
convert_currency Argentina 1969 1/100
convert_currency Argentina 1984 1/1000
convert_currency Argentina 1989 1/10000
convert_currency Bolivia   1974 1/1000
convert_currency Brazil    1966 1/1000
convert_currency Brazil    1984 1/1000
convert_currency Brazil    1988 1/2750
convert_currency Brazil    1989 1/1000000

* Reshape
reshape_data govrev

* Convert units
replace govrev = govrev / 1000 if year <= 1974 & countryname == "Chile"
replace govrev = govrev / 1000 if year <= 1954 & countryname == "Chile"

replace govrev = govrev / 2500 if year <= 1993 & countryname == "Ecuador"
replace govrev = govrev * (10^-14) if countryname == "Venezuela"

replace govrev = govrev / 1000 if countryname == "Uruguay"
replace govrev = govrev / 1000 if year <= 1974 & countryname == "Uruguay"

replace govrev = govrev * 1000 if year >= 1990 & countryname == "Peru"
replace govrev = govrev * 1 if year == 1989 & countryname == "Peru"
replace govrev = govrev / 1000 if year <= 1988 & countryname == "Peru"
replace govrev = govrev / 1000 if year <= 1987 & countryname == "Peru"
replace govrev = govrev / 1000 if year <= 1984 & countryname == "Peru"

replace govrev = govrev / 1000 if countryname == "Suriname"

replace govrev = govrev / 1000 if countryname == "Bolivia"
replace govrev = govrev / 100 if countryname == "Bolivia" & year <= 1984

replace govrev = govrev / 10000 if countryname == "Argentina" & year <= 1984


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
