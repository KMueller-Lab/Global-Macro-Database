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
global input "${data_raw}/aggregators/MITCHELL/Australia_govexp"
global output "${data_temp}/MITCHELL/Australia_govexp.dta"

*===============================================================================
* 			govexp: Sheet 2
*===============================================================================
clear
* Import
import_columns "${input}" "2"

* Destring
qui drop if year == ""
destring_check

* Convert units
qui ds year, not
foreach var in `r(varlist)'{
	convert_units `var' 1839 1869 "Th"
}

* Reshape
reshape_data govexp

* Save
save "${output}", replace



* Reshape
greshape wide govexp, i(year) j(countryname)
ren govexp* *

* Sum different states
gen Australia = 0
qui ds year Australia, not
foreach country in `r(varlist)'{
	replace `country' = 0 if `country' == .
	replace Australia = `country' + Australia
}

keep year Australia

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

