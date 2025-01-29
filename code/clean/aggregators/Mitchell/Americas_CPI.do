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
* This Stata script opens and cleans the consumer price index data from Mitchell IHS
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
global input "${data_raw}/aggregators/MITCHELL/Americas_CPI"
global output "${data_temp}/MITCHELL/Americas_CPI"

*===============================================================================
* 			CPI: Sheet 2
*===============================================================================
import_columns "${input}" "2"

* Use overlapping data if it exists and destring
drop in 1

* Destring
qui drop if year == ""
destring_check

* Reshape
reshape_data CPI

* Derive inflation rate
sort countryname year
encode countryname, gen(id)
xtset id year
by id: gen infl = (CPI - L.CPI) / L.CPI * 100  if L.CPI != .
drop id

* Save
tempfile temp_c
save `temp_c', emptyok replace

*===============================================================================
* 			CPI: Sheet 3
*===============================================================================
import_columns "${input}" "3"

* Use overlapping data if it exists and destring
drop in 1

* Destring
qui drop if year == ""
destring_check

* Reshape
reshape_data CPI

* Derive inflation rate
sort countryname year
encode countryname, gen(id)
xtset id year
by id: gen infl = (CPI - L.CPI) / L.CPI * 100  if L.CPI != .
drop id

* Save
save_merge `temp_c'

*===============================================================================
* 			CPI: Sheet 4
*===============================================================================
import_columns "${input}" "4"

* Use overlapping data if it exists and destring
drop in 1
drop in 5
drop in 39
drop in l // Last row because it's duplicated in the next sheet

* Destring
qui drop if year == ""
destring_check

* Reshape
reshape_data CPI

* Derive inflation rate
sort countryname year
encode countryname, gen(id)
xtset id year
by id: gen infl = (CPI - L.CPI) / L.CPI * 100  if L.CPI != .
drop id

* Save
save_merge `temp_c'

*===============================================================================
* 			CPI: Sheet 5
*===============================================================================

import_columns "${input}" "5"

* Use overlapping data if it exists and destring
drop in 1
drop in 15
drop in 20 
drop in 27

* Destring
qui drop if year == ""
destring_check

* Reshape
reshape_data CPI

* Add missing data
replace CPI = 100 if CPI == . & year == 2000

* Derive inflation rate
sort countryname year
encode countryname, gen(id)
xtset id year
by id: gen infl = (CPI - L.CPI) / L.CPI * 100  if L.CPI != .
drop id

* Save 
save_merge `temp_c'

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


* Adjust breaks
adjust_breaks_CPI

* Sort
sort countryname year

* Order
order countryname year

* Check for duplicates
isid countryname year

* Save
save "${output}", replace
