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
* This Stata script opens and cleans the trade data from Mitchell IHS
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
global input "${data_raw}/aggregators/MITCHELL/Africa_trade"
global output "${data_temp}/MITCHELL/Africa_trade"

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

* Keep only imports
qui ds year, not
local vars_to_keep 
foreach var in `r(varlist)' {
	qui replace `var' = subinstr(`var', " ", "", .) in 1
	qui replace `var' = strlower(`var') in 2
	if `var'[2] == "imports" {
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
drop F 

* Destring
qui drop if year == ""
destring_check

* Convert units
local countries Gambia Ghana
foreach country of local countries{
	convert_units `country' 1831 1869 "Th"
}

* Reshape and save
reshape_data imports
tempfile temp_c
save `temp_c', emptyok replace


*===============================================================================
* 			Exports: Sheet2
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

* Keep only exports
qui ds year, not
local vars_to_keep 
foreach var in `r(varlist)' {
	qui replace `var' = subinstr(`var', " ", "", .) in 1
	qui replace `var' = strlower(`var') in 2
	if `var'[2] == "exports" {
            local vars_to_keep `vars_to_keep' `var'
        }
}
qui keep year `vars_to_keep'
drop G 

* Rename columns
qui ds year, not
foreach var in `r(varlist)' {
	local newname = `var'[1]
	cap ren `var' `newname'
}

* Destring
qui drop if year == ""
destring_check

* Convert units
local countries Gambia Ghana
foreach country of local countries{
	convert_units `country' 1831 1869 "Th"
}

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

* Keep only imports
qui ds year, not
local vars_to_keep 
foreach var in `r(varlist)' {
	qui replace `var' = subinstr(`var', " ", "", .) in 1
	qui replace `var' = strlower(`var') in 2
	if `var'[2] == "imports" {
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

* Destring
qui drop if year == ""
destring_check

* Add South Africa as the sum of Cape of Good Hope and Natal 
gen SouthAfrica = CapeofGoodHope + Natal
replace SouthAfrica = CapeofGoodHope if SouthAfrica == .
drop CapeofGoodHope Natal

* Convert units
local countries Nigeria SierraLeone SouthAfrica
foreach country of local countries{
	convert_units `country' 1826 1869 "Th"
}

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
	qui replace `var' = subinstr(`var', " ", "", .) in 1
	qui replace `var' = strlower(`var') in 2
	if `var'[2] == "exports" {
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

* Destring
qui drop if year == ""
destring_check
qui missings dropvars, force

* Add South Africa as the sum of Cape of Good Hope and Natal 
gen SouthAfrica = CapeofGoodHope + Natal
replace SouthAfrica = CapeofGoodHope if SouthAfrica == .
drop CapeofGoodHope Natal

* Convert units
local countries Nigeria SierraLeone SouthAfrica
foreach country of local countries{
	convert_units `country' 1826 1869 "Th"
}

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
qui ds year, not
local vars_to_keep 
foreach var in `r(varlist)' {
	qui replace `var' = subinstr(`var', " ", "", .) in 1
	qui replace `var' = strlower(`var') in 2
	if strpos(`var'[2], "imports") > 0 {
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


* Destring
qui drop if year == ""
destring_check

* Add South Africa as the sum of Cape of Good Hope and Natal 
local countries CapeofGoodHope Natal OrangeFreeState Transvaal
foreach country of local countries {
	qui replace `country' = 0 if `country' == .
}
gen SouthAfrica = CapeofGoodHope + Natal + OrangeFreeState + Transvaal
drop CapeofGoodHope Natal OrangeFreeState Transvaal

