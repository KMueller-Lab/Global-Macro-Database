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
global input "${data_raw}/aggregators/MITCHELL/Americas_banknotes"
global output "${data_temp}/MITCHELL/Americas_banknotes.dta"
*===============================================================================
* 			Banknotes: Sheet 2
*===============================================================================
clear
import_columns "${input}" "2"

* Destring
qui drop if year == ""
destring_check

* Create the United States total as the sum of currency + notes
replace USA = USA + D 
drop D

* Reshape
reshape_data M0

* Save
tempfile temp_c
save `temp_c', emptyok replace


*===============================================================================
* 			Banknotes: Sheet 3
*===============================================================================
import_columns "${input}" "3"

* Destring
qui drop if year == ""
destring_check

* Create the United States total as the sum of currency + notes
replace USA = USA + N if N != .
drop N

* Convert units
convert_units USA 1935 2010 "B"
local countries Canada Mexico
foreach country of local countries{
	convert_units `country' 1975 2010 "B"
}
convert_units Nicaragua 1985 1987 "B"

* Reshape
reshape_data M0

* Save
save_merge `temp_c'


*===============================================================================
* 			Convert currencies
*===============================================================================

qui greshape wide M0, i(year) j(countryname)
ren M0* * 
convert_currency Nicaragua 1912 0.08
convert_currency Jamaica 1968 2
convert_currency Guatemala 1925 1/60

ren TrinidadTobago TrinidadandTobago

* Reshape
reshape_data M0

replace M0 = M0 / 1000 if countryname == "Mexico"
replace M0  = M0 / 8.75 if year <= 2000 & countryname == "ElSalvador"
replace M0  = M0 / 1000000 if year <= 1987 & countryname == "Nicaragua"
replace M0  = M0 / 200 if year <= 1989 & countryname == "Nicaragua"

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

