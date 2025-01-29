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
global input "${data_raw}/aggregators/MITCHELL/Americas_govexp"
global output "${data_temp}/MITCHELL/Americas_govexp.dta"

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
local countries Barbados Jamaica Trinidad
foreach country of local countries {
	convert_units `country' 1825 1864 "Th"
}

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
convert_units Trinidad 1865 1935 "Th"
convert_units Barbados 1865 1945 "Th"
convert_units Jamaica 1865 1944 "Th"
convert_units Mexico 1965 1984 "B"
convert_units Mexico 1985 2010 "Tri"
convert_units USA    1945 2010 "B"
convert_units Canada 1975 2010 "B"
convert_units CostaRica 1980 2010 "B"


* Reshape
reshape_data govexp

* Save
save_merge `temp_c'
*===============================================================================
* 			Convert currencies
*===============================================================================
qui greshape wide govexp, i(year) j(countryname)
ren govexp* * 
format * %9.0f
* Convert
convert_currency Nicaragua 1912 0.08
convert_currency Nicaragua 1987 0.0001
convert_currency Nicaragua 1989 0.2
convert_currency Jamaica 1968 2
convert_currency Guatemala 1923 1/60
convert_currency Trinidad 1935 4.2

* Rename
ren Trinidad TrinidadandTobago
ren EISalvador ElSalvador

* Convert El Salvador currency
replace ElSalvador = ElSalvador / 8.75 if year <= 2000

* Reshape wide
reshape_data govexp

* fix units for Mexico
replace govexp = govexp * (10^-6) if countryname == "Mexico"
replace govexp = govexp * (10^3) if year <= 1993 & countryname == "Mexico"
replace govexp = govexp * (10^-3) if year <= 1988 & countryname == "Nicaragua"
replace govexp = govexp * (10^-3) if year <= 1984 & countryname == "Nicaragua"
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
