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
* This Stata script opens and cleans the GDP data from Mitchell IHS
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
global output "${data_temp}/MITCHELL/Latam_nGDP"

*===============================================================================
* 			nGDP: Sheet 2
*===============================================================================
clear
import_columns_first "${input}" "2"

* Keep columns
keep year B

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


* Reshape
reshape_data nGDP

* Save
tempfile temp_c
save `temp_c', emptyok replace

*===============================================================================
* 			nGDP: Sheet 3
*===============================================================================
import_columns_first "${input}" "3"

* Keep columns
keep year E

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

* Reshape
reshape_data nGDP

* Save
save_merge `temp_c'

*===============================================================================
* 			nGDP: Sheet4
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
	if `var'[3] == "current prices" &  inlist(`var'[4], "gdp") {
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
local countries Argentina Chile Ecuador Paraguay Venezuela
foreach country of local countries {
	convert_units `country' 1935 1969 "B"
}

* Reshape
reshape_data nGDP

* Save
save_merge `temp_c'


*===============================================================================
* 			nGDP: Sheet5
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
	if `var'[3] == "current prices" &  inlist(`var'[4], "gdp") {
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
local countries Bolivia Brazil Colombia Ecuador Paraguay Uruguay Venezuela
foreach country of local countries {
	convert_units `country' 1970 1993 "B"
}

convert_units Argentina 1970 1986 "B"

* Reshape
reshape_data nGDP

* Save
save_merge `temp_c'

* Rename
ren nGDP nGDP_LCU

* Drop data after 1993
drop if year >= 1993

* Fix currency issues
replace nGDP_LCU = nGDP_LCU / 2750 if countryname == "Brazil"
replace nGDP_LCU = nGDP_LCU / 1000 if countryname == "Brazil"
replace nGDP_LCU = nGDP_LCU / 1000 if year <= 1989 & countryname == "Brazil"
replace nGDP_LCU = nGDP_LCU / 1000 if year <= 1979 & countryname == "Brazil"
replace nGDP_LCU = nGDP_LCU * 1000 if inrange(year, 1960, 1969) & countryname == "Brazil"

* Argentina
replace nGDP_LCU = nGDP_LCU / 10 if year <= 1979 & countryname == "Argentina"
replace nGDP_LCU = nGDP_LCU * 100 if inrange(year, 1965, 1974) & countryname == "Argentina"
replace nGDP_LCU = . if year >= 1985 & countryname == "Argentina"
replace nGDP_LCU = nGDP_LCU / 10000000 if countryname == "Argentina" & year <= 1985
replace nGDP_LCU = nGDP_LCU / 100000 if countryname == "Argentina" & year <= 1974

* Venezuela
replace nGDP_LCU = nGDP_LCU * (10^-8) if countryname == "Venezuela"

* Ecuador
replace nGDP_LCU = nGDP_LCU * (10^-3) / 25000 if  countryname == "Ecuador"

* Colombia
replace nGDP_LCU = nGDP_LCU * (10^3) if  countryname == "Colombia" & year <= 1969

* Uruguay
replace nGDP_LCU = nGDP_LCU * (10^-3) if countryname == "Uruguay" 
replace nGDP_LCU = nGDP_LCU / 1000 if year <= 1979 & countryname == "Uruguay" 
replace nGDP_LCU = nGDP_LCU * 1000 if year <= 1969 & countryname == "Uruguay" 
replace nGDP_LCU = nGDP_LCU / 1000 if year <= 1959 & countryname == "Uruguay" 

* Peru
replace nGDP_LCU = nGDP_LCU * (10^-3) if year <= 1988 & countryname == "Peru" 
replace nGDP_LCU = nGDP_LCU * (10^-3) if year <= 1979 & countryname == "Peru" 
replace nGDP_LCU = nGDP_LCU * (10^-3) if year <= 1949 & countryname == "Peru" 

* Bolivia
replace nGDP_LCU = nGDP_LCU / 1000 if countryname == "Bolivia" & year <= 1992
replace nGDP_LCU = nGDP_LCU / 1000 if countryname == "Bolivia" & year == 1984
replace nGDP_LCU = nGDP_LCU / 100 if countryname == "Bolivia" & year <= 1983
replace nGDP_LCU = nGDP_LCU / 10 if countryname == "Bolivia" & year <= 1979

* Chile
replace nGDP_LCU = nGDP_LCU / 1000 if countryname == "Chile" & year <= 1969
replace nGDP_LCU = nGDP_LCU / 1000 if countryname == "Chile" & year <= 1964
replace nGDP_LCU = nGDP_LCU * 1000 if countryname == "Chile" & year >= 1975


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
