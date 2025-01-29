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
global input "${data_raw}/aggregators/MITCHELL/Canada_govexp"
global output "${data_temp}/MITCHELL/Canada_govexp.dta"

*===============================================================================
* 			govexp: Sheet 2
*===============================================================================
clear
* Import
import_columns_first "${input}" "2"

* Destring
qui drop if year == ""
destring_check

* Sum different states
gen Canada = 0
qui ds year Canada, not
foreach country in `r(varlist)'{
	replace `country' = 0 if `country' == .
	replace Canada = `country' + Canada
}

* Convert units
convert_units Canada 1806 1839 "Th"

* Keep
keep year Canada

* Reshape
reshape_data govexp

* Save
tempfile temp_c
save `temp_c', emptyok replace

*===============================================================================
* 			govexp: Sheet 3
*===============================================================================
* Import
import_columns_first "${input}" "3"

* Destring
replace C = "771" if C == "771l"
qui drop if year == ""
destring_check

* Sum different states
gen Canada = 0
qui ds year Canada, not
foreach country in `r(varlist)'{
	replace `country' = 0 if `country' == .
	replace Canada = `country' + Canada
}
* Convert units
convert_units Canada 1840 1866 "Th"

* Keep
keep year Canada

* Reshape
reshape_data govexp

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

