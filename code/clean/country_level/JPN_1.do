* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* 
* Description: 
* This Stata script reads in and clean interest rates data for JAPAN
*
* Author:
* Mohamed Lehbib
* National University of Singapore
*
* Created: 2024-10-08
*
* URL: https://www.imes.boj.or.jp/en/historical/hstat/hstat.html
* ==============================================================================

* ==============================================================================
* 	SET UP 
* ==============================================================================
* Clear
clear
global input1 "${data_raw}/country_level/JPN_1a"
global input2 "${data_raw}/country_level/JPN_1b"
global output "${data_clean}/country_level/JPN_1"

* ===============================================================================
*	JPN_1a
* ===============================================================================

* Open
import excel using "${input1}", clear sheet("ltrate") first allstring

* Add year
gen year = "" 
replace year = date if strlen(date) == 4
replace year = "20" + substr(date, -2, .) if year == ""

* Keep only relevant columns
keep year ltrate

* Destring
destring *, replace

* Keep only end-of-year values
sort year
by year: keep if _n == _N

* Save
tempfile temp_master1
save `temp_master1', replace emptyok

* Open
import excel using "${input1}", clear sheet("strate") first allstring

* Add year
gen year = "" 
replace year = substr(date, -4, .)

* Keep only relevant columns
keep year strate

* Destring
destring *, replace

* Keep only end-of-year values
sort year
by year: keep if _n == _N

* Save and merge
tempfile temp_c
save `temp_c', replace emptyok
merge 1:1 year using `temp_master1', nogen
save `temp_master1', replace	

* Add country's ISO3
gen ISO3 = "JPN"
save `temp_master1', replace	


* ===============================================================================
*	JPN_1b
* ===============================================================================

* Open
import excel using "${input2}", clear sheet("cbrate") first allstring

* Add year
gen year = "" 
replace year = substr(date, 1, 4)

* Keep only relevant columns
keep year cbrate

* Destring
destring *, replace

* Keep only end-of-year values
drop if cbrate == . // If end-of-year value is missing, take the previous one
sort year
by year: keep if _n == _N

* Save
tempfile temp_master2
save `temp_master2', replace emptyok

* Open
import excel using "${input2}", clear sheet("strate") first allstring

* Add year
gen year = "" 
replace year = substr(date, 1, 4)

* Compute interest rate as the average of high and low
destring High Low, replace
gen strate = (High + Low) / 2

* Keep only relevant columns
keep year strate

* Destring
destring *, replace

* Keep only end-of-year values
sort year
by year: keep if _n == _N

* Save and merge
tempfile temp_c
save `temp_c', replace emptyok
merge 1:1 year using `temp_master2', nogen
save `temp_master2', replace	

* Open
import excel using "${input2}", clear sheet("CPI") first allstring

* Add year
gen year = "" 
replace year = substr(date, 1, 4)

* Keep only relevant columns
keep year CPI

* Destring
destring *, replace

* Keep only end-of-year values
sort year
by year: keep if _n == _N

* Save and merge
tempfile temp_c
save `temp_c', replace emptyok
merge 1:1 year using `temp_master2', nogen
save `temp_master2', replace	

* Open
import excel using "${input2}", clear sheet("M0") first allstring

* Add year
gen year = "" 
replace year = substr(date, 1, 4)

* Keep only relevant columns
keep year M0

* Destring
destring *, replace

* Keep only end-of-year values
drop if M0 == . // If end-of-year value is missing, take the previous one
sort year
by year: keep if _n == _N

* Convert unit
replace M0 = M0 / 1000

* Save and merge
tempfile temp_c
save `temp_c', replace emptyok
merge 1:1 year using `temp_master2', nogen
save `temp_master2', replace	

* Add country's ISO3
gen ISO3 = "JPN"

* Derive inflation rate
sort ISO3 year
encode ISO3, gen(id)
xtset id year
by id: gen infl = (CPI - L.CPI) / L.CPI * 100 if L.CPI != .
drop id

save `temp_master2', replace	


* ===============================================================================
* 	Merge two tempfiles
* ===============================================================================

merge 1:1 year using `temp_master1', nogen
save `temp_master1', replace	

* Add source identifier
qui ds ISO3 year, not
foreach var in `r(varlist)'{
	ren `var' CS1_`var'
}


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
