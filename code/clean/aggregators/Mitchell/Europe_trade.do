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
* This Stata script opens and cleans data on trade from Mitchell IHS
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
global input "${data_raw}/aggregators/MITCHELL/Europe_trade"
global output "${data_temp}/MITCHELL/Europe_trade"

*===============================================================================
* 			Imports: Sheet2
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

* Keep only nominal GDP columns
qui ds year, not
local vars_to_keep 
foreach var in `r(varlist)' {
	if `var'[3] == "I" {
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
ren P UnitedKingdom
ren B AustriaHungary
 
* Destring
qui drop if year == ""
destring_check


* Reshape and save
reshape_data imports
tempfile temp_c
save `temp_c', emptyok replace


*===============================================================================
* 			Exports: Sheet3
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

* Keep only nominal GDP columns
qui ds year, not
local vars_to_keep 
foreach var in `r(varlist)' {
	if `var'[3] != "I" {
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
ren Q UnitedKingdom
ren R UnitedKingdom_R
ren C AustriaHungary

* Use overlapping data if it exists and destring
replace Russia = "93.4" if Russia == "93/4"

* Destring
qui drop if year == ""
destring_check


* Calculate the UK's exports total as the sum of domestic exports and re-exports
replace UnitedKingdom = UnitedKingdom + UnitedKingdom_R
drop UnitedKingdom_R

 
* Reshape and merge
reshape_data exports
qui merge 1:1 year countryname using `temp_c', assert(3) nogen
qui save `temp_c', replace

*===============================================================================
* 			Imports: Sheet3
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

* Keep only 
qui ds year, not
local vars_to_keep 
foreach var in `r(varlist)' {
	if `var'[3] == "I" {
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
ren AJ UnitedKingdom
ren B AustriaHungary
 
* Destring
qui drop if year == ""
destring_check


* Reshape and save
reshape_data imports
gen exports = .
save_merge `temp_c'


*===============================================================================
* 			Exports: Sheet3
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

* Keep only exports
qui ds year, not
local vars_to_keep 
foreach var in `r(varlist)' {
	if `var'[3] != "I" {
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
ren AK UnitedKingdom
ren AL UnitedKingdom_R
ren C AustriaHungary

* Destring
qui drop if year == ""
destring_check


* Calculate the UK's exports total as the sum of domestic exports and re-exports
replace UnitedKingdom = UnitedKingdom + UnitedKingdom_R
drop UnitedKingdom_R

* Reshape and merge
reshape_data exports
qui merge 1:1 year countryname using `temp_c', assert(2 3) nogen
save `temp_c', replace 

*===============================================================================
* 			Imports: Sheet4
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

* Keep only imports
gen WestGermany = S
gen EastGermany = U
qui ds year, not
local vars_to_keep 
foreach var in `r(varlist)' {
	if `var'[3] == "I" {
            local vars_to_keep `vars_to_keep' `var'
        }
}
qui keep year EastGermany `vars_to_keep'

* Rename columns
qui ds year EastGermany, not
foreach var in `r(varlist)' {
	local newname = `var'[1]
	cap ren `var' `newname'
}
ren D Austria
ren AN Russia
ren AV UnitedKingdom
ren AY Yugoslavia
 
* Destring
qui drop if year == ""
destring_check


* Austria/Hungary refers to Austria after 1920
replace Austria = . if year <= 1919

* Set to missing East Germany before 1948
replace EastGermany = . if year <= 1947

* Convert units
convert_units Greece 1946 1949 "B"
convert_units Italy 1946 1949 "B"

* Reshape and save
reshape_data imports
gen exports = .
save_merge `temp_c'


*===============================================================================
* 			Exports: Sheet4
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

* Keep only exports
gen EastGermany = T
qui ds year, not
local vars_to_keep 
foreach var in `r(varlist)' {
	if `var'[3] != "I" {
            local vars_to_keep `vars_to_keep' `var'
        }
}
qui keep year EastGermany `vars_to_keep'
qui drop S U

* Rename columns
qui ds year EastGermany, not
foreach var in `r(varlist)' {
	local newname = `var'[1]
	cap ren `var' `newname'
}
ren E Austria
ren AO Russia
ren AW UnitedKingdom
ren AX UnitedKingdom_R
ren AZ Yugoslavia

* Destring
qui drop if year == ""
destring_check


* Austria/Hungary refers to Austria after 1920
replace Austria = . if year <= 1919

* Set to missing East Germany before 1948
replace EastGermany = . if year <= 1947

