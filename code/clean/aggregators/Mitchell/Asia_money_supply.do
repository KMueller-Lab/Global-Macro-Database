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
* This Stata script opens and cleans the money supply data from Mitchell IHS
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
global input "${data_raw}/aggregators/MITCHELL/Asia_money_supply"
global output "${data_temp}/MITCHELL/Asia_money_supply"

*===============================================================================
* 			Money supply: Sheet 2
*===============================================================================
clear
import_columns "${input}" "2"

* Keep only M1 columns
qui ds year, not
local vars_to_keep 
foreach var in `r(varlist)' {
	qui replace `var' = strtrim(strlower(`var')) in 2
    if `var'[2] == "m1" {
            local vars_to_keep `vars_to_keep' `var'
        }
}
qui keep year `vars_to_keep'

* Destring
qui drop if year == ""
destring_check

* Convert units
local countries Afghanistan Bangladesh China India Japan Iran Pakistan Philippines SaudiArabia SouthKorea Taiwan UnitedArabEmirates SouthVietnam Thailand Turkey
foreach country of local countries {
	convert_units `country' 1948 2010 "B"
}

* Convert units
local countries Israel Lebanon Malaysia Singapore SriLanka Syria
foreach country of local countries {
	convert_units `country' 1965 2010 "B"
}

* Convert units
local countries Myanmar Nepal Qatar 
foreach country of local countries {
	convert_units `country' 1980 2010 "B"
}
convert_units Japan 1960 2010 "B"
convert_units Pakistan 1965 2010 "B"
convert_units Indonesia 1950 2010 "B"
convert_currency Indonesia 1962 1/1000
convert_currency Turkey 1985 2010 "Tri"

* Reshape
reshape_data M1

* Save
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
	qui replace `var' = subinstr(`var', " ", "", .) in 1
	qui replace `var' = strtrim(strlower(`var')) in 3
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

* Destring
qui drop if year == ""
destring_check

* Convert units
local countries Afghanistan Bangladesh China India Japan Iran Pakistan Philippines SaudiArabia SouthKorea Taiwan UnitedArabEmirates SouthVietnam Thailand Turkey
foreach country of local countries {
	convert_units `country' 1948 2010 "B"
}

* Convert units
local countries Israel Lebanon Malaysia Singapore SriLanka Syria
foreach country of local countries {
	convert_units `country' 1965 2010 "B"
}

* Convert units
local countries Myanmar Nepal Qatar 
foreach country of local countries {
	convert_units `country' 1980 2010 "B"
}
convert_units Japan 1960 2010 "B"
convert_units Pakistan 1965 2010 "B"
convert_units Indonesia 1950 2010 "B"
convert_currency Indonesia 1962 1/1000
convert_currency Turkey 1985 2010 "Tri"

* Reshape 
reshape_data M2

* Save
tempfile temp_master
qui save `temp_master', replace
qui merge 1:1 year countryname using `temp_c', nogen assert(3)

* Convert units
replace M1 = M1 / 1000 if countryname == "Lebanon" & inrange(year, 1965, 1974)
replace M2 = M2 / 1000 if countryname == "Lebanon" & inrange(year, 1965, 1974)

replace M1 = M1 / 1000 if countryname == "Malaysia" & inrange(year, 1965, 1974)
replace M2 = M2 / 1000 if countryname == "Malaysia" & inrange(year, 1965, 1974)

replace M1 = M1 / 1000 if countryname == "Singapore" & inrange(year, 1965, 1974)
replace M2 = M2 / 1000 if countryname == "Singapore" & inrange(year, 1965, 1974)

replace M1 = M1 / 1000 if countryname == "SriLanka" & inrange(year, 1965, 1974)
replace M2 = M2 / 1000 if countryname == "SriLanka" & inrange(year, 1965, 1974)

replace M1 = M1 / 1000 if countryname == "Syria" & inrange(year, 1965, 1974)
replace M2 = M2 / 1000 if countryname == "Syria" & inrange(year, 1965, 1974)

replace M1 = M1 / 1000000 if countryname == "Turkey" & year <= 1985
replace M1 = M1 / 1000 	  if countryname == "Turkey"

replace M2 = M2 / 1000000 if countryname == "Turkey" & year <= 1985
replace M2 = M2 / 1000    if countryname == "Turkey"

replace M1  = M1 / 1000 if countryname == "Israel" 
replace M1  = M1 / 10   if countryname == "Israel" & year <= 1979
replace M1  = M1 / 1000 if countryname == "Israel" & year <= 1974 & year >= 1965

replace M2  = M2 / 1000 if countryname == "Israel" 
replace M2  = M2 / 10   if countryname == "Israel" & year <= 1979
replace M2  = M2 / 1000 if countryname == "Israel" & year <= 1974 & year >= 1965

replace M1 = M1 / 1000 if countryname == "Pakistan"
replace M2 = M2 / 1000 if countryname == "Pakistan"

replace M1 = M1 * 1000 if countryname == "SouthKorea" & year >= 1980
replace M2 = M2 * 1000 if countryname == "SouthKorea" & year >= 1980

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

