* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* Description: 
* This Stata script opens and cleans macroeconomic data from the Taiwan statistical office.
*
* Author:
* Mohamed Lehbib
* National University of Singapore
*
* Created: 2025-02-28
*
* URL: https://eng.stat.gov.tw/Default.aspx
* ==============================================================================

* ==============================================================================
* 	SET UP 
* ==============================================================================

* Clear 
clear

* Define input and output files
global input "${data_raw}/country_level/"
global output "${data_clean}/country_level/TWN_2.dta"

* ==============================================================================
* 	CONSUMER PRICE INDEX
* ==============================================================================

* Import the data
import excel using "$input/TWN_2a.xls", clear cellrange(A4:N71) first

* Keep 
keep Year Index
ren (Year Index) (year CPI)

 
* Rebasing to 2010
su CPI if year == 2010, meanonly
replace CPI = (CPI * 100) / r(mean)


* Derive inflation
gen infl = (CPI[_n] - CPI[_n-1])/CPI[_n-1] * 100

* Save 
tempfile temp_master
save `temp_master', replace

* ==============================================================================
* 	EXCHANGE RATE, and POPULATION
* ==============================================================================

* Import the data
import excel using "$input/TWN_2b.xlsx", clear

* Rename the columns
ren (A B C E) (year pop USDfx nGDP)

* Keep relevan columns
keep year pop USDfx nGDP

* Drop preliminary data
drop in 330/l
drop in 1/4

* Keep only yearly values 
keep if strlen(year) == 4

* Destring
destring *, replace

* Merge and save
merge 1:1 year using `temp_master', nogen
save `temp_master', replace

* ==============================================================================
* 	NATIONAL ACCOUNTS (1951-1981)
* ==============================================================================

* Import the data
import excel using "$input/TWN_2c.xlsx", clear

* Rename the columns
ren (C D Q R S AD AG AJ) (year cons_hh cons_gov inv finv exports imports nGDP)

* Keep relevant columns
keep year cons_hh cons_gov inv finv exports imports nGDP

* Keep only yearly values 
keep in 10/39

* Destring
destring *, replace

* Derive total consumption 
gen cons = cons_hh + cons_gov
drop cons_*

* Merge and save
merge 1:1 year using `temp_master', nogen
save `temp_master', replace

* ==============================================================================
* 	NATIONAL ACCOUNTS (1981-2023)
* ==============================================================================

* Import the data
import excel using "$input/TWN_2c.xlsx", clear sheet(GDP(nominal,1981～))

* Rename the columns
ren (C D V W X AI AL AQ) (year cons_hh cons_gov inv finv exports imports nGDP)

* Keep relevant columns
keep year cons_hh cons_gov inv finv exports imports nGDP

* Keep only yearly and final (no preliminary) values 
keep in 9/51

* Destring
destring *, replace

* Derive total consumption 
gen cons = cons_hh + cons_gov
drop cons_*

* Merge and save
merge 1:1 year using `temp_master', nogen
save `temp_master', replace

* ==============================================================================
* 	REAL GDP and consumption (1981-2023)
* ==============================================================================

* Import the data
import excel using "$input/TWN_2c.xlsx", clear sheet(GDP(chained dollars,1981～))

* Rename the columns
ren (C D V AQ) (year cons_hh cons_gov rGDP)

* Keep relevant columns
keep year cons_hh cons_gov rGDP

* Keep only yearly and final (no preliminary) values 
keep in 9/51

* Destring
destring *, replace

* Derive total real consumption 
gen rcons = cons_hh + cons_gov
drop cons_*

* Merge and save
merge 1:1 year using `temp_master', nogen
save `temp_master', replace

* ==============================================================================
*  UNEMPLOYMENT RATE
* ==============================================================================

* Import the data
import excel using "$input/TWN_2d.xlsx", clear

* Rename the columns
ren (A G) (year unemp)

* Keep relevant columns
keep year unemp

* Keep only yearly values 
keep if strpos(year, "Dec")

* Destring
replace year = substr(year, -4, 4)
destring *, replace

* Assert that no yearly values were dropped because they weren't available in Dec 
su year
assert r(max) - r(min) == 46 // 2024 - 1978 = 46

* Merge and save
merge 1:1 year using `temp_master', nogen
save `temp_master', replace

* ==============================================================================
* 	Output
* ==============================================================================

* Rebase GDP to 2010
gen deflator = (nGDP / rGDP) * 100
gen  temp = deflator if year == 2010
egen defl_2010 = max(temp)
replace rGDP = (rGDP * defl_2010) / 100
drop temp defl_2010

* Update the deflator
replace deflator = (nGDP / rGDP) * 100


* Add source identifier 
ren * CS2_*
ren CS2_year year

* Add country ISO3 
gen ISO3 = "TWN"

* Sort
sort ISO3 year

* Order
order ISO3 year

* Check for duplicates
isid ISO3 year

* Save 
save "${output}", replace


