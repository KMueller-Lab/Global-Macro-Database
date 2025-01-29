* ==============================================================================
* GLOBAL CREDIT DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* 
* Description: 
* This Stata script reads in and clean data for Turkiye
* 
* Author:
* Mohamed Lehbib
* National University of Singapore
*
* Created: 2024-11-05
*
* ==============================================================================

* ==============================================================================
* 	SET UP 
* ==============================================================================
* Clear
clear
global input "${data_raw}/country_level/TUR_1"
global output "${data_clean}/country_level/TUR_1"

* ==============================================================================
*	POP
* ==============================================================================

* Open
use "$input", clear

* Extract indicators
gen indicator = "" 
replace indicator = "REER" if series_code == "cpiree" 
keep if indicator != ""

* Aggregate the data by taking end-of-period values 
keep period value indicator
gen year = substr(period, 1, 4)
destring year, replace
sort year period
by year: keep if _n == _N
drop period indicator
ren value CS1_REER

* Add ISO3 
gen ISO3 = "TUR"

* ==============================================================================
* 	Output
* ==============================================================================

* Order
order ISO3 year

* Sort
sort ISO3 year

* Check for duplicates
isid ISO3 year

* Save
save "${output}", replace
