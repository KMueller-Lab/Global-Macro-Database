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
global input "${data_raw}/aggregators/MITCHELL/Latam_govrev"
global output "${data_temp}/MITCHELL/Latam_govtax"

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

* Keep  
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
egen Argentinatax = rowtotal(Argentina C)
egen Braziltax = rowtotal(Brazil G H)
egen Chiletax = rowtotal(Chile K)
egen Colombiatax = rowtotal(Colombia N)
egen Perutax = rowtotal(Peru T)
egen Uruguaytax = rowtotal(Uruguay X)
egen Venezuelatax = rowtotal(Venezuela AA AB)
keep year *tax
ren *tax *

* Reshape
reshape_data govtax
replace govtax = . if govtax == 0

* Save
tempfile temp_c
save `temp_c', emptyok replace


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

* Keep only needed columns
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
egen Argentinatax = rowtotal(Argentina C D)
egen Braziltax = rowtotal(Brazil H I)
egen Chiletax = rowtotal(Chile L)
egen Colombiatax = rowtotal(Colombia O P)
egen Perutax = rowtotal(Peru V)
egen Uruguaytax = rowtotal(Uruguay Z AA)
egen Venezuelatax = rowtotal(Venezuela AD AE)
keep year *tax
ren *tax *

* Convert units
convert_units Argentina 1955 1969 "B"
convert_units Argentina 1970 1978 "B"
convert_units Argentina 1979 1984 "Tri"
convert_units Argentina 1985 1988 "B"
convert_units Brazil 1955 1966  "B"
convert_units Brazil 1970 1988  "B"
convert_units Brazil 1990 1992 "Th"
convert_units Chile  1950 1954 "B"
convert_units Chile  1970 2010 "B"
convert_units Colombia 1975 2010 "B"
convert_units Uruguay 1965 1974 "B"
convert_units Uruguay 1980 2010 "B"
convert_units Venezuela 1975 2010 "B"


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
convert_currency Argentina 1969 1/100
convert_currency Argentina 1984 1/1000
convert_currency Argentina 1989 1/10000
convert_currency Brazil    1966 1/1000
convert_currency Brazil    1984 1/1000
convert_currency Brazil    1988 1/2750
convert_currency Brazil    1989 1/1000000

* Reshape
reshape_data govtax

* Convert currency units
* Chile
replace govtax = govtax / 1000 if year <= 1974 & countryname == "Chile"
replace govtax = govtax / 1000 if year <= 1954 & countryname == "Chile"

* Ecuador
replace govtax = govtax / 2500 if year <= 1993 & countryname == "Ecuador"

* Uruguay
replace govtax = govtax / 1000 if countryname == "Uruguay"
replace govtax = govtax / 1000 if year <= 1974 & countryname == "Uruguay"

* Peru
replace govtax = govtax * 1000 if year >= 1965 & year <= 1984 & countryname == "Peru" // Convert to millions of old soles
replace govtax = govtax / 1000 if year <= 1984 & countryname == "Peru" // Convert to intis 
replace govtax = govtax * 1000 if year <= 1987 & year >= 1985 & countryname == "Peru" // Convert milion of intis
replace govtax = govtax / 1000 if year >= 1988 & countryname == "Peru" // Convert to million of new soles
replace govtax = govtax / 10^6 if year <= 1987 & countryname == "Peru" // Convert all data to new soles

* Venezuela
replace govtax = govtax / (10^8) if countryname == "Venezuela"

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
