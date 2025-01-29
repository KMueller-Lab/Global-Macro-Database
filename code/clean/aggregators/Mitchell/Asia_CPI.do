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
global input "${data_raw}/aggregators/MITCHELL/Asia_CPI"
global output "${data_temp}/MITCHELL/Asia_CPI"

*===============================================================================
* 			CPI: Sheet 2
*===============================================================================
import_columns "${input}" "2"

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
drop in 30
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
drop in 37
drop in 34
drop in 27/28
drop in 13
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
