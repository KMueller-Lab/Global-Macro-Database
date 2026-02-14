* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* 
* Author:
* Mohamed Lehbib
* National University of Singapore
*
* Created: 2025-09-20
*
* Description: 
* This stata script cleans data from the United Nations' National Accounts 
* Estimates of Main Aggregates, including some countries no longer in existence.
*
* Download URL: https://unstats.un.org/unsd/snaama/Downloads
* ==============================================================================

* ==============================================================================
* 	SET-UP
* ==============================================================================
* Clear panel
clear

* Define input and output files
global UN_nGDP "${data_raw}/aggregators/UN/nGDP"
global UN_rGDP "${data_raw}/aggregators/UN/rGDP"
global UN_rGDP_USD "${data_raw}/aggregators/UN/rGDP_USD"
global UN_USDfx "${data_raw}/aggregators/UN/USDfx"
global output "${data_clean}/aggregators/UN/UN.dta"
* ==============================================================================

* ==============================================================================
* 	NOMINAL GDP
* ==============================================================================
* Open
use "${UN_nGDP}" , clear 

* Drop empty rows 
drop in 1/2
drop C

* Make year variable 
qui ds A B D, not
foreach var in `r(varlist)' {
	local newname = `var'[1]
	ren `var' UN_`newname'
}
drop in 1 

* Reshape long 
greshape long UN_, i(A B D) j(year)

* Only keep broad national account variables 
keep if inlist(D,"Final consumption expenditure","Gross Domestic Product (GDP)","Gross capital formation","Gross fixed capital formation (including Acquisitions less disposals of valuables)","Imports of goods and services","Exports of goods and services")

* Rename variables 
replace D = "nGDP"			if D == "Gross Domestic Product (GDP)"
replace D = "cons"			if D == "Final consumption expenditure"
replace D = "inv"			if D == "Gross capital formation"
replace D = "finv"			if D == "Gross fixed capital formation (including Acquisitions less disposals of valuables)"
replace D = "imports"		if D == "Imports of goods and services"
replace D = "exports"		if D == "Exports of goods and services"

* Reshape
greshape wide UN_, i(A B year) j(D)
ren UN_* *

* Make ISO3 code
ren B countryname
ren A ISOnum
destring ISOnum, replace 
merge m:1 ISOnum using $isomapping, keep(3) keepus(ISO3) nogen
drop ISOnum countryname

* Convert to millions
qui ds year ISO3, not
foreach var in `r(varlist)'{
	replace `var' = `var' / 1000000
}

* Add ratios to gdp variables
gen cons_GDP = (cons / nGDP) * 100
gen imports_GDP = (imports / nGDP) * 100
gen exports_GDP = (exports / nGDP) * 100
gen finv_GDP    = (finv / nGDP) * 100
gen inv_GDP     = (inv / nGDP) * 100

* Add source identifier
qui ds ISO3 year, not
foreach var in `r(varlist)' {
	ren `var' UN_`var'
}

* Save
tempfile temp_master
save `temp_master', replace

* ==============================================================================
* 	REAL GDP
* ==============================================================================
use "${UN_rGDP}" , clear

* Drop empty rows 
drop in 1/2
drop C

* Make year variable 
qui ds A B D, not
foreach var in `r(varlist)' {
	local newname = `var'[1]
	ren `var' UN_`newname'
}
drop in 1

* Reshape long 
greshape long UN_, i(A B D) j(year)


* Keep relevant vars
replace D = "rGDP"		if D == "Gross Domestic Product (GDP)"
drop if !inlist(D, "rGDP")

* Reshape
greshape wide UN_, i(A B year) j(D)

* Make ISO3 code
ren B countryname
ren A ISOnum
destring ISOnum, replace force
drop if ISOnum == .
merge m:1 ISOnum using $isomapping, keep(3) keepus(ISO3) nogen
drop ISOnum countryname

* Keep 
keep ISO3 year UN_rGDP

* Convert to millions
replace UN_rGDP  = UN_rGDP / (10^6) if ISO3 != "VEN"

* Merge
merge 1:1 ISO3 year using `temp_master', nogen
save `temp_master', replace


* ==============================================================================
* 	REAL GDP in USD
* ==============================================================================
use "${UN_rGDP_USD}" , clear

* Drop empty rows 
drop in 1/2

* Make year variable 
qui ds A B C, not
foreach var in `r(varlist)' {
	local newname = `var'[1]
	ren `var' UN_`newname'
}
drop in 1

* Keep relevant vars
replace C = "rGDP_USD"		if C == "Gross Domestic Product (GDP)"
drop if !inlist(C, "rGDP_USD")


* Reshape long 
greshape long UN_, i(A B C) j(year)

* Reshape
greshape wide UN_, i(A B year) j(C)

* Make ISO3 code
ren B countryname
ren A ISOnum
destring ISOnum, replace force
drop if ISOnum == .
merge m:1 ISOnum using $isomapping, keep(3) keepus(ISO3) nogen
drop ISOnum countryname

* Keep 
keep ISO3 year UN_rGDP_USD

* Convert to millions
replace UN_rGDP_USD  = UN_rGDP_USD / (10^6) if ISO3 != "VEN"

* Merge
merge 1:1 ISO3 year using `temp_master', nogen
save `temp_master', replace

* ==============================================================================
* 	Population
* ==============================================================================
use "${UN_USDfx}" , clear

* Drop empty rows 
drop in 1/2
drop C

* Make year variable 
qui ds A B D, not
foreach var in `r(varlist)' {
	local newname = `var'[1]
	ren `var' UN_`newname'
}
drop in 1 


* Reshape long 
greshape long UN_, i(A B D) j(year)


* Keep relevant vars
replace D = "USDfx"		if D == "IMF based exchange rate"
replace D = "pop"		if D == "Population"
keep if inlist(D, "pop", "USDfx")

* Reshape
greshape wide UN_, i(A B year) j(D)

* Make ISO3 code
ren B countryname
ren A ISOnum
destring ISOnum, replace force
drop if ISOnum == .
merge m:1 ISOnum using $isomapping, keep(3) keepus(ISO3) nogen
drop ISOnum countryname

* Convert to millions
replace UN_pop = UN_pop / (10^6)

* Merge
merge 1:1 ISO3 year using `temp_master', nogen

* Czechoslovakia has some trade values that negative
replace UN_exports = abs(UN_exports) if ISO3 == "CSK"
replace UN_exports_GDP = abs(UN_exports_GDP) if ISO3 == "CSK"

* Add the deflator
gen UN_deflator = (UN_nGDP / UN_rGDP) * 100

* Rebase variables to $base_year
gmd_rebase UN

* Check for ratios and levels 
check_gdp_ratios UN

* ==============================================================================
* 	OUTPUT
* ==============================================================================
* Sort
sort ISO3 year

* Order 
order ISO3 year

* Check for duplicates
isid ISO3 year

* Output
save "${output}", replace
