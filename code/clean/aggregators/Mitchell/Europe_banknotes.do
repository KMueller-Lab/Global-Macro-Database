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
* This Stata script opens and cleans the monetary base data from Mitchell IHS
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
global input "${data_raw}/aggregators/MITCHELL/Europe_banknotes"
global output "${data_temp}/MITCHELL/Europe_banknotes"

*===============================================================================
* 			Banknotes: Sheet2
*===============================================================================
clear
import_columns_first "${input}" "2"

* Rename columns
qui ds year, not
foreach var in `r(varlist)' {
	local newname = `var'[1]
	cap ren `var' `newname'
}
ren C UnitedKingdom

* Destring
qui drop if year == ""
destring_check

* Reshape and save
reshape_data M0 
tempfile temp_c
save `temp_c', emptyok replace


*===============================================================================
* 			Banknotes: Sheet3
*===============================================================================

import_columns_first "${input}" "3"
qui ds year, not
local varlist `r(varlist)'
forvalues i = 1/1 {
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

* Rename columns
qui ds year, not
foreach var in `r(varlist)' {
	local newname = `var'[1]
	cap ren `var' `newname'
}
ren J Sweden_bis
ren K UnitedKingdom
ren L UnitedKingdom_bis

* Destring
qui drop if year == ""
destring_check

* Calculate Sweden's and UK's total 
replace Sweden = Sweden + Sweden_bis if Sweden_bis != .
replace UnitedKingdom = UnitedKingdom + UnitedKingdom_bis if UnitedKingdom_bis != .
drop *bis

* Convert units
convert_units Finland 1800 1849 "Th"

* Reshape
reshape_data M0

* Merge and save
save_merge `temp_c'

*===============================================================================
* 			Banknotes: Sheet4
*===============================================================================

import_columns "${input}" "4"

* Rename
ren UKGB UnitedKingdom

* Destring
qui drop if year == ""
destring_check

* Calculate Spain's, Sweden's, and the UK's totals 
replace Spain  = Spain + Q if Q != .
replace Sweden = Sweden + S if S != .
replace UnitedKingdom = UnitedKingdom + V if V != .
drop Q S V

* Convert units
convert_units Finland 1850 1899 "Th"
convert_units Bulgaria 1850 1899 "Th"

* Reshape
reshape_data M0

* Merge and save
save_merge `temp_c'


*===============================================================================
* 			Banknotes: Sheet5
*===============================================================================
import_columns "${input}" "5"

* Destring
qui drop if year == ""
destring_check

* Rename
ren UKGB UnitedKingdom

* Calculate Sweden's, Switzerland's, and the UK's totals
replace Sweden = Sweden + W if W != .
replace Switzerland = Switzerland + Y if Y != .
replace UnitedKingdom = UnitedKingdom + AA if AA != .
drop W Y AA

* Convert units
convert_units Finland 1900 1917 "Th"
convert_units Poland 1924 1944 "B"
convert_units France 1940 1944 "B"
convert_units Romania 1925 1944 "B"
replace Hungary = Hungary / 12500 if year <= 1924

* Reshape
reshape_data M0

* Merge and save
save_merge `temp_c'

*===============================================================================
* 			Banknotes: Sheet5
*===============================================================================
import_columns "${input}" "6"

* Rename
ren UK UnitedKingdom

* Destring
qui drop if year == ""
destring_check

* Calculate the UK's total
replace UnitedKingdom = UnitedKingdom + GB if GB != .
drop GB

* Convert units
local countries Austria  France WestGermany Greece Italy Poland Portugal Spain Yugoslavia
foreach country of local countries {
	qui convert_units `country' 1945 2010 "B"
}
ren WestGermany Germany

* Reshape
reshape_data M0

* Merge and save
save_merge `temp_c'

* Convert units
replace M0 = M0 * 1000 if countryname == "Switzerland" & year >= 1975
replace M0 = M0 * 1000 if countryname == "Belgium" & inrange(year, 1941, 1998)
replace M0 = M0 / 10000 if countryname == "Austria" & year <= 1923
replace M0 = M0 / (10^12) if countryname == "Germany" & year <= 1923
replace M0 = M0 * 1000 if countryname == "Sweden" & year >= 1974
replace M0 = M0 * 1000 if countryname == "Norway" & year >= 1975
replace M0 = M0 * 1000 if countryname == "Netherlands" & year >= 1975
replace M0 = M0 * 1000 if countryname == "Italy" & year >= 1975
replace M0 = M0 / 40000 if countryname == "Greece" & year <= 1943
replace M0 = M0 * 100 if countryname == "France" & year >= 1959
replace M0 = M0 / 100 if countryname == "Yugoslavia" & year <= 1964

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


*===============================================================================
* 			Adjust breaks and save
*===============================================================================

* Adjust the breaks
*adjust_breaks M0


* Save
save "${output}", replace

