* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* CLEAN MONETARY AGGREGATE DATA FROM CENTRAL BANK OF MOROCCO
* 
* Description: 
* This Stata script opens and cleans data on monetary aggregates from central bank of Morocco
*
* Author:
* Zekai Chen
* National University of Singapore
*
* URL: https://www.bkam.ma/Statistiques/Statistiques-monetaires/Series-statistiques-monetaires (archived on: 2024-07-24)
* ==============================================================================

* ==============================================================================
* SET UP 
* ==============================================================================

* Define input and output files
clear
global input1 "${data_raw}/country_level/MAR_1.xls"
global input2 "${data_raw}/country_level/MAR_2.xlsx"
global output "${data_clean}/country_level/MAR_1"

* Create temporary file
tempfile temp_master
save `temp_master', replace emptyok

* ==============================================================================
* 	PROCESS THE FILE WITH DATA BETWEEN 1985 AND 2001
* ==============================================================================

* Open
import excel using "${input1}", clear allstring sheet(Agrégats de monnaie)

* Keep only relevant rows
keep if inlist(A, "Circulation fiduciaire", "M1", "M2", "M3") | B == "31jan1985"
replace A = "M0" if A == "Circulation fiduciaire"
replace A = "year" if A == ""

* Rename
qui ds A, not
foreach var in `r(varlist)'{
	local varname = `var'[1]
	ren `var' CS1_`varname'
}
drop in 1

* Drop columns with no data
missings dropvars, force

* reshape the data
greshape long CS1_, i(A) j(date) string
greshape wide CS1_, i(date) j(A)

* Generate year and month dates
gen datem = .
replace datem = date(date, "DMY")
format datem %td
gen year = year(datem)
gen month = month(datem)
drop date datem


* Save 
tempfile temp_c
save `temp_c', replace emptyok
append using `temp_master'
save `temp_master', replace

* ==============================================================================
* 	PROCESS THE FILE WITH AFTER 2001
* ==============================================================================
* Open
import excel using "${input2}", clear allstring sheet(Feuil1)

* Keep only relevant rows
keep if inlist(A, "Circulation fiduciaire", "M1", "M2", "M3") | B == "31dec2001"
replace A = "M0" if A == "Circulation fiduciaire"
replace A = "year" if A == ""

* Rename
qui ds A, not
foreach var in `r(varlist)'{
	local varname = `var'[1]
	ren `var' CS1_`varname'
}
drop in 1

* Drop columns with no data
missings dropvars, force

* reshape the data
greshape long CS1_, i(A) j(date) string
greshape wide CS1_, i(date) j(A)

* Generate year and month dates
gen datem = .
replace datem = date(date, "DMY")
format datem %td
gen year = year(datem)
gen month = month(datem)
drop date datem

* Save and append
tempfile temp_c
save `temp_c', replace emptyok
append using `temp_master'

* Keep end-of-year data
sort year month
by year: keep if _n == _N
drop month

* Destring
destring *, replace

* Add country's ISO3
gen ISO3 = "MAR"

* ==============================================================================
* 	OUTPUT
* ==============================================================================

* Sort
sort year

* Order
order ISO3 year

* Check for duplicates
isid ISO3 year

* Save
save "${output}", replace
