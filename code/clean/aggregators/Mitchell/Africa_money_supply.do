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
* This Stata script opens and cleans the monetary aggregates data from Mitchell IHS
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
global input "${data_raw}/aggregators/MITCHELL/Africa_money_supply"
global output "${data_temp}/MITCHELL/Africa_money_supply"

*===============================================================================
* 			M1: Sheet 2
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
qui ds Algeria Benin BurkinaFaso Burundi Cameroon CentralAfricanRepublic Chad Congo Gabon IvoryCoast Madagascar Mali Morocco Niger Senegal Tanzania Togo
foreach country in `r(varlist)'{
	convert_units `country' 1948 2010 "B"
}

* Convert units
qui ds Egypt Ghana Kenya Mauritania Nigeria Rwanda Somalia SouthAfrica Zaire
foreach country in `r(varlist)'{
	convert_units `country' 1980 2010 "B"
}

* Reshape
reshape_data M1

* Save
tempfile temp_c
save `temp_c', emptyok replace

*===============================================================================
* 			M2: Sheet 2
*===============================================================================
import_columns_first "${input}" "2"

* Fill empty columns that were merged cells in excel
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
qui ds Algeria Benin BurkinaFaso Burundi Cameroon CentralAfricanRepublic Chad Congo Gabon IvoryCoast Madagascar Mali Morocco Niger Senegal Tanzania Togo
foreach country in `r(varlist)'{
	convert_units `country' 1948 2010 "B"
}

* Convert units
qui ds Egypt Ghana Kenya Mauritania Nigeria Rwanda Somalia SouthAfrica Zaire
foreach country in `r(varlist)'{
	convert_units `country' 1980 2010 "B"
}

* Reshape
reshape_data M2

* Save
tempfile temp_master
qui save `temp_master', replace
qui merge 1:1 year countryname using `temp_c', nogen assert(3)

* Fix units
replace M1 = M1 / 10000 if countryname == "Ghana"
replace M2 = M2 / 10000 if countryname == "Ghana"

replace M1 = M1 / 5 if year <= 2000 & countryname == "Madagascar"
replace M2 = M2 / 5 if year <= 2000 & countryname == "Madagascar"

replace M1 = M1 / 10 if countryname == "Mauritania"
replace M2 = M2 / 10 if countryname == "Mauritania"

replace M1 = M1 / 1000 if countryname == "Sudan" & year <= 1991
replace M2 = M2 / 1000 if countryname == "Sudan" & year <= 1991

replace M1 = M1 * 1000 if year >= 2000 & countryname == "Uganda"
replace M2 = M2 * 1000 if year >= 2000 & countryname == "Uganda"

replace M2 = M2 / 1000 if year <= 1995 & countryname == "Zaire"
replace M2 = M2 / 1000 if countryname == "Zaire"
replace M2 = M2 / 100 if year <= 1993 & countryname == "Zaire"
replace M2 = M2 / 1000 if year <= 1991 & countryname == "Zaire"
replace M2 = M2 / 3 if year <= 1987 & countryname == "Zaire"

replace M1 = M1 / 1000 if year <= 1995 & countryname == "Zaire"
replace M1 = M1 / 1000 if countryname == "Zaire"
replace M1 = M1 / 100 if year <= 1993 & countryname == "Zaire"
replace M1 = M1 / 1000 if year <= 1991 & countryname == "Zaire"
replace M1 = M1 / 3 if year <= 1987 & countryname == "Zaire"

replace M1 = M1 * 1000 if year > 2000 & countryname == "Zambia"
replace M2 = M2 * 1000 if year > 2000 & countryname == "Zambia"

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

