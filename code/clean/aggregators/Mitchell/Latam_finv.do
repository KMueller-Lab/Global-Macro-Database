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
* This Stata script opens and cleans the investment data from Mitchell IHS
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
global input "${data_raw}/aggregators/MITCHELL/Latam_NA"
global output "${data_temp}/MITCHELL/Latam_finv"

*===============================================================================
* 			finv: Sheet4
*===============================================================================
import_columns_first "${input}" "4"

qui ds year, not
local varlist `r(varlist)'
forvalues i = 1/3 {
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
	qui replace `var' = strtrim(strlower(`var')) in 4
	qui replace `var' = strtrim(strlower(`var')) in 3
	if `var'[3] == "current prices" &  inlist(`var'[4], "gfcf") {
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


* Convert units
local countries Argentina Chile Paraguay Venezuela
foreach country of local countries {
	convert_units `country' 1935 1969 "B"
}

* Reshape
reshape_data finv

* Save
tempfile temp_c
save `temp_c', emptyok replace


*===============================================================================
* 			finv: Sheet5
*===============================================================================
import_columns_first "${input}" "5"

qui ds year, not
local varlist `r(varlist)'
forvalues i = 1/3 {
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
	qui replace `var' = strtrim(strlower(`var')) in 4
	qui replace `var' = strtrim(strlower(`var')) in 3
	if `var'[3] == "current prices" &  inlist(`var'[4], "gfcf") {
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

* Convert units
local countries Bolivia Brazil Colombia Paraguay Uruguay Venezuela
foreach country of local countries {
	convert_units `country' 1970 1993 "B"
}

convert_units Argentina 1970 1986 "B"

* Reshape
reshape_data finv

* Drop USD values
replace finv = . if year >= 1994

* Save
save_merge `temp_c'

* Convert units
replace finv = finv / 2750 if countryname == "Brazil"
replace finv = finv / 1000 if countryname == "Brazil"
replace finv = finv / 1000 if year <= 1989 & countryname == "Brazil"
replace finv = finv / 1000 if year <= 1979 & countryname == "Brazil"
replace finv = finv * 1000 if inrange(year, 1960, 1969) & countryname == "Brazil"
replace finv = . if year >= 1986 & countryname == "Argentina"
replace finv = finv * (10^-14) if countryname == "Venezuela"
replace finv = finv * (10^-6) if countryname == "Mexico" & year <= 1984
replace finv = finv * (10^3) if  countryname == "Ecuador"
replace finv = finv / 25000 if  countryname == "Ecuador"
replace finv = finv * (10^3) if  countryname == "Colombia" & year <= 1969
replace finv = finv * (10^-3) if countryname == "Uruguay" 
replace finv = finv / 1000 if year <= 1979 & countryname == "Uruguay" 
replace finv = finv * 1000 if year <= 1969 & countryname == "Uruguay" 
replace finv = finv / 1000 if year <= 1959 & countryname == "Uruguay" 
replace finv = finv * (10^-3) if year <= 1988 & countryname == "Peru" 
replace finv = finv * (10^-3) if year <= 1979 & countryname == "Peru" 
replace finv = finv * (10^-3) if year <= 1949 & countryname == "Peru" 
replace finv = finv / 1000 if countryname == "Bolivia" & year <= 1993
replace finv = finv / 1000 if countryname == "Bolivia" & year == 1984
replace finv = finv / 100 if countryname == "Bolivia" & year <= 1983
replace finv = finv / 10 if countryname == "Bolivia" & year <= 1979
replace finv = finv / 1000 if countryname == "Chile" & year <= 1969
replace finv = finv / 1000 if countryname == "Chile" & year <= 1964
replace finv = finv * 1000 if countryname == "Chile" & year >= 1975
replace finv = finv / 10000 if countryname == "Argentina" & year <= 1985
replace finv = finv / 1000 if countryname == "Argentina" & year <= 1984
replace finv = finv / 10000 if countryname == "Argentina" & year <= 1974
replace finv = finv / 100 if countryname == "Argentina" & year <= 1964


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
