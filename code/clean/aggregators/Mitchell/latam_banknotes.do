* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Ziliang Chen, and Mohamed Lehbib
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
global input "${data_raw}/aggregators/MITCHELL/Latam_banknotes"
global output "${data_temp}/MITCHELL/Latam_banknotes.dta"
*===============================================================================
* 			Banknotes: Sheet2
*===============================================================================


clear
import_columns  "${input}" "2"

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

import_columns  "${input}" "3"

* Destring
qui drop if year == ""
destring_check


* Reshape
reshape_data M0

* Merge and save
save_merge `temp_c'

*===============================================================================
* 			Banknotes: Sheet4
*===============================================================================

import_columns  "${input}" "4"

* Destring
qui drop if year == ""
destring_check


* Reshape
reshape_data M0

* Merge and save
save_merge `temp_c'

*===============================================================================
* 			Convert units
*===============================================================================
qui greshape wide M0, i(year) j(countryname)
ren M0* *

replace Argentina = Argentina / 100 if year <= 1969
replace Argentina = Argentina / 1000 if year <= 1982
replace Argentina = Argentina / 10000 if year <= 1988
convert_units Argentina 1955 1982 "B"

convert_units Bolivia 1955 1982 "B"
convert_units Bolivia 1983 2010 "Tri"

replace Brazil = Brazil * 1000 if year >= 1940
replace Brazil = Brazil * 1000 if year >= 1975
replace Brazil = Brazil * 1000000 if year >= 1985
replace Brazil = Brazil / 1000 if year >= 1985
replace Brazil = Brazil / 1000 if year >= 1990
replace Brazil = Brazil / 2750 if year <= 1993


replace Chile = Chile / 1000 if year <= 1954
convert_units Chile 1970 1975 "B"
replace Chile = Chile / 1000 if year <= 1975
convert_units Chile 1983 2010 "B"

convert_units Colombia 1975 2010 "B"
convert_units Ecuador 1983 2000 "B"
replace Ecuador = Ecuador / 25000 if year <= 2000

replace Paraguay = Paraguay / 100 if year <= 1942
convert_units Paraguay 1975 2010 "B" 

replace Peru = Peru / 1000 if year <= 1929
replace Peru = Peru / (10^6) if year <= 1989
replace Peru = Peru / (1000) if year <= 1954

replace Uruguay = Uruguay / 1000 if year <= 1982
replace Uruguay = Uruguay / 1000 if year <= 1969

replace Venezuela = Venezuela / (10^8)
replace Venezuela = Venezuela / (10^3) if year <= 2000

* Reshape
reshape_data M0

* Convert units
replace M0 = M0 / 1000000 if countryname == "Bolivia"

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
    

