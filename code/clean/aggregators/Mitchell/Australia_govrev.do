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
global input "${data_raw}/aggregators/MITCHELL/Australia_govrev"
global output "${data_temp}/MITCHELL/Australia_govrev"

*===============================================================================
* 			govrev: Sheet 2
*===============================================================================
clear
* Import
import_columns "${input}" "2"

* Destring
qui drop if year == ""
destring_check

* Sum different states
gen Australia = 0
qui ds year Australia, not
foreach country in `r(varlist)'{
	replace `country' = 0 if `country' == .
	replace Australia = `country' + Australia
}

* Convert units
convert_units Australia 1820 1869 "Th"

* Keep
keep year Australia

* Reshape
reshape_data govrev

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

