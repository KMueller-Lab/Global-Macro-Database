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
global input "${data_raw}/aggregators/MITCHELL/Asia_banknotes"
global output "${data_temp}/MITCHELL/Asia_banknotes.dta"
*===============================================================================
* 			Banknotes: Sheet2
*===============================================================================
import_columns "${input}" "2"

* Destring
qui drop if year == ""
destring_check

* Reshape
reshape_data M0

* Save
tempfile temp_c
save `temp_c', emptyok replace

*===============================================================================
* 			Banknotes: Sheet3
*===============================================================================
import_columns "${input}" "3"

* Destring
qui drop if year == ""
destring_check

* Convert units
local countries China Japan
foreach country of local countries{
	convert_units `country' 1945 1949 "B"
}
convert_units Indonesia 1948 1949 "B"

* Reshape
reshape_data M0

* Save
save_merge `temp_c'

*===============================================================================
* 			Banknotes: Sheet4
*===============================================================================
import_columns "${input}" "4"

* Use overlapping data if it exists and destring
use_overlapping_data
drop if year == .

* Convert units
convert_units Thailand 1955 2010 "B"

local countries China India Indonesia Japan
foreach country of local countries{
	convert_units `country' 1950 2010 "B"
}

local countries Iran SouthKorea
foreach country of local countries{
	convert_units `country' 1965 2010 "B"
}

local countries SaudiArabia Taiwan Turkey SouthVietnam
foreach country of local countries{
	convert_units `country' 1970 2010 "B"
}

local countries Afghanistan Cambodia Pakistan Philippines
foreach country of local countries{
	convert_units `country' 1975 2010 "B"
}

convert_units Lebanon 1985 2010 "B"
convert_units Japan   1975 2010 "B"
convert_units Turkey  1996 2010 "B"

* Reshape
reshape_data M0

* Save
save_merge `temp_c'

*===============================================================================
* 			Convert currencies
*===============================================================================

qui greshape wide M0, i(year) j(countryname)
ren M0* * 

convert_currency Indonesia  1947 1/10
convert_currency Indonesia  1964 1/1000
convert_currency Israel     1982 1/1000
convert_currency SouthYemen 1988 26
replace Turkey = Turkey / (10^5)
replace SouthVietnam = Indochina if SouthVietnam == .
drop Indochina

ren SouthVietnam Vietnam

replace SouthYemen = SouthYemen + Yemen if Yemen != .
drop Yemen
ren SouthYemen Yemen


* Reshape
reshape_data M0

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
