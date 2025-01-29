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
global input "${data_raw}/aggregators/MITCHELL/Latam_money_supply"
global output "${data_temp}/MITCHELL/Latam_money_supply"

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

* Use overlapping data if it exists and destring
use_overlapping_data
drop if year == .

* Convert units
replace Argentina = Argentina / 100 if year <= 1969
replace Argentina = Argentina / 10000 if year <= 1982
replace Argentina = Argentina / 1000 if year <= 1984
replace Argentina = Argentina / 10000 if year <= 1988

convert_units Argentina 1948 1975 "B"
convert_units Argentina 1976 1982 "Tri"
convert_units Argentina 1983 1988 "B"

convert_units Bolivia 1948 1962 "B"
replace Bolivia = Bolivia / 1000 if year <= 1962
convert_units Bolivia 1975 1984 "B"
convert_units Bolivia 1985 1986 "Tri"
replace Bolivia = Bolivia / 1000000 if year <= 1986


replace Brazil = Brazil / 1000 if year <= 1965
convert_units Brazil 1984 1985 "B"
replace Brazil = Brazil / 2750 if year <= 1985

convert_units Bolivia 1955 1982 "B"
convert_units Bolivia 1983 2010 "Tri"

replace Brazil = Brazil / 1000 if year <= 1939
replace Brazil = Brazil / 1000 if year <= 1966
replace Brazil = Brazil / 2750 if year <= 1993
convert_units Brazil 1940 1974 "B"
convert_units Brazil 1940 1974 "B"

replace Venezuela = Venezuela * 1000 if year >= 1965

replace Chile = Chile / 1000 if year <= 1954
convert_units Chile 1970 1975 "B"
replace Chile = Chile / 1000 if year <= 1975
convert_units Chile 1983 2010 "B"

convert_units Colombia 1975 2010 "B"
convert_units Ecuador 1983 2000 "B"
replace Ecuador = Ecuador * 25000 if year >= 2001

replace Paraguay = Paraguay / 100 if year <= 1942

convert_units Paraguay 1975 2000 "B" 

replace Peru = Peru / 1000 if year <= 1929

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

* Use overlapping data if it exists and destring
use_overlapping_data
drop if year == .

* Convert units
replace Argentina = Argentina / 100 if year <= 1969
replace Argentina = Argentina / 10000 if year <= 1982
replace Argentina = Argentina / 1000 if year <= 1984
replace Argentina = Argentina / 10000 if year <= 1988

convert_units Argentina 1948 1975 "B"
convert_units Argentina 1976 1982 "Tri"
convert_units Argentina 1983 1988 "B"

convert_units Bolivia 1948 1962 "B"
replace Bolivia = Bolivia / 1000 if year <= 1962
convert_units Bolivia 1975 1984 "B"
convert_units Bolivia 1985 1986 "Tri"
replace Bolivia = Bolivia / 1000000 if year <= 1986


replace Brazil = Brazil / 1000 if year <= 1965
convert_units Brazil 1984 1985 "B"
replace Brazil = Brazil / 2750 if year <= 1985


convert_units Bolivia 1955 1982 "B"
convert_units Bolivia 1983 2010 "Tri"
*
replace Brazil = Brazil / 1000 if year <= 1939
replace Brazil = Brazil / 1000 if year <= 1966
replace Brazil = Brazil / 2750 if year <= 1993
convert_units Brazil 1940 1974 "B"
convert_units Brazil 1940 1974 "B"


replace Chile = Chile / 1000 if year <= 1954
convert_units Chile 1970 1975 "B"
replace Chile = Chile / 1000 if year <= 1975
convert_units Chile 1983 2010 "B"

convert_units Colombia 1975 2010 "B"
convert_units Ecuador 1983 2000 "B"
replace Ecuador = Ecuador * 25000 if year >= 2001

replace Paraguay = Paraguay / 100 if year <= 1942

convert_units Paraguay 1975 2000 "B" 

replace Peru = Peru / 1000 if year <= 1929

replace Venezuela = Venezuela * 1000 if year >= 1965

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
replace M2 = M2 / 1000 if countryname == "Argentina"
replace M1 = M1 / 1000 if countryname == "Argentina"

