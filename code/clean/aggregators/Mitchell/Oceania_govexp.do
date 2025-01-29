* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Ziliang Chen, Mohamed Lehbib
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
global input "${data_raw}/aggregators/MITCHELL/Oceania_govexp"
global output "${data_temp}/MITCHELL/Oceania_govexp.dta"
*===============================================================================
* 			govexp: Sheet 2
*===============================================================================
clear
* Import
import_columns "${input}" "2"

* Destring
qui drop if year == ""
destring_check


*===============================================================================
* 			Convert currencies
*===============================================================================
* Fiji
convert_units 	 Fiji 1840 1964 "Th"
convert_currency Fiji 1964 1/2

* Australia
convert_currency Australia 1964 2
convert_units Australia 1970 2010 "B"

* New Zealand
convert_units 	 NewZealand 1840 1899 "Th"
convert_units 	 NewZealand 1980 2010 "B"
convert_currency NewZealand 1964 2

* Hawaii
convert_units 	 Hawaii 1840 1929 "Th"

* Reshape
reshape_data govexp

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
