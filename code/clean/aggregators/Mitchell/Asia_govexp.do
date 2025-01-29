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
* This Stata script opens and cleans the government expenditure data from Mitchell IHS
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
global input "${data_raw}/aggregators/MITCHELL/Asia_govexp"
global output "${data_temp}/MITCHELL/Asia_govexp.dta"
*===============================================================================
* 			govexp: Sheet 2
*===============================================================================
clear
import_columns "${input}" "2"

* Destring
qui drop if year == ""
destring_check

* Reshape
reshape_data govexp

* Save
tempfile temp_c
save `temp_c', emptyok replace

*===============================================================================
* 			govexp: Sheet 3
*===============================================================================
import_columns "${input}" "3"

* Destring
qui drop if year == ""
destring_check

* Convert units
convert_units Cyprus 1860 1909 "Th"

* Reshape
reshape_data govexp

* Save
save_merge `temp_c'

*===============================================================================
* 			govexp: Sheet 4
*===============================================================================
import_columns "${input}" "4"

* Destring
qui drop if year == ""
destring_check

* Convert units
convert_units StraitsSettlements 1860 1909 "Th"

* Reshape
reshape_data govexp

* Save
save_merge `temp_c'

*===============================================================================
* 			govexp: Sheet 5
*===============================================================================
import_columns "${input}" "5"

* Destring
qui drop if year == ""
destring_check

* Convert units
convert_units Cyprus 1910 1949 "Th"
convert_units Palestine 1910 1939 "Th"
local countries Iran Japan
foreach country of local countries {
	convert_units `country' 1940 1949 "B"
}

* Rename
ren Malaya Malaysia

* Reshape
reshape_data govexp

* Save
save_merge `temp_c'

*===============================================================================
* 			govexp: Sheet 6
*===============================================================================
import_columns "${input}" "6"

* Destring
qui drop if year == ""
destring_check

* Convert units
local countries Bangladesh India Indonesia Iran Japan Thailand Vietnam
foreach country of local countries {
	convert_units `country' 1950 2010 "B"
}
convert_units Japan 1965 2010 "B"
convert_units Pakistan 1965 2010 "B"

local countries Malaysia SriLanka Syria
foreach country of local countries {
	convert_units `country' 1975 2010 "B"
}

local countries Indonesia SouthKorea Nepal Singapore UnitedArabEmirates
foreach country of local countries {
	convert_units `country' 1980 2010 "B"
}

* Reshape
reshape_data govexp

* Save
save_merge `temp_c'

*===============================================================================
* 			Convert currencies
*===============================================================================
qui greshape wide govexp, i(year) j(countryname)
ren govexp* * 

* Convert
convert_currency Turkey 1984 1/1000
convert_currency Indonesia 1964 1/1000
convert_currency Israel 1964 1.1
convert_currency Israel 1974 1/1000
convert_currency Israel 1984 1/1000
replace Israel = Israel * 1000
replace Turkey = Turkey / 1000 if year <= 1949
replace Philippines = Philippines * 1000 if year >= 1970
replace SouthKorea = SouthKorea * 1000
replace Taiwan = Taiwan * 1000 if year >= 1950

* Add indochina into vietnam
replace Vietnam =  Indochina if Vietnam != .
drop Indochina

* Add Straits Settlements to Singapore
replace Singapore =  StraitsSettlements if StraitsSettlements != .
drop StraitsSettlements

* Reshape
reshape_data govexp 

* Convert units for Taiwan
replace govexp = govexp * (10^-4) if year <= 1939 & countryname == "Taiwan"
replace govexp = govexp / 4 if year <= 1939 & countryname == "Taiwan"

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
*adjust_breaks govexp

* Save
save "${output}", replace
