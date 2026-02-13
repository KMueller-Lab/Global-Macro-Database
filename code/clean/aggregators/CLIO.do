* ==============================================================================
* GLOBAL MACRO PROJECT
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* Description: 
* This Stata script opens and cleans long term interest rate data and Inflation from CLIO
*
* Author:
* Mohamed Lehbib
* National University of Singapore
*
* Created: 2025-01-10
*
* URL:
* https://clio-infra.eu/
* ==============================================================================

* ==============================================================================
* 	SET UP 
* ==============================================================================

* Clear 
clear

* Define input and output files
global ltrate "${data_raw}/aggregators/CLIO/CLIO.xlsx"
global infl    "${data_raw}/aggregators/CLIO/CLIO_infl.xlsx"
global output "${data_clean}/aggregators/CLIO/CLIO.dta"

* ==============================================================================
* 	PROCESS
* ==============================================================================

* Open 
import excel using "$ltrate", clear sheet("Data Long Format") first

* Extract ISO3 
merge m:1 countryname using $isomapping, keepus(ISO3) nogen keep(1 3)
replace ISO3 = "RUS" if countryname == "Russia"

* Keep 
keep ISO3 year value

* Rename
ren value CLIO_ltrate

* Save 
tempfile temp_master
save `temp_master', replace

* ==============================================================================
* 	ADD INFLATION DATA
* ==============================================================================

import excel using "$infl", clear

qui ds A B, not
foreach var in `r(varlist)'{
	local newname = `var'[1]
	qui ren `var' CLIO_infl`newname'
}
drop in 1

* Reshape
greshape long CLIO_infl, i(A B) j(year)

* Take ISO3 codes 
ren A ISOnum
destring ISOnum CLIO_infl, replace
merge m:1 ISOnum using $isomapping, keepus(ISO3) keep(1 3)

* Fix the rest of countries not merged 
/*
levelsof B if _merge == 1, clean
Canada Kosovo Morocco Sudan
*/
replace ISO3 = "CAN" if B == "Canada"
replace ISO3 = "MAR" if B == "Morocco"
replace ISO3 = "XKX" if B == "Kosovo"
replace ISO3 = "SDN" if B == "Sudan"

* Drop
drop ISOnum B _merge 

* Merge 
merge 1:1 ISO3 year using `temp_master', nogen

* Keep the first year with data for every country 
qui ds ISO3 year, not
local vars `r(varlist)'
qui egen all_missing = rowmiss(`vars')
qui replace all_missing = (all_missing == `:word count `vars'')

* Sort by country and year
sort ISO3 year
qui bysort ISO3 (year): egen first_year = min(year) if all_missing == 0
qui bysort ISO3: egen first_year_final = min(first_year)
qui keep if year >= first_year_final

* Drop 
drop all_missing first_year first_year_final

* Drop the years with no data for every country 
qui ds ISO3 year, not
local vars `r(varlist)'
qui egen all_missing = rowmiss(`vars')
qui replace all_missing = (all_missing == `:word count `vars'')

* Sort by country and year
sort ISO3 year
qui bysort ISO3 (year): egen last_year = max(year) if all_missing == 0
qui bysort ISO3: egen last_year_final = max(last_year)
qui keep if year <= last_year_final

* Drop 
drop all_missing last_year last_year_final

* Thailand inflation data is leading by one year between 1944 and 1956 and this can be seen in all the other sources: tell sources
encode ISO3, gen(id)
gen iyear = -year
xtset id iyear
replace CLIO_infl = F.CLIO_infl if inrange(iyear, -1957, -1944) & ISO3 == "THA" 
drop iyear id 

* ==============================================================================
* 	OUTPUT
* ==============================================================================
* Order
order ISO3 year

* Sort
sort ISO3 year

* Check for duplicates
isid ISO3 year

* Output
save "${output}", replace