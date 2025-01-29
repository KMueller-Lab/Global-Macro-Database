* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* 
* Description: 
* This Stata script reads in and cleans data on real effective exchange rates
*
* Author:
* Mohamed Lehbib
* National University of Singapore
*
* Created: 2024-10-14
*
* URL: https://www.lusem.lu.se/organisation/department-economic-history/research-department-economic-history/databases-department-economic-history/economic-history-data/nominal-and-real-effective-exchange-rates-europe
* ==============================================================================

* ==============================================================================
* SET UP
* ==============================================================================
clear
global input "${data_raw}/aggregators/LUND/LUND.xlsx"
global output "${data_clean}/aggregators/LUND/LUND.dta"
* ==============================================================================
* PROCESS 
* ==============================================================================

* clear
clear

* Create temp file
tempfile temp_master
save `temp_master', replace emptyok

* ==============================================================================
* SHEET R1900
* ==============================================================================

* Open
import excel using "${input}", clear sheet("R1900")

* Drop 
drop in 1/8
qui missings dropobs, force
qui missings dropvars, force

* Rename
ren A year
drop B // Drop Austria-Hungary
ren K REERNetherlands
ren R REERSwitzerland
ren S REERGreatBritain
qui ds year REER*, not
foreach var in `r(varlist)'{
	local newname = `var'[1]
	ren `var' REER`newname'
}
drop in 1

* Reshape
greshape long REER, i(year) j(countryname) string

* Destring
destring year REER, replace

* Rename 
ren REER first_REER


* Sort 
sort countryname year 

* Append
append using `temp_master'
save `temp_master', replace

* ==============================================================================
* SHEET R1929
* ==============================================================================
import excel using "${input}", clear sheet("R1929")

* Drop 
drop in 1/8
qui missings dropobs, force
qui missings dropvars, force

* Rename
ren A year
ren E REERCzechoSlovakia
ren N REERNetherlands
ren U REERSwitzerland
ren V REERGreatBritain
qui ds year REER*, not
foreach var in `r(varlist)'{
	local newname = `var'[1]
	ren `var' REER`newname'
}
drop in 1

* Reshape
greshape long REER, i(year) j(countryname) string

* Destring
destring year REER, replace

* Rename 
ren REER second_REER

* Sort 
sort countryname year 

* Merge
merge 1:1 countryname year using `temp_master', nogen
save `temp_master', replace

* ==============================================================================
* SHEET R1969
* ==============================================================================
import excel using "${input}", clear sheet("R1960")

* Drop 
drop in 1/3
qui missings dropobs, force
qui missings dropvars, force

* Rename
ren A year
ren E REERCzechoSlovakia
ren I REERGermany
ren J REEREastGermany
ren O REERNetherlands
ren V REERSwitzerland
ren W REERGreatBritain
qui ds year REER*, not
foreach var in `r(varlist)'{
	local newname = `var'[1]
	ren `var' REER`newname'
}
drop in 1

* Reshape
greshape long REER, i(year) j(countryname) string

* Destring
destring year REER, replace

* Rename 
ren REER third_REER


* Sort 
sort countryname year 


* Merge
merge 1:1 countryname year using `temp_master', nogen
save `temp_master', replace

* ==============================================================================
* SHEET R1999
* ==============================================================================
import excel using "${input}", clear sheet("R1999")

* Drop 
drop in 1
qui missings dropobs, force
qui missings dropvars, force

* Rename
ren A year
ren Q REERNetherlands
ren X REERSwitzerland
ren Y REERGreatBritain
qui ds year REER*, not
foreach var in `r(varlist)'{
	local newname = `var'[1]
	ren `var' REER`newname'
}
drop in 1

* Reshape
greshape long REER, i(year) j(countryname) string

* Destring
destring year REER, replace

* Rename 
ren REER fourth_REER

* Sort 
sort countryname year 

* Merge
merge 1:1 countryname year using `temp_master', nogen
save `temp_master', replace

* Fix country names
replace countryname = "Czech Republic" if countryname == "Czechia"
replace countryname = "Czechoslovakia" if countryname == "CzechoSlovakia"
replace countryname = "Georgia" if countryname == "EastGermany"
replace countryname = "United Kingdom" if countryname == "GreatBritain"
replace countryname = "Russian Federation" if countryname == "Russia"

* Get country names
merge m:1 countryname using $isomapping, assert(2 3) nogen keepus(ISO3) keep(3)
drop countryname

* Sort 
sort ISO3 year 

* Splice 
splice, priority(fourth third second first) generate(REER) varname(REER) base_year(1999) method("chainlink")

* Keep 
keep ISO3 year REER 

* Rename
ren REER LUND_REER

* ==============================================================================
* Output
* ==============================================================================

* Order
order ISO3 year

* Sort
sort ISO3 year

* Check for duplicates
isid ISO3 year

* Save
save "${output}", replace




