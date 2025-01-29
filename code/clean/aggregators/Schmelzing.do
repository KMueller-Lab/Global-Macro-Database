* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* CLEAN ECONOMIC DATA FROM PAUL SCHMELZING PAPER
* 
* Author:
* Mohamed Lehbib
* National University of Singapore
*
* Description: 
* This stata script cleans interest rate data from Paul Schmelzing
* Created: 2024-07-10
*
* URL: https://www.bankofengland.co.uk/working-paper/2020/eight-centuries-of-global-real-interest-rates-r-g-and-the-suprasecular-decline-1311-2018
* ==============================================================================

* ==============================================================================
* 	SET UP
* ==============================================================================

* Clear data 
clear

* Define input and output files 
global input "${data_raw}/aggregators/Schmelzing/Schmelzing.xlsx"
global output "${data_clean}/aggregators/Schmelzing/Schmelzing.dta"

* ==============================================================================
* 	NATIONAL ACCOUNTS
* ==============================================================================

* Open
import excel using "${input}", clear sheet("IV. Country level, 1310-2018")

* Keep only relevant rows and columns
keep A AE AF AG AH AI AJ AK AL 

* Rename
ren (A AE AF AG AH AI AJ AK AL ) (year ITA GBR NLD DEU FRA USA ESP JPN)
ds year, not
foreach var in `r(varlist)'{
		qui ren `var' Schmelzing`var'
}

* Fixed the years column 
replace year = "2016" if year == "2018" & _n == 710
replace year = "2015" if year == "2018" & _n == 709
replace year = "2014" if year == "2018" & _n == 708
replace year = "2013" if year == "2018" & _n == 707
replace year = "2017" if year == "2018" & _n == 711

* Destring
drop in 1/3
destring *, replace
drop if year == .

* Reshape
qui greshape long Schmelzing, i(year) j(ISO3) string

* Destring
destring year Schmelzing, replace

* Rename
ren Schmelzing Schmelzing_ltrate

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
