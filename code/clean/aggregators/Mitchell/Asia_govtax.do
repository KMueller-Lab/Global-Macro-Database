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
global input "${data_raw}/aggregators/MITCHELL/Asia_govrev"
global output "${data_temp}/MITCHELL/Asia_govtax"

*===============================================================================
* 			govtax: Sheet 2
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

* Sum the columns
replace Indonesia = Indonesia + E
drop E

* Reshape
reshape_data govtax

* Save
tempfile temp_c
save `temp_c', emptyok replace

*===============================================================================
* 			govtax: Sheet 3
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

* Keep only nominal GDP columns
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

* Generate sum columns
replace India = India + !missing(E)
replace India = India + F + G + H
keep India year

* Reshape
reshape_data govtax

* Save
save_merge `temp_c'

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

* Keep only total columns
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

* Calculate total tax revenue
egen Indonesiatax = rowtotal(Indonesia E)
egen Japantax     = rowtotal(Japan H I J K)
egen Thailandtax  = rowtotal(Thailand S)
keep year *tax
ren *tax *

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

* Keep only nominal GDP columns
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

* Sum column taxes
egen Indiatax = rowtotal(India E F G H)
egen Indonesiatax = rowtotal(Indonesia L)
egen Japantax  = rowtotal(Japan Q R S T)
egen Koreatax  = rowtotal(Korea W X Y)
egen Thailandtax = rowtotal(Thailand AJ)
keep year *tax
ren *tax *

* Reshape
reshape_data govtax
replace govtax = . if govtax == 0

* Save
save_merge `temp_c'

*===============================================================================
* 			govtax: Sheet 6
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

* Keep only total columns
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
egen Indiatax = rowtotal(India H I)
egen Indonesiatax = rowtotal(Indonesia L M)
egen Irantax = rowtotal(Iran P Q)
egen Japantax  = rowtotal(Japan V W X)
egen SouthKoreatax  = rowtotal(SouthKorea AC AD)
keep year *tax
ren *tax *

* Convert units
convert_units India 1960 2010 "B"
 
* Reshape
reshape_data govtax
replace govtax = . if govtax == 0

* Save
save_merge `temp_c'
*===============================================================================
* 			govtax: Sheet 7
*===============================================================================

import_columns_first "${input}" "7"

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
cap destring_check
destring Thailand Turkey, force replace


* Sum taxes columns 
egen Pakistantax = rowtotal(Pakistan D E)
egen Phillippinestax = rowtotal(Phillippines H I)
egen Thailandtax = rowtotal(Thailand P Q)
egen Turkeytax = rowtotal(Turkey T U)
keep year *tax
ren *tax *


* Convert units
local countries Pakistan Phillippines
foreach country of local countries {
	convert_units `country' 1970 2010 "B"
}
convert_units Thailand  1962 2010 "B"
convert_units Turkey    1959 1988 "B"
convert_units Turkey    1989 2010 "Tri"

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
convert_currency Indonesia 1964 1/1000
convert_units Iran 1945 2010 "B"

* Reshape
reshape_data govtax

* Convert units
replace govtax = govtax * 1000 if year >= 1965 & countryname == "Japan"
replace govtax = govtax * 1000 if year >= 1945 & countryname == "Japan"
replace govtax = govtax * (10^3) if countryname == "SouthKorea"

* Convert units for Taiwan
replace govtax = govtax * (10^-4) if year <= 1939 & countryname == "Taiwan"
replace govtax = govtax / 4 if year <= 1939 & countryname == "Taiwan"

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
