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
global input "${data_raw}/aggregators/MITCHELL/Oceania_govrev"
global output "${data_temp}/MITCHELL/Oceania_govtax"

*===============================================================================
* 			govtax: Sheet 3
*===============================================================================
import_columns_first "${input}" "3"

* Destring
qui drop if year == ""
destring_check

keep year G H

* Convert units
convert_units G 1870 1899 "Th"
convert_units H 1870 1899 "Th"
egen NewZealand = rowtotal(G H)
drop G H

* Reshape
reshape_data govtax

* Save
tempfile temp_c
save `temp_c', emptyok replace

*===============================================================================
* 			govtax: Sheet 4
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
	if `var'[2] != "total" {
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


* Sum taxes columns 
egen Australiatax = rowtotal(Australia D E)
egen NewZealandtax = rowtotal(NewZealand J K)
keep year *tax
ren *tax *

* Convert units
convert_units NewZealand 1900 1919 "Th"

* Reshape
reshape_data govtax
replace govtax = . if govtax == 0

* Save
save_merge `temp_c'

*===============================================================================
* 			govtax: Sheet 5
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

* Keep 
qui ds year, not
local vars_to_keep 
foreach var in `r(varlist)' {
	qui replace `var' = strlower(`var') in 2
	if `var'[2] != "total" {
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


* Sum taxes columns 
egen Australiatax = rowtotal(Australia D E F)
egen NewZealandtax = rowtotal(NewZealand K L)
keep year *tax
ren *tax *

* Convert units
convert_units Australia  1975 2010 "B"

* Reshape
reshape_data govtax
replace govtax = . if govtax == 0

* Save
save_merge `temp_c'

*===============================================================================
* 			Convert currencies
*===============================================================================
qui greshape wide govtax, i(year) j(countryname)
ren govtax* * 

* Convert
convert_currency Australia  1964 2
convert_currency NewZealand	1964 2

* Reshape
reshape_data govtax

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
