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
global input "${data_raw}/aggregators/MITCHELL/Africa_govexp"
global output "${data_temp}/MITCHELL/Africa_govexp.dta"

*===============================================================================
* 			govexp: Sheet 2
*===============================================================================
clear
* Import
import_columns "${input}" "2"

* Destring
qui drop if year == ""
destring_check

* Add South Africa 
gen SouthAfrica = CapeofGoodHope + Natal 
replace SouthAfrica = CapeofGoodHope if SouthAfrica == .
drop CapeofGoodHope Natal

* Convert units
local countries Ghana Kenya Malawi Mauritius Nigeria SierraLeone SouthAfrica Sudan Uganda Zambia Zanzibar Zimbabwe
foreach country of local countries {
	convert_units `country' 1812 1904 "Th"
}
convert_units Egypt 1812 1859 "Th"

* Reshape
reshape_data govexp

* Save
tempfile temp_c
save `temp_c', emptyok replace

*===============================================================================
* 			govexp: Sheet 3
*===============================================================================
* Import
import_columns "${input}" "3"

* Destring
qui drop if year == ""
destring_check

* Convert units
local countries Ghana Kenya Malawi SierraLeone Uganda Zambia Zanzibar Zimbabwe
foreach country of local countries {
	convert_units `country' 1905 1949 "Th"
}
convert_units Tanganyika 1915 1949 "Th"
convert_units Zimbabwe   1905 1939 "Th"
convert_units Nigeria	 1905 1944 "Th"
convert_units Sudan	     1905 1944 "Th"


* Reshape
reshape_data govexp

* Save
save_merge `temp_c'

*===============================================================================
* 			govexp: Sheet 4
*===============================================================================
* Import
import_columns "${input}" "4"

* Destring
qui drop if year == ""
replace Zanzibar = "" if strlen(Zanzibar) > 4
destring_check

* Convert units
local countries Cameroon Gabon IvoryCoast Madagascar Mali Senegal
foreach country of local countries {
	convert_units `country' 1950 2010 "B"
}
convert_units Tunisia 1950 1955 "B"
convert_units Tunisia 1950 1958 "B"
convert_units Zaire   1950 1959 "B"
convert_units Algeria 1950 1993 "B"
local countries Benin BurkinaFaso CentralAfricanRepublic Chad Congo Kenya Togo
foreach country of local countries {
	convert_units `country' 1970 2010 "B"
}

local countries Morocco Niger SouthAfrica Tanzania
foreach country of local countries {
	convert_units `country' 1975 2010 "B"
}
convert_units Zanzibar 1950 2010 "Th"
convert_units Ghana    1985 2010 "B"
convert_units Nigeria  2001 2010 "B"

* Reshape
reshape_data govexp

* Save
save_merge `temp_c'

*===============================================================================
* 			Convert units
*===============================================================================
sort countryname year
greshape wide govexp, i(year) j(countryname) string
ren govexp* *

*===============================================================================
* 			Convert currencies
*===============================================================================
replace Nigeria = Nigeria * 2 if year <= 1972
replace SierraLeone = SierraLeone * 2 if year <= 1963
replace Ghana = Ghana / 0.417 if year <= 1964
replace Madagascar = Madagascar / 5 if year <= 2000
replace SouthAfrica = SouthAfrica * 2 if year <= 1959
replace Algeria = Algeria / 100 if year <= 1960
replace Angola  = Angola / 1000000000 if year <= 1974
replace Cameroon = Cameroon * 3.3538549 if year <= 1919
replace Zanzibar = Zanzibar / 20
replace Tanganyika = Tanganyika / 25.4377 if year <= 1912 // Exchange rate from https://canvasresources-prod.le.unimelb.edu.au/projects/CURRENCY_CALC/

* Add Zanzibar and Tanganyika together
replace Tanzania = Zanzibar + Tanzania if Zanzibar != .
replace Tanzania = Tanganyika + Tanzania if Tanganyika != .
drop Tanganyika Zanzibar 

* Convert units
replace Tunisia = Tunisia / 1000000 if inrange(year, 1950, 1954)
replace Tunisia = Tunisia / 1000 if year <= 1949
replace Uganda  = Uganda  / 100  if year <= 1976
replace Zaire   = Zaire   / 1000
replace Zaire   = Zaire   / 1000 if year <= 1958
replace Zaire   = Zaire   / 1000 if year <= 1979
replace Zaire   = Zaire   / 100 if year <= 1997
replace Zaire   = Zaire   / 1000 if year <= 1993
replace Mauritius = Mauritius * 1000 if year <= 1904 & year >= 1850
replace Mauritius = Mauritius * 10 if year <= 1849
replace Algeria = Algeria * 1000 if year >= 1994
replace Algeria = Algeria * 1000 if inrange(year, 1947, 1949)
replace Ghana = Ghana / 10000
replace Mauritania = Mauritania / 10
replace Mozambique = Mozambique / 1000 if year <= 1973
replace Morocco = Morocco * 10 if year <= 1956 
replace Morocco = Morocco / 1000 if year <= 1944 
replace Sudan = Sudan / 1000 if year <= 1985
replace Zambia = Zambia / 1000 

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