replace M2 = M2 / 1000000 if countryname == "Bolivia"
replace M1 = M1 / 1000000 if countryname == "Bolivia"

replace M2 = M2 / 1000 if countryname == "Bolivia" & year >= 1983
replace M1 = M1 / 1000 if countryname == "Bolivia" & year >= 1983

replace M2 = M2 * 1000 if countryname == "Bolivia" & year <= 1954
replace M1 = M1 * 1000 if countryname == "Bolivia" & year <= 1954

replace M1  = M1  / 1000 if countryname == "Brazil" 
replace M1  = M1  / 1000 if countryname == "Brazil" & year <= 1989
replace M1  = M1  / 1000 if countryname == "Brazil" & year <= 1989
replace M1  = M1  / 1000 if countryname == "Brazil" & year <= 1974
replace M1  = M1  / 1000 if countryname == "Brazil" & year <= 1974 & year >= 1967


replace M2  = M2  / 1000 if countryname == "Brazil" 
replace M2  = M2  / 1000 if countryname == "Brazil" & year <= 1989
replace M2  = M2  / 1000 if countryname == "Brazil" & year <= 1989
replace M2  = M2  / 1000 if countryname == "Brazil" & year <= 1974
replace M2  = M2  / 1000 if countryname == "Brazil" & year <= 1974 & year >= 1967


replace M1 = M1 / 1000 if countryname == "Chile" & year >= 1983
replace M1 = M1 / 1000 if countryname == "Chile" & year <= 1974
replace M1 = M1 * 1000 if countryname == "Chile" & year <= 1954

replace M2 = M2 / 1000 if countryname == "Chile" & year >= 1983
replace M2 = M2 / 1000 if countryname == "Chile" & year <= 1974
replace M2 = M2 * 1000 if countryname == "Chile" & year <= 1954

replace M1 = M1 / 1000 if countryname == "Colombia" & year >= 1975
replace M1 = M1 / 1000 if countryname == "Colombia" & year <= 1964

replace M2 = M2 / 1000 if countryname == "Colombia" & year >= 1975
replace M2 = M2 / 1000 if countryname == "Colombia" & year <= 1964

replace M1 = M1 / 25000 if countryname == "Ecuador"
replace M1 = M1 / 1000 if countryname == "Ecuador" & year >= 1983
replace M1 = M1 / 1000 if countryname == "Ecuador" & year <= 1969

replace M2 = M2 / 25000 if countryname == "Ecuador"
replace M2 = M2 / 1000 if countryname == "Ecuador" & year >= 1983
replace M2 = M2 / 1000 if countryname == "Ecuador" & year <= 1969

replace M2 = M2 / 1000 if countryname == "Guyana"
replace M1 = M1 / 1000 if countryname == "Guyana"

replace M1 = M1 / 1000 if countryname == "Paraguay" & year <= 2000 & year >= 1975
replace M1 = M1 / 1000 if countryname == "Paraguay" & year <= 1969

replace M2 = M2 / 1000 if countryname == "Paraguay" & year <= 2000 & year >= 1975
replace M2 = M2 / 1000 if countryname == "Paraguay" & year <= 1969

replace M1 = M1 / 1000 if countryname == "Peru"
replace M1 = M1 / 1000 if countryname == "Peru" & year <= 1989

replace M2 = M2 / 1000 if countryname == "Peru"
replace M2 = M2 / 1000 if countryname == "Peru" & year <= 1989

replace M1 = M1 / 1000 if countryname == "Peru" & year <= 1984
replace M2 = M2 / 1000 if countryname == "Peru" & year <= 1984

replace M2 = M2 / 1000 if countryname == "Uruguay"
replace M2 = M2 / 1000 if countryname == "Uruguay" & year <= 1979
replace M2 = M2 / 1000 if countryname == "Uruguay" & year <= 1964

replace M1 = M1 / 1000 if countryname == "Uruguay"
replace M1 = M1 / 1000 if countryname == "Uruguay" & year <= 1979
replace M1 = M1 / 1000 if countryname == "Uruguay" & year <= 1964

replace M2 = M2 * (10^-14) if countryname == "Venezuela"
replace M1 = M1 * (10^-14) if countryname == "Venezuela"

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

