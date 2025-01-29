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
* This Stata script opens and cleans data on government expenditure from Mitchell IHS
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
global input "${data_raw}/aggregators/MITCHELL/Latam_govexp"
global output "${data_temp}/MITCHELL/Latam_govexp.dta"
*===============================================================================
* 			govexp: Sheet2
*===============================================================================
clear
import_columns "${input}" "2"

* Drop
drop F H

* Destring
qui drop if year == ""
destring_check


* Convert units
convert_units Guyana 1823 1864 "Th"

* Reshape and save
reshape_data govexp
tempfile temp_c
save `temp_c', emptyok replace


*===============================================================================
* 			govexp: Sheet3
*===============================================================================
* Open
import_columns "${input}" "3"

* Drop 
drop J L

* Use overlapping data if it exists and destring
replace Brazil = "34.46" if Brazil == "34 46"

* Destring
qui drop if year == ""
destring_check


* Convert units
convert_units Guyana 1865 1939 "Th"
convert_units Argentina 1950 1982 "B"
convert_units Argentina 1978 1982 "B"
convert_units Argentina 1985 1988 "B"

convert_units Bolivia 1950 2007 "B"
convert_units Bolivia 1985 2007 "B"

convert_units Brazil 1950 1966 "B"
convert_units Brazil 1985 1988 "B"
replace Brazil = Brazil * (10^-6) if year == 1989
convert_units Brazil 1990 1992 "Th"


convert_units Colombia 1967 2010 "B"

convert_units Ecuador 1970 1999 "B"
replace Ecuador = Ecuador / 25000 if year < 2000 // Convert to USD

convert_units Paraguay 1965 2010 "B"

convert_units Peru 1965 2010 "B"

convert_units Uruguay 1965 2010 "B"

convert_units Venezuela 1965 2010 "B"


* Reshape and append
reshape_data govexp
save_merge `temp_c'

* Convert units

replace govexp = govexp / 2750 if year <= 1988 & countryname  == "Brazil"
replace govexp = govexp * (10^-6) if year <= 1966 & countryname  == "Brazil"
replace govexp = govexp * (10^-6) if year <= 1988 & countryname  == "Brazil"


replace govexp = govexp * (10^-4) if year <= 1988 & countryname == "Argentina"
replace govexp = govexp * (10^-7) if year <= 1982 & countryname == "Argentina"
replace govexp = govexp * (10^-3) if year == 1978 & countryname == "Argentina"
replace govexp = govexp * (10^-2) if year <= 1969 & countryname == "Argentina"

replace govexp = govexp * (10^-3) if countryname == "Uruguay"
replace govexp = govexp * (10^-3) if year <= 1979 & countryname == "Uruguay"

replace govexp = govexp * (10^-3) if countryname == "Peru"
replace govexp = govexp * (10^-3) if year <= 1989 & countryname == "Peru"
replace govexp = govexp * (10^-3) if year <= 1984 & countryname == "Peru"

replace govexp = govexp * (10^3) if countryname == "Chile"
replace govexp = govexp * (10^-3) if year <= 1974 & countryname == "Chile"
replace govexp = govexp * (10^-3) if year <= 1966 & countryname == "Chile"
replace govexp = govexp * (10^-3) if year <= 1949 & countryname == "Chile"

replace govexp = govexp * (10^-6) if countryname == "Bolivia"
replace govexp = govexp * (10^-3) if year <= 1973 & countryname == "Bolivia"

replace govexp = govexp * (10^-2) if year <= 1939 & countryname == "Paraguay" 
replace govexp = govexp / 1.75 if year <= 1919 & countryname == "Paraguay" 

replace govexp = govexp * (10^-14) if countryname == "Venezuela"

replace govexp = govexp * (10^-3) if countryname == "Suriname"

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
