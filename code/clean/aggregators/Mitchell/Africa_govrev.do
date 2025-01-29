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
global input "${data_raw}/aggregators/MITCHELL/Africa_govrev"
global output "${data_temp}/MITCHELL/Africa_govrev.dta"


*===============================================================================
* 			govrev: Sheet 2
*===============================================================================
clear
import_columns "${input}" "2"

* Destring
qui drop if year == ""
destring_check

* Convert units
qui ds year Algeria, not
foreach country in `r(varlist)'{
	convert_units `country' 1812 1859 "Th"
}

* Add South Africa
gen SouthAfrica = CapeofGoodHope + Natal 
replace SouthAfrica = CapeofGoodHope if SouthAfrica == .
drop CapeofGoodHope Natal 

* Reshape
reshape_data govrev

* Save
tempfile temp_c
save `temp_c', emptyok replace

*===============================================================================
* 			govrev: Sheet 3
*===============================================================================
import_columns "${input}" "3"

* Destring
qui drop if year == ""
destring_check

* Convert units
local countries Ghana Kenya Malawi Nigeria SierraLeone
foreach country of local countries{
	convert_units `country' 1860 1904 "Th"
}

* Reshape
reshape_data govrev

* Save
save_merge `temp_c'

*===============================================================================
* 			govrev: Sheet 4
*===============================================================================
import_columns "${input}" "4"

* Destring
qui drop if year == ""
destring_check

* Add South Africa
gen SouthAfrica = CapeofGoodHope + Natal 
replace SouthAfrica = CapeofGoodHope if SouthAfrica == .
drop CapeofGoodHope Natal 

* Convert units
qui ds year Tanganyika Togo, not
foreach country in `r(varlist)'{
	convert_units `country' 1860 1904 "Th"
}

* Reshape
reshape_data govrev

* Save
save_merge `temp_c'

*===============================================================================
* 			govrev: Sheet 5
*===============================================================================
import_columns "${input}" "5"

* Destring
qui drop if year == ""
destring_check

* Convert units
local countries Algeria Morocco
foreach country of local countries{
	convert_units `country' 1945 1949 "B"
}

* Convert units
local countries Ghana Kenya Malawi Mozambique SierraLeone Uganda Zambia Zanzibar
foreach country of local countries{
	convert_units `country' 1905 1949 "Th"
}

* Convert units
local countries Nigeria
foreach country of local countries{
	convert_units `country' 1905 1949 "Th"
}

* Convert units
convert_units Tanganyika 1915 1949 "Th"
convert_units Sudan 1905 1944 "Th"

* Reshape
reshape_data govrev

* Save
save_merge `temp_c'

*===============================================================================
* 			govrev: Sheet 6
*===============================================================================
import_columns "${input}" "6"

* Destring
qui drop if year == ""
destring_check

* Convert units
local countries BurkinaFaso Benin CentralAfricanRepublic Chad Congo 
foreach country of local countries{
	convert_units `country' 1970 2010 "B"
}

* Convert units
local countries Algeria Gabon Cameroon IvoryCoast Madagascar Mali
foreach country of local countries{
	convert_units `country' 1950 2010 "B"
}

* Convert units
convert_units Kenya 1975 2010 "B"
convert_units Ghana 1985 2010 "B"

* Reshape
reshape_data govrev

* Save
save_merge `temp_c'

*===============================================================================
* 			govrev: Sheet 7
*===============================================================================
import_columns "${input}" "7"

* Destring
qui drop if year == ""
destring_check

* Convert units
local countries Morocco Niger
foreach country of local countries{
	convert_units `country' 1975 2010 "B"
}

* Convert units
convert_units Senegal 1950 2010 "B"
convert_units SouthAfrica 1980 2010 "B"
convert_units Mauritania 1990 2010 "B"

* Reshape
reshape_data govrev

* Save
save_merge `temp_c'

*===============================================================================
* 			govrev: Sheet 8
*===============================================================================
import_columns "${input}" "8"

* Destring
qui drop if year == ""
destring_check

* Convert units
local countries Tunisia Zaire
foreach country of local countries{
	convert_units `country' 1950 1960 "B"
}

* Convert units
convert_units Togo 1970 2010 "B"
convert_units Zaire 1980 1987 "B"
convert_units Zaire 1988 1991 "B"
convert_units Sudan 1988 2010 "B"

* Reshape
reshape_data govrev

* Save
save_merge `temp_c'

*===============================================================================
* 			Convert currencies
*===============================================================================
qui greshape wide govrev, i(year) j(countryname)
ren govrev* * 


* Convert
convert_currency Algeria 1960 1/100
convert_currency Ghana 1964 2.4
convert_currency Malawi 1963 2
convert_currency Mauritania 1969 1/5
convert_currency Nigeria 1964 2
convert_currency SierraLeone 1963 2
convert_currency Tunisia 1959 1/1000
convert_currency Zambia 1964 2
convert_currency SouthAfrica 1979 2
convert_currency Uganda 1949 20
convert_currency Uganda 1976 1/100

* Reshape
reshape_data govrev

* Fix units
replace govrev = govrev / 1000000  if year <= 1994 & countryname == "Angola"
replace govrev = govrev / 1000  if year <= 1964 & countryname == "Gabon"
replace govrev = govrev / 10000 if countryname == "Ghana"
replace govrev = govrev / 1000 if countryname == "Morocco" & year <= 1949
replace govrev = govrev * 10 if countryname == "Morocco" & year <= 1958
replace govrev = govrev / 1000 if countryname == "Mozambique" & year >= 1950
replace govrev = govrev * 1000 if inrange(year, 1940, 1949) & countryname == "Nigeria"
replace govrev = govrev * 10 if countryname == "Kenya" & year <= 1949
replace govrev = govrev * 1000 if countryname == "Tanzania" & year >= 1975
replace govrev = govrev * 100 if inrange(year, 1850, 1859) & countryname == "Mauritius"
replace govrev = govrev / 1000 if countryname == "SouthAfrica" & year == 1952
replace govrev = govrev / 10 if countryname == "Mauritania"
replace govrev = govrev / 1000 if countryname == "Sudan"  
replace govrev = govrev * 100 if countryname == "Zaire" & inrange(year, 1992, 1995)
replace govrev = govrev * (10^-6) if countryname == "Zaire" & year <= 1991
replace govrev = govrev / 3 if countryname == "Zaire" & year <= 1987
replace govrev = govrev / 1000 if countryname == "Zaire" & year <= 1958
replace govrev = govrev / 1000 if countryname == "Zambia"

* Data on Zaire is likely incorrect due to differences with other sources and ratio to GDP even after fixing units 
replace govrev = . if countryname == "Zaire"

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
