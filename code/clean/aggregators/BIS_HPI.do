* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* CLEAN HOUSE PRICE DATA FROM BIS
* 
* Author:
* Ziliang Chen
* National University of Singapore
* 
* Created: 2024-04-24
*
* Description: This Stata script opens and cleans house price data from the BIS.
* 
* Data Source: Bank of International Settlements
* ==============================================================================

* ==============================================================================
* 	SET UP
* ==============================================================================

* Clear data 
clear

* Define globals 
global input "${data_raw}/aggregators/BIS/BIS_HPI.dta"
global output "${data_clean}/aggregators/BIS/BIS_HPI.dta"

* ==============================================================================
* 	PROCESSING
* ==============================================================================

* Open
use "$input", clear

* Drop regional aggregates
drop if inlist(ref_area,"4T","5R","XM","XW")
drop dataset_name freq series_code series_name

* Convert ISO2 to ISO3
ren ref_area ISO2
merge m:1 ISO2 using ${isomapping}, nogen assert(2 3) keep(3) keepusing(ISO3)
drop ISO2

* Replace NA with missing
replace value = "" if value == "NA"
destring value, replace

* Extract the year
gen year = substr(period, 1, 4)
destring year, replace

* Keep end-of-year observation
sort ISO3 year period
by ISO3 year: keep if _n == _N
drop period

* Rename
ren value BIS_HPI

* Keep relevant variables
keep ISO3 year BIS*

* ==============================================================================
* 	OUTPUT
* ==============================================================================
* Sort
sort ISO3 year

* Order
order ISO3 year 

* Check for duplicates
isid year ISO3 

* Save
save "${output}", replace