* Convert units
convert_units Greece 1946 1949 "B"
convert_units Italy 1946 1949 "B"

* Calculate the UK's exports total as the sum of domestic exports and re-exports
replace UnitedKingdom = UnitedKingdom + UnitedKingdom_R
drop UnitedKingdom_R

* Reshape and merge
reshape_data exports
qui merge 1:1 year countryname using `temp_c', nogen
save `temp_c', replace 


*===============================================================================
* 			Imports: Sheet5
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

* Keep only imports
qui ds year, not
local vars_to_keep 
foreach var in `r(varlist)' {
	if `var'[3] == "I" {
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
ren R EastGermany
ren T Germany
ren AN Russia
ren AV UnitedKingdom

* Destring
replace EastGermany = "" if year == "1990"
 
* Destring
qui drop if year == ""
destring_check

 
* Generate Czech Republic 
gen Czech = Czechoslovakia if year >= 1994
replace Czechoslovakia = . if year >= 1994

* Convert units
qui ds year Italy, not
foreach country in `r(varlist)' {
	convert_units `country' 1950 1993 "B"
}
convert_units Italy 1950 1993 "Tri"


* Reshape and save
reshape_data imports
gen exports = .
save_merge `temp_c'

*===============================================================================
* 			Exports: Sheet5
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

* Keep only imports
qui ds year, not
local vars_to_keep 
foreach var in `r(varlist)' {
	if `var'[3] != "I" {
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
ren S EastGermany
ren U Germany
ren AO Russia
ren AW UnitedKingdom
ren AX UnitedKingdom_R

* Destring
qui drop if year == ""
destring_check


* Calculate the UK's exports total as the sum of domestic exports and re-exports
replace UnitedKingdom = UnitedKingdom + UnitedKingdom_R if UnitedKingdom_R != .
drop UnitedKingdom_R

* Generate Czech Republic 
gen Czech = Czechoslovakia if year >= 1994
replace Czechoslovakia = . if year >= 1994

* Convert units
qui ds year Italy, not
foreach country in `r(varlist)' {
	convert_units `country' 1950 1993 "B"
}
convert_units Italy 1950 1993 "Tri"

* Reshape and merge
reshape_data exports
qui merge 1:1 year countryname using `temp_c', nogen
save `temp_c', replace 

*===============================================================================
* 			Convert currencies and fix units
*===============================================================================
qui replace exports = exports / 100   if countryname == "France" & year <= 1958
qui replace imports = imports / 100   if countryname == "France" & year <= 1958

qui replace exports = exports / 100   if countryname == "Finland" & year <= 1945
qui replace imports = imports / 100   if countryname == "Finland" & year <= 1945

qui replace exports = exports / 1000   if countryname == "Greece" & year <= 1953
qui replace imports = imports / 1000   if countryname == "Greece" & year <= 1953

gen exports_USD = exports if year >= 1994
gen imports_USD = exports if year >= 1994

replace imports = . if year >= 1994
replace exports = . if year >= 1994

qui replace exports = exports / 1000   if countryname == "Italy" & inrange(year, 1950, 1969)
qui replace imports = imports / 1000   if countryname == "Italy" & inrange(year, 1950, 1969)

qui replace exports = exports / 1000   if countryname == "Ireland" & year >= 1950
qui replace imports = imports / 1000   if countryname == "Ireland" & year >= 1950

qui replace exports = exports / 1000   if countryname == "Poland" 
qui replace imports = imports / 1000   if countryname == "Poland"

qui replace exports = exports / 1000000   if countryname == "Bulgaria"  & year <= 1948
qui replace imports = imports / 1000000   if countryname == "Bulgaria"  & year <= 1948

qui replace exports = exports / 1000   if countryname == "Bulgaria"  & year >= 1952
qui replace imports = imports / 1000   if countryname == "Bulgaria"  & year >= 1952

qui replace exports = exports / 10000   if countryname == "Romania"
qui replace imports = imports / 10000   if countryname == "Romania"

qui replace exports = exports / 20000   if countryname == "Romania" & year <= 1946
qui replace imports = imports / 20000   if countryname == "Romania" & year <= 1946

qui replace exports = exports / (10^12)   if countryname == "Germany" & year <= 1913
qui replace imports = imports / (10^12)   if countryname == "Germany" & year <= 1913

* Drop real values for Germany between 1920 and 1923
qui replace exports = .   if countryname == "Germany" & inrange(year, 1920, 1923)
qui replace imports = .   if countryname == "Germany" & inrange(year, 1920, 1923)

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

