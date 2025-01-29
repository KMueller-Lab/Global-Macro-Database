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
global input "${data_raw}/aggregators/MITCHELL/Europe_CPI"
global output "${data_temp}/MITCHELL/Europe_CPI"

*===============================================================================
* 			CPI: Sheet 2
*===============================================================================
clear
import_columns "${input}" "2"

* Destring
qui drop if year == ""
destring_check

* Reshape
ren UK UnitedKingdom
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

* Destring
qui drop if year == ""
destring_check

* Reshape
ren UK UnitedKingdom
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

* Destring
qui drop if year == ""
destring_check
drop in l

* Reshape
ren UK UnitedKingdom
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
replace Greece = "" if Greece == "1953 = 100"
replace Spain = "" if Spain == "1953 = 100"
replace Germany = "" if year == "1923"

* Destring
qui drop if year == ""
destring_check
drop in l

* Rename
ren UK UnitedKingdom
ren Nethl Netherlands
ren RussiaUSSR USSR

* Add West Germany to Germany
replace Germany = WestGermany if Germany == .
drop WestGermany

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
* 			CPI: Sheet 6
*===============================================================================
import_columns "${input}" "6"

* Destring
qui drop if year == ""
destring_check

* Add East Germany to Germany
ren WestGermany Germany
replace Germany = EastGermany if Germany == .
replace EastGermany = . if year >= 1990

* Rename
ren UK UnitedKingdom
ren SIreland Ireland

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
