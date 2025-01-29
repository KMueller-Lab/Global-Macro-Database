* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* 
* Description: 
* This Stata script reads in and clean monetary variables of Switzerland
*
* Author:
* Mohamed Lehbib
* National University of Singapore
*
* Created: 2024-06-26
*
* URL: https://www.snb.ch/en/the-snb/mandates-goals/statistics/statistics-pub/publication-history/historical-time-series
* ==============================================================================

* ==============================================================================
* 	SET UP 
* ==============================================================================
clear
global input1 "${data_raw}/country_level/CHE_1a"
global input2 "${data_raw}/country_level/CHE_1b"
global output "${data_clean}/country_level/CHE_1"

* ===============================================================================
*	PROCESS
* ===============================================================================

* Open
import excel using "${input1}", clear sheet(T 2.2) allstring

* Drop row with no data
drop in 1/3
drop in 45/l

* Drop column
drop C

* Rename
ren A year
ren B M1 
ren D M3

* Extract the year
replace year = substr(year, strlen(year) - 3, 4)

* Destring
destring *, replace

* Sort
sort year

* Save
tempfile temp_master
save `temp_master', replace emptyok

********************************************************************************

* Open
import excel using "${input1}", clear sheet(T 1.3) allstring

* Drop row with no data
drop in 1/3
drop in 45/l

* Keep
keep A D

* Rename
ren A year
ren D M0

* Extract the year
replace year = substr(year, strlen(year) - 3, 4)

* Destring
destring *, replace

* Sort
sort year

* Save and merge
tempfile temp_c
save `temp_c', replace emptyok
merge 1:1 year using `temp_master', nogen
save `temp_master', replace

********************************************************************************

* Open
import excel using "${input2}", clear sheet(1.1_A) allstring

* Drop documentation rows
drop in 1/6
drop in 101/l

* Keep columns with used data
keep A B C
 
* Rename
ren A year
ren B cbrate
ren C strate

* Extract the year
replace year = substr(year, strlen(year) - 3, 4)

* Destring
destring *, replace

* Sort
sort year

* Save and merge
tempfile temp_c
save `temp_c', replace emptyok
merge 1:1 year using `temp_master', nogen
save `temp_master', replace


* Add source identifier
qui ds year, not
foreach var in `r(varlist)'{
	ren `var' CS1_`var'
}

* Add country's ISO3
gen ISO3 = "CHE"

* ===============================================================================
* 	Output
* ===============================================================================

* Order
order ISO3 year

* Sort
sort ISO3 year

* Check for duplicates
isid ISO3 year

* Save
save "${output}", replace
