* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* 
* Description: 
* This Stata script reads in and cleans Italian National Accounts data from 1861-2011
*
* Author:
* Mohamed Lehbib
* National University of Singapore
*
* Created: 2024-07-04
*
* URL: https://www.bancaditalia.it/statistiche/tematiche/stat-storiche/stat-storiche-moneta/
* ==============================================================================

* ==============================================================================
* SET UP 
* ==============================================================================
clear
global input1 "${data_raw}/country_level/ITA_2.xlsx"
global input2 "${data_raw}/country_level/ITA_3.xlsx"
global input3 "${data_raw}/country_level/ITA_4.xlsx"
global output "${data_clean}/country_level/ITA_2"

* Create a temporary file
tempfile temp_master
save `temp_master', replace emptyok

* ===============================================================================
* 	Rendimento BOT (Italian treasury bills (Buoni Ordinari del Tesoro)): strate
* ===============================================================================

* Open
qui import excel using "$input1", clear sheet(Rendimenti BOT (annuali))

* Drop 
drop in 1

* Rename
ren A year
ren B strate

* Destring
qui destring *, replace 

* Assert that all columns are numeric now
ds, has(type string) 
cap `r(varlist)'
if _rc != 0 {
    di as error "Not all variables are numeric."
}
else {
    di as txt "All variables are numeric."
}

* Save
tempfile temp_c
save `temp_c', replace emptyok
append using `temp_master'
save `temp_master', replace 

* ===============================================================================
* 	Rendimenti_ML_term (Bonds with maturity higher than 1 year): ltrate
* ===============================================================================

* Open
qui import excel using "$input1", clear sheet(Rendimenti_ML_term (annuali))

* Drop 
drop in 1

* Rename
ren A year
ren B ltrate

* Destring
qui destring *, replace 

* Assert that all columns are numeric now
ds, has(type string) 
cap `r(varlist)'
if _rc != 0 {
    di as error "Not all variables are numeric."
}
else {
    di as txt "All variables are numeric."
}

* Save
tempfile temp_c
save `temp_c', replace emptyok
merge 1:1 year using `temp_master', nogen
save `temp_master', replace

* ===============================================================================
* 	Tasso ufficiale: official discount rate (cbrate)
* ===============================================================================

* Open
qui import excel using "$input2", clear sheet(TASSI UFFICIALI) cellrange(A4:B177)

* Generate the year
gen year = substr(A, -4, .)

* Aggregate
collapse (mean) cbrate=B, by(year)

* Destring
qui destring *, replace

* Assert that all columns are numeric now
ds, has(type string) 
cap `r(varlist)'
if _rc != 0 {
    di as error "Not all variables are numeric."
}
else {
    di as txt "All variables are numeric."
}

* Save
tempfile temp_c
save `temp_c', replace emptyok
merge 1:1 year using `temp_master', nogen
save `temp_master', replace

* ===============================================================================
* 	M0-M1-M2
* ===============================================================================

* Open
qui import excel using "$input3", clear sheet(M1_M2) cellrange(A6:J159)

* Keep relevant columns
keep A D G J

* Rename
ren A year
ren D M0 
ren G M1 
ren J M2

* Convert units
qui ds year, not
foreach var in `r(varlist)' {
	replace `var' = `var' / 1000 if year <= 1949
}

* Destring
qui destring *, replace

* Assert that all columns are numeric now
ds, has(type string) 
cap `r(varlist)'
if _rc != 0 {
    di as error "Not all variables are numeric."
}
else {
    di as txt "All variables are numeric."
}

* Save
tempfile temp_c
save `temp_c', replace emptyok
merge 1:1 year using `temp_master', nogen
save `temp_master', replace

* ===============================================================================
* 	M3
* ===============================================================================

* Open
qui import excel using "$input3", clear sheet(M3) cellrange(A55:I70)

* Keep relevant columns
keep A I

* Rename
ren A year
ren I M3

* Destring
qui destring *, replace

* Assert that all columns are numeric now
ds, has(type string) 
cap `r(varlist)'
if _rc != 0 {
    di as error "Not all variables are numeric."
}
else {
    di as txt "All variables are numeric."
}

* Save
tempfile temp_c
save `temp_c', replace emptyok
merge 1:1 year using `temp_master', nogen

* Add country's ISO3
gen ISO3 = "ITA"

* Add source identifier
qui ds ISO3 year, not
foreach var  in `r(varlist)'{
	ren `var' CS2_`var'
}

* ===============================================================================
* 	OUTPUT
* ===============================================================================
* Sort
sort year

* Order
order ISO3 year

* Check for duplicates
isid ISO3 year

* Save
save "${output}", replace
