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
* This Stata script opens and cleans the Balance of Payments data from Mitchell IHS
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
global input1 "${data_raw}/aggregators/MITCHELL/Americas_BoP_A"
global input2 "${data_raw}/aggregators/MITCHELL/Americas_BoP_B"
global output "${data_temp}/MITCHELL/Americas_BoP"

*===============================================================================
* 			BOP: Sheet2
*===============================================================================


clear
import_columns_first "${input1}" "2"
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

* Keep only overall current account columns
qui ds year, not
local vars_to_keep 
foreach var in `r(varlist)' {
	if `var'[3] == "OCB" {
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
ren O CostaRica
ren AE DominicanRepublic
ren AM ElSalvador

* Destring
qui drop if year == ""
destring_check

* Reshape and save
reshape_data CA
tempfile temp_c
save `temp_c', emptyok replace

*===============================================================================
* 			BOP part A: Sheet2 
*===============================================================================


import_columns_first "${input2}" "2"
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

* Keep only nominal GDP columns
qui ds year, not
local vars_to_keep 
foreach var in `r(varlist)' {
	if `var'[2] == "OCB" {
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
ren CQ TrinidadandTobago

* Destring
qui drop if year == ""
destring_check

* Reshape and save
reshape_data CA_USD

merge 1:1 countryname year using `temp_c', nogen
save `temp_c', replace

* All data for Mexico is in USD
replace CA = CA_USD if countryname == "Mexico" & CA_USD != .
replace CA_USD = . if countryname == "Mexico"

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
