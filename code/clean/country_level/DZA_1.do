* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* CLEAN MONETARY AGGREGATE DATA FROM CENTRAL BANK OF ALGERIA
*
* Description: 
* This Stata script opens and cleans data on monetary aggregates from central bank of Algeria
*
* Author:
* Zekai Chen
* National University of Singapore
*
* URL: https://www.bank-of-algeria.dz/situation-monetaire/ (archived on: 2024-07-24)
* ==============================================================================

* ==============================================================================
* 	SET UP 
* ==============================================================================

* Define input and output files
clear
global input "${data_raw}/country_level/DZA_1.xlsx"
global output "${data_clean}/country_level/DZA_1" 

* ==============================================================================
* 	PROCESS
* ==============================================================================

* input the data
import excel using "${input}", clear allstring sheet(Situation monétaire)

* Keep relevant rows
replace A = strtrim(A)
replace A = "CS1_M2" if A == "MONNAIE ET QUASI-MONNAIE"
replace A = "CS1_M1" if A == "Monnaie"
replace A = "CS1_M0" if A == "Circulation fiduciaire H/BA"
keep if strpos(A, "CS1") | B == "Jan-74"

* Rename
qui ds A, not
foreach var in `r(varlist)' {
	qui replace `var' = subinstr(`var', "-", "", .)
    local newname = `var'[1]
    rename `var' Y_`newname'
}
drop in 1

* reshape
greshape long Y_, i(A) j(date) string
greshape wide Y_, i(date) j(A) 
ren Y_* *

* Generate the year and month
gen  year = substr(date, -2, .)
gen month_str = substr(date, 1, 3)

* Destring and extract the month
destring year, replace
replace year = year + 2000 if year <= 23
replace year = year + 1900 if year <= 99
replace date = "01" + "-" + month_str + "-" + string(year)
gen datem = .
replace datem = date(date, "DMY")
format datem %td
gen month = month(datem)

* Keep end-of-period observation
sort year month
by year: keep if _n == _N

* Drop 
drop date datem month month_str

* Destring
destring *, replace

* ==============================================================================
* 	OUTPUT
* ==============================================================================	
* Sort
sort year

* Add country's ISO3
gen ISO3 = "DZA"

* Order
order ISO3 year

* Check for duplicates
isid ISO3 year

* Save
save "${output}", replace
