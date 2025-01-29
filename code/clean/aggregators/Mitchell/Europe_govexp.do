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
* This Stata script opens and cleans data on government expenditure from Mitchell IHS
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
global input "${data_raw}/aggregators/MITCHELL/Europe_govexp"
global output "${data_temp}/MITCHELL/Europe_govexp"

*===============================================================================
* 			govexp: Sheet2
*===============================================================================
clear
import_columns "${input}" "2"

* Rename columns
ren UK UnitedKingdom

* Destring
qui drop if year == ""
destring_check


* Reshape and save
reshape_data govexp
tempfile temp_c
save `temp_c', emptyok replace


*===============================================================================
* 			govexp: Sheet3
*===============================================================================

import_columns "${input}" "3"

* Rename columns
ren UK UnitedKingdom

* Use overlapping data if it exists and destring
use_overlapping_data
drop if year == .

* Reshape and append
reshape_data govexp
save_merge `temp_c'

*===============================================================================
* 			govexp: Sheet4
*===============================================================================

import_columns "${input}" "4"

* Rename columns
ren UK UnitedKingdom

* Use overlapping data if it exists and destring
use_overlapping_data
drop if year == .

* Reshape and append
reshape_data govexp
save_merge `temp_c'


*===============================================================================
* 			govexp: Sheet5
*===============================================================================
import_columns "${input}" "5"

* Rename columns
ren UK UnitedKingdom
ren RussiaUSSR Russia
ren SIreland Ireland
ren SerbiaYugoslavia Yugoslavia

* Destring
replace Austria = "" if year == "1922"
replace Hungary = "8644649" if Hungary == "8,644, 649"

* Destring
qui drop if year == ""
destring_check

* Reshape and append
reshape_data govexp
save_merge `temp_c'

*===============================================================================
* 			govexp: Sheet6
*===============================================================================
import_columns "${input}" "6"

* Rename columns
ren EGermany EastGermany
ren SIreland Ireland
ren Nethl Netherlands
ren RussiaUSSR Russia
ren UK UnitedKingdom

* Destring
qui drop if year == ""
destring_check


* Drop West Germany
replace Germany = WGermany if Germany == .
drop WGermany

* Reshape and append
reshape_data govexp
save_merge `temp_c'

*===============================================================================
* 			Convert units
*===============================================================================
qui greshape wide govexp, i(year) j(countryname) 
ren govexp* *
convert_units Belgium 1941 1993 "B"
convert_units Austria 1950 1993 "B"
convert_units Denmark 1950 1993 "B"
convert_units Finland 1940 2000 "B"
convert_units France  1940 2000 "B"
convert_units Italy   1940 1969 "B"
convert_units Italy   1970 1998 "Tri"
convert_units Netherlands   1950 1998 "B"
convert_units Norway   1950 2010 "B"
convert_units Spain    1950 2010 "B"
convert_units Switzerland    1970 2010 "B"
convert_units UnitedKingdom    1970 1979 "B"
convert_units Germany    1949 1993 "B"

replace Finland = Finland / 100 if year <= 1962
replace France = France / 100 if year <= 1959
replace Greece = Greece / 1000 if year <= 1952
replace Hungary = Hungary * 2 if year <= 1893
replace Hungary = Hungary / 12500 if year <= 1924
replace Austria = Austria / 10
replace Greece  = Greece * 1000
replace Portugal  = Portugal * 1000 if year >= 1950
replace Sweden  = Sweden * 1000 if year >= 1950
replace UnitedKingdom  = UnitedKingdom * 1000 if year >= 1980
replace Bulgaria  = Bulgaria / 1000000 
replace Romania = Romania * (10^-9) if year <= 1938
replace Romania = Romania / 10
replace Poland = Poland / 1000 if year <= 1949
replace Poland = Poland / 10
replace Germany = Germany / (10^12) if year <= 1924
replace Greece = Greece / (10^6) if year <= 1949
replace Greece = Greece / 4   if year <= 1949

* Reshape
reshape_data govexp

* Drop years after 1994
drop if year >= 1994


* Austria
replace govexp = govexp * 10 if countryname == "Austria"

* Germany government expenditure value in 1949 are unreliable
replace govexp = . if year == 1949 & countryname == "Germany"

* Russia
replace govexp = govexp * 1000 if year >= 1940 & countryname == "Russia"


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
