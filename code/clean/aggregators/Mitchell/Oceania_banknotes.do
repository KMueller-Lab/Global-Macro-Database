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
* This Stata script opens and cleans banknotes data from Mitchell IHS
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
global input "${data_raw}/aggregators/MITCHELL/Oceania_banknotes"
global output "${data_temp}/MITCHELL/Oceania_banknotes.dta"
*===============================================================================
* 			Banknotes: Sheet 2
*===============================================================================
clear
* Import
import_columns "${input}" "2"

* Destring
qui drop if year == ""
destring_check


* Convert units
convert_currency NewZealand 1965 2
replace NewZealand = NewZealand / 1000 if year <= 1909 

* Reshape
reshape_data M0

* Save
tempfile temp_c
save `temp_c', emptyok replace

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




