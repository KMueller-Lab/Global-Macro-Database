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
* This Stata script opens and cleans the banknotes data from Mitchell IHS
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
global input "${data_raw}/aggregators/MITCHELL/Africa_banknotes.xlsx"
global output "${data_temp}/MITCHELL/Africa_banknotes"

*===============================================================================
* 			Banknotes: Sheet 2
*===============================================================================
clear
* Import
import_columns "${input}" "2"

* Destring
qui drop if year == ""
destring_check

* Create South Africa
generate SouthAfrica = CapeofGoodHope + Natal 
replace SouthAfrica = CapeofGoodHope if SouthAfrica == .
drop CapeofGoodHope Natal

* Convert units
convert_units SouthAfrica 1876 1909 "Th"

* Reshape
reshape_data M0

* Save
tempfile temp_c
save `temp_c', emptyok replace

*===============================================================================
* 			Banknotes: Sheet 3
*===============================================================================
* Import
import_columns "${input}" "3"

* Destring
qui drop if year == ""
destring_check

* Reshape
reshape_data M0

* Save
save_merge `temp_c'

*===============================================================================
* 			Banknotes: Sheet 4
*===============================================================================
* Import
import_columns "${input}" "4"

* Destring
qui drop if year == ""
destring_check

* Convert units
convert_units SouthAfrica 1910 1911 "Th"

* Reshape
reshape_data M0

* Save
save_merge `temp_c'

*===============================================================================
* 			Banknotes: Sheet 5
*===============================================================================
* Import
import_columns "${input}" "5"

* Destring
qui drop if year == ""
drop FrenchEquatorialAfrica 
replace Mozambique = "" if Mozambique == "thousand million meticais"
replace Sudan = "" if Sudan == "thousand million dinars"
destring_check

* Reshape
reshape_data M0

* Save
save_merge `temp_c'

*===============================================================================
* 			Convert units
*===============================================================================
sort countryname year
reshape wide M0, i(year) j(countryname) string
ren M0* *

* Convert Algeria new French franc to old franc
convert_units Algeria 1945 1960 "B"
convert_units Algeria 1975 2010 "B"
local countries Benin BurkinaFaso CentralAfricanRepublic Chad Congo Gabon IvoryCoast Madagascar Mali Niger Senegal Tunisia 
foreach country of local countries {
	qui convert_units `country' 1950 2010 "B"
}
convert_units Cameroon 1961 2010 "B"
convert_units Ghana 1985 2010 "B"
convert_units Morocco 1945 1956 "B"
convert_units Uganda 1966 1974 "Th"
convert_units Uganda 2001 2010 "B"
convert_units SouthAfrica 1983 2010 "B"

*===============================================================================
* 			Convert currencies
*===============================================================================
convert_currency Morocco 1956 10
replace Morocco = Morocco / 100 if year <= 1956
replace Nigeria = Nigeria * 2 if year <= 1972
replace SierraLeone = SierraLeone * 2 if year <= 1963
replace Ghana = Ghana / 0.417 if year <= 1964
replace Madagascar = Madagascar / 5 if year <= 2000
replace SouthAfrica = SouthAfrica * 2 if year <= 1959
replace SouthAfrica = SouthAfrica / 1000 if year >= 1983
replace Algeria = Algeria / 100 if year <= 1960
replace Angola  = Angola / 1000000 if year <= 1974
replace Sudan = Sudan * 1000 if year >= 1994
replace Sudan = Sudan / 10 if year < 1994
replace Tanzania = Tanzania / 1000 if year < 1983

* Reshape
reshape_data M0

* Save
tempfile temp_master
save `temp_master', replace

* Convert units
replace M0 = M0 / 1000 if countryname == "Madagascar" & inrange(year, 1950, 1959)
replace M0 = M0 / 1000 if countryname == "SierraLeone"
replace M0 = M0 * 1000 if countryname == "Tanzania"
replace M0 = M0 * 1000 if countryname == "Togo" & year >= 1970
replace M0 = M0 / 1000 if countryname == "Tunisia"
replace M0 = M0 * 5 if countryname == "Kenya" & year <= 1965
replace M0 = M0 / 1000 if year <= 1967 & countryname == "Zaire"
replace M0 = M0 / 3000 if year <= 1979 & countryname == "Zaire"
replace M0 = M0 / 1000 if year <= 1977 & countryname == "Zaire"
replace M0 = M0 /  1000 if year <= 1993 & countryname == "Zaire"
replace M0 = M0 /  100000 if year <= 1991 & countryname == "Zaire"
replace M0 = M0 * 1000 if countryname == "Mozambique" & year >= 1994
replace M0 = M0 * 1000 if countryname == "Zambia" & year >= 1988
replace M0 = M0 / 1000 if countryname == "Zimbabwe" & year <= 2000
replace M0 = M0 / 1000 if countryname == "Zimbabwe" & year <= 1963

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
