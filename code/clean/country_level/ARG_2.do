* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* CLEAN DATA FOR ARGENTINA 
* 
* Description: 
* This Stata script reads in and cleans data from BANKING AND FINANCE IN ARGENTINA
*
* Author:
* Mohamed Lehbib
* National University of Singapore
*
* Created: 2024-10-28 
*
* Url: https://www.economia.gob.ar/download/infoeco/apendice8.xlsx
* ==============================================================================

* ==============================================================================
* SET UP 
* ==============================================================================

* Clear data 
clear 

* Define input and output files
global input "${data_raw}/country_level/ARG_2.xlsx"
global output "${data_clean}/country_level/ARG_2.dta"

* ==============================================================================
* 	PROCESS
* ==============================================================================
* Open  
import excel using "${input}", clear sheet("8.7 Series historicas") allstring

* Keep relevant columns and rows
keep A E I J K L AJ
drop in 1/9

* Rename
ren (A E I J K L AJ) (date USDfx M0 M1 M2 M3 strate)

* Extract the date
gen year_ = substr(date, -2, 2)
destring year_, replace
gen year = "19" + string(year_) if year_ > 24
replace year = "200" + string(year_) if year_ <= 9
replace year = "20" + string(year_) if year == ""
drop year_ 
destring year USDfx M0 M1 M2 M3 strate, replace

* Aggregate values
qui ds M0 M1 M2 M3
foreach var in `r(varlist)'{
	replace `var' = 0 if `var' == .
	sort year
	by year: gen `var'_s = sum(`var')
	drop `var'
	ren `var'_s `var'
}

* Keep end-of-year values for exchange rate and interst rate
keep if strpos(date, "Dec") > 0
drop date

* Add ISO3 code
gen ISO3 = "ARG"

* Add source identifier
qui ds year ISO3, not
foreach var in `r(varlist)' {
	ren `var' CS2_`var'
}

* ==============================================================================
* 	Output
* ==============================================================================
* Sort
sort ISO3 year

* Order
order ISO3 year

* Check for duplicates
isid ISO3 year

* Save 
save "${output}", replace
