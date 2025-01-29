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
* This Stata script opens and cleans data on money supply from Mitchell IHS
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
global input "${data_raw}/aggregators/MITCHELL/Europe_money_supply"
global output "${data_temp}/MITCHELL/Europe_money_supply"

*===============================================================================
* 			Money supply: Sheet 2
*===============================================================================

clear
import_columns "${input}" "2"

* Keep only M1 columns
qui ds year, not
local vars_to_keep 
foreach var in `r(varlist)' {
	qui replace `var' = strlower(`var') in 2
    if `var'[2] == "m1" {
            local vars_to_keep `vars_to_keep' `var'
        }
}
qui keep year `vars_to_keep'

* Rename columns
ren UK UnitedKingdom
ren WestGermany Germany

* Destring
qui drop if year == ""
destring_check


* Convert units
convert_units Italy 1950 2010 "B" // Convert italy to Billions from Trillions
convert_units Ireland 1950 2010 "Th" // Convert Ireland to Billions from Millions

* Convert all countries
qui ds year, not
foreach country in `r(varlist)' {
	qui replace `country' =  `country' * 1000
}

* Reshape and save
reshape_data M1
tempfile temp_c
save `temp_c', emptyok replace


*===============================================================================
* 			Money supply: Sheet 2
*===============================================================================
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

* Keep only M2 columns
qui ds year, not
local vars_to_keep 
foreach var in `r(varlist)' {
	qui replace `var' = strlower(`var') in 3
    if `var'[3] == "m2" {
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
ren M  Germany
ren AG UnitedKingdom

* Destring
qui drop if year == ""
destring_check


* Convert units
convert_units Italy 1950 2010 "B" // Convert italy to Billions from Trillions
convert_units Ireland 1950 2010 "Th" // Convert Ireland to Billions from Millions

* Convert all countries
qui ds year, not
foreach country in `r(varlist)' {
	qui replace `country' =  `country' * 1000
}

* Reshape and save
reshape_data M2
tempfile temp_master
qui save `temp_master', replace
qui merge 1:1 year countryname using `temp_c', nogen assert(3)

* Convert units
replace M1 = M1 / 1000 if year >= 1999 & inlist(countryname, "Belgium", "France", "Greece", "Italy")
replace M2 = M2 / 1000 if year >= 1999 & inlist(countryname, "Belgium", "France", "Greece", "Italy")
replace M2 = M2 / (10^6) if countryname == "Bulgaria"


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
