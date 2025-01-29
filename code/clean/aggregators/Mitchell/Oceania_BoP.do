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
global input1 "${data_raw}/aggregators/MITCHELL/Oceania_BoP_A" 
global input2 "${data_raw}/aggregators/MITCHELL/Oceania_BoP_B"
global output "${data_temp}/MITCHELL/Oceania_BoP"
*===============================================================================
* 			BOP part A: Sheet2
*===============================================================================
clear
import_columns "${input1}" "2"

* Keep
keep year Australia

* Destring
qui drop if year == ""
destring_check

* Convert currency
convert_currency Australia 1950 2

* Reshape and save
reshape_data CA
tempfile temp_c
save `temp_c', emptyok replace


*===============================================================================
* 			BOP part B: Sheet2
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

* Keep only total overall current balance columns
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
	local newname = `var'[1]
	cap ren `var' `newname'
}
ren W NewZealand

* Destring
qui drop if year == ""
destring_check


* Merge and save
reshape_data CA_USD
merge 1:1 countryname year using `temp_c', nogen
save `temp_c', replace

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