* Convert units
local countries Gambia Ghana Kenya Nigeria SierraLeone SouthAfrica Uganda Zambia Zanzibar Zimbabwe
foreach country of local countries{
	convert_units `country' 1870 1909 "Th"
}

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

* Keep only imports
qui ds year, not
local vars_to_keep 
foreach var in `r(varlist)' {
	qui replace `var' = subinstr(`var', " ", "", .) in 1
	qui replace `var' = strlower(`var') in 2
	if strpos(`var'[2], "exports") > 0 {
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

* Destring
qui drop if year == ""
destring_check

* Add South Africa as the sum of Cape of Good Hope and Natal 
local countries CapeofGoodHope Natal OrangeFreeState Transvaal
foreach country of local countries {
	qui replace `country' = 0 if `country' == .
}
gen SouthAfrica = CapeofGoodHope + Natal + OrangeFreeState + Transvaal
drop CapeofGoodHope Natal OrangeFreeState Transvaal

* Convert units
local countries Gambia Ghana Kenya Nigeria SierraLeone SouthAfrica Uganda Zambia Zanzibar Zimbabwe
foreach country of local countries{
	convert_units `country' 1870 1909 "Th"
}

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
	qui replace `var' = subinstr(`var', " ", "", .) in 1
	qui replace `var' = strlower(`var') in 2
	if strpos(`var'[2], "imports") > 0 {
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

* Destring
qui drop if year == ""
destring_check

* Convert units
local countries BritishSomaliland Kenya SierraLeone Uganda Zambia Zanzibar
foreach country of local countries{
	convert_units `country' 1910 1949 "Th"
}

* Convert units
local countries Ghana Nigeria
foreach country of local countries{
	convert_units `country' 1910 1919 "Th"
}

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
	qui replace `var' = subinstr(`var', " ", "", .) in 1
	qui replace `var' = strlower(`var') in 2
	if strpos(`var'[2], "exports") > 0 {
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

* Destring
qui drop if year == ""
destring_check

* Convert units
local countries BritishSomaliland Kenya SierraLeone Uganda Zambia Zanzibar
foreach country of local countries{
	convert_units `country' 1910 1949 "Th"
}

* Convert units
local countries Ghana Nigeria
foreach country of local countries{
	convert_units `country' 1910 1919 "Th"
}


* Reshape and merge
reshape_data exports
qui merge 1:1 year countryname using `temp_c', nogen
save `temp_c', replace 

*===============================================================================
* 			Imports: Sheet6
*===============================================================================

import_columns_first "${input}" "6"
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
	qui replace `var' = subinstr(`var', " ", "", .) in 1
	qui replace `var' = strlower(`var') in 2
	if strpos(`var'[2], "imports") > 0 {
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

* Destring
qui drop if year == ""
destring_check

* Reshape and save
reshape_data imports
gen exports = .
save_merge `temp_c'


*===============================================================================
* 			Exports: Sheet6
*===============================================================================

import_columns_first "${input}" "6"
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
	qui replace `var' = subinstr(`var', " ", "", .) in 1
	qui replace `var' = strlower(`var') in 2
	if strpos(`var'[2], "exports") > 0 {
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

* Destring
qui drop if year == ""
destring_check

* Reshape and merge
reshape_data exports
qui merge 1:1 year countryname using `temp_c', nogen
save `temp_c', replace 

*===============================================================================
* 			Convert currencies
*===============================================================================

* Generate new variables for USD values
gen exports_USD = .
gen imports_USD = .

* Algeria
replace exports_USD = exports if countryname == "Algeria" & year >= 1997
replace imports_USD = imports if countryname == "Algeria" & year >= 1997

* Benin
replace exports_USD = exports if countryname == "Benin" & year >= 1997
replace imports_USD = imports if countryname == "Benin" & year >= 1997

* Burkina Faso
replace exports_USD = exports if countryname == "BurkinaFaso" & year >= 1995
replace imports_USD = imports if countryname == "BurkinaFaso" & year >= 1995

* Burundi
replace exports_USD = exports if countryname == "Burundi" & year >= 1997
replace imports_USD = imports if countryname == "Burundi" & year >= 1997

* Cameroon
replace exports_USD = exports if countryname == "Cameroon" & year >= 1995
replace imports_USD = imports if countryname == "Cameroon" & year >= 1995

* Central African Republic
replace exports_USD = exports if countryname == "CentralAfricanRepublic" & year >= 1997
replace imports_USD = imports if countryname == "CentralAfricanRepublic" & year >= 1997

* Egypt
replace exports_USD = exports if countryname == "Egypt" & year >= 1997
replace imports_USD = imports if countryname == "Egypt" & year >= 1997

* Ethiopia
replace exports_USD = exports if countryname == "Ethiopia" & year >= 1997
replace imports_USD = imports if countryname == "Ethiopia" & year >= 1997

* Gabon
replace exports_USD = exports if countryname == "Gabon" & year >= 1997
replace imports_USD = imports if countryname == "Gabon" & year >= 1997

* Gambia
replace exports_USD = exports if countryname == "Gambia" & year >= 1997
replace imports_USD = imports if countryname == "Gambia" & year >= 1997

* Ghana
replace exports_USD = exports if countryname == "Ghana" & year >= 1997
replace imports_USD = imports if countryname == "Ghana" & year >= 1997

* Guinea
replace exports_USD = exports if countryname == "Guinea" & year >= 1988
replace imports_USD = imports if countryname == "Guinea" & year >= 1988

* Ivory Coast
replace exports_USD = exports if countryname == "IvoryCoast" & year >= 1997
replace imports_USD = imports if countryname == "IvoryCoast" & year >= 1997

* Kenya
replace exports_USD = exports if countryname == "Kenya" & year >= 1997
replace imports_USD = imports if countryname == "Kenya" & year >= 1997

* Liberia
replace exports_USD = exports if countryname == "Liberia" 
replace imports_USD = imports if countryname == "Liberia"

* Libya
replace exports_USD = exports if countryname == "Libya" & year >= 1997
replace imports_USD = imports if countryname == "Libya" & year >= 1997

* Madagascar
replace exports_USD = exports if countryname == "Madagascar" & year >= 1997
replace imports_USD = imports if countryname == "Madagascar" & year >= 1997

* Malawi
replace exports_USD = exports if countryname == "Malawi" & year >= 1994
replace imports_USD = imports if countryname == "Malawi" & year >= 1994

* Mali
replace exports_USD = exports if countryname == "Mali" & year >= 1996
replace imports_USD = imports if countryname == "Mali" & year >= 1996

* Mauritania
replace exports_USD = exports if countryname == "Mauritania" & year >= 1997
replace imports_USD = imports if countryname == "Mauritania" & year >= 1997

* Mauritius
replace exports_USD = exports if countryname == "Mauritius" & year >= 1997
replace imports_USD = imports if countryname == "Mauritius" & year >= 1997

* Morocco
replace exports_USD = exports if countryname == "Morocco" & year >= 1997
replace imports_USD = imports if countryname == "Morocco" & year >= 1997

* Mozambique
replace exports_USD = exports if countryname == "Mozambique" & year >= 1994
replace imports_USD = imports if countryname == "Mozambique" & year >= 1994

* Nigeria
replace exports_USD = exports if countryname == "Nigeria" & year >= 1995
replace imports_USD = imports if countryname == "Nigeria" & year >= 1995

* Rwanda
replace exports_USD = exports if countryname == "Rwanda" & year >= 1995
replace imports_USD = imports if countryname == "Rwanda" & year >= 1995

* Senegal
replace exports_USD = exports if countryname == "Senegal" & year >= 1997
replace imports_USD = imports if countryname == "Senegal" & year >= 1997

* Sierra Leone
replace exports_USD = exports if countryname == "Sierra Leone" & year >= 1997
replace imports_USD = imports if countryname == "Sierra Leone" & year >= 1997

* South Africa
replace exports_USD = exports if countryname == "SouthAfrica" & year >= 1997
replace imports_USD = imports if countryname == "SouthAfrica" & year >= 1997

* Sudan
replace exports_USD = exports if countryname == "Sudan" & year >= 1995
replace imports_USD = imports if countryname == "Sudan" & year >= 1995

* Tanzania
replace exports_USD = exports if countryname == "Tanzania" & year >= 2004
replace imports_USD = imports if countryname == "Tanzania" & year >= 2004

* Togo
replace exports_USD = exports if countryname == "Togo" & year >= 1997
replace imports_USD = imports if countryname == "Togo" & year >= 1997

* Tunisia
replace exports_USD = exports if countryname == "Tunisia" & year >= 1997
replace imports_USD = imports if countryname == "Tunisia" & year >= 1997

* Uganda
replace exports_USD = exports if countryname == "Uganda" & year >= 1997
replace imports_USD = imports if countryname == "Uganda" & year >= 1997

* Zaire
replace exports_USD = exports if countryname == "Zaire" & year >= 1994
replace imports_USD = imports if countryname == "Zaire" & year >= 1994

* Zambia
replace exports_USD = exports if countryname == "Zambia" & year >= 1993
replace imports_USD = imports if countryname == "Zambia" & year >= 1993

* Drop LCU imports and exports
replace imports = . if imports_USD != .
replace exports = . if exports_USD != .

* Convert currencies 
replace exports = exports / 1000 if countryname == "Tunisia" & year <= 1949
replace imports = imports / 1000 if countryname == "Tunisia" & year <= 1949

replace exports = exports / 1000 if countryname == "Sudan" & year <= 1998
replace imports = imports / 1000 if countryname == "Sudan" & year <= 1998

replace exports = exports / 0.5 if countryname == "Nigeria" & year <= 1972
replace imports = imports / 0.5 if countryname == "Nigeria" & year <= 1972

replace exports = exports / 0.5 if countryname == "SierraLeone" & year <= 1964
replace imports = imports / 0.5 if countryname == "SierraLeone" & year <= 1964

replace exports = exports / 0.417 if countryname == "Ghana" & year <= 1964
replace imports = imports / 0.417 if countryname == "Ghana" & year <= 1964

replace exports = exports / 5 if countryname == "Madagascar" & year <= 2000
replace imports = imports / 5 if countryname == "Madagascar" & year <= 2000

replace exports = exports / 0.5 if countryname == "SouthAfrica" & year <= 1959
replace imports = imports / 0.5 if countryname == "SouthAfrica" & year <= 1959

replace exports = exports / 1000000000 if countryname == "Angola"
replace imports = imports / 1000000000 if countryname == "Angola" 

replace exports = exports / 100 if countryname == "Algeria" & year <= 1957
replace imports = imports / 100 if countryname == "Algeria" & year <= 1957

replace exports = exports * 3.3538549 if countryname == "Cameroon" & year <= 1919
replace imports = imports * 3.3538549 if countryname == "Cameroon" & year <= 1919

replace exports = exports / 200 if countryname == "Gambia" & year <= 1969
replace imports = imports / 200 if countryname == "Gambia" & year <= 1969

replace exports = exports / 100 if countryname == "Morocco" & year <= 1945
replace imports = imports / 100 if countryname == "Morocco" & year <= 1945

* Convert units
local countries Cameroon Congo Gabon Madagascar Niger Senegal 
foreach country of local countries{
	replace exports = exports * 1000 if countryname == "`country'" & year >= 1980
	replace imports = imports * 1000 if countryname == "`country'" & year >= 1980
}

replace exports = exports * 1000 if countryname == "IvoryCoast" & year >= 1971
replace imports = imports * 1000 if countryname == "IvoryCoast" & year >= 1971

replace exports = exports / 1000 if countryname == "SierraLeone" & inrange(year, 1950, 1952)
replace imports = imports / 1000 if countryname == "SierraLeone" & inrange(year, 1950, 1952)

replace exports = exports / 1000 if countryname == "Mozambique"  
replace imports = imports / 1000 if countryname == "Mozambique"  

replace exports = exports / 10000 if countryname == "Ghana"  
replace imports = imports / 10000 if countryname == "Ghana"  

replace exports = exports / 10 if countryname == "Guinea" & year <= 1963 
replace imports = imports / 10 if countryname == "Guinea" & year <= 1963

replace exports = exports / 10 if countryname == "Mauritania" 
replace imports = imports / 10 if countryname == "Mauritania"

replace exports = exports / 1000 if countryname == "Zimbabwe" & year <= 1944
replace imports = imports / 1000 if countryname == "Zimbabwe" & year <= 1944

replace exports = exports * 1000 if countryname == "Gambia" & year <= 1909
replace imports = imports * 1000 if countryname == "Gambia" & year <= 1909


replace exports = exports / 1000 if countryname == "Zambia"
replace imports = imports / 1000 if countryname == "Zambia" 

replace imports = imports / 500 if countryname == "Malawi" & year <= 1970
replace exports = exports / 500 if countryname == "Malawi" & year <= 1970

replace imports = imports / 1000 if countryname == "Zaire" & year <= 1959
replace exports = exports / 1000 if countryname == "Zaire" & year <= 1959

replace imports = imports / 30000 if countryname == "Zaire" & year <= 1993
replace exports = exports / 30000 if countryname == "Zaire" & year <= 1993

replace imports = imports / 1000000 if countryname == "Zaire" & year <= 1990
replace exports = exports / 1000000 if countryname == "Zaire" & year <= 1990

replace imports = imports / 10 if countryname == "Zaire" & year <= 1989
replace exports = exports / 10 if countryname == "Zaire" & year <= 1989

replace imports = imports / 100 if countryname == "Uganda" & year <= 1986
replace exports = exports / 100 if countryname == "Uganda" & year <= 1986

* Liberia trade values in USD do not reflect the devaluation in its own exchange rate in 1974 which changed from 1-1 to 1-23.
replace imports_USD = . if countryname == "Liberia" & year >= 1974
replace exports_USD = . if countryname == "Liberia" & year >= 1974



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
