* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* 
* Author:
* Mohamed Lehbib
* National University of Singapore
*
* Created: 2022-09-26
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
global UN_nGDP "${data_raw}/aggregators/UN/UN_nGDP.xlsx"
global UN_rGDP "${data_raw}/aggregators/UN/UN_rGDP.xlsx"
global UN_pop "${data_raw}/aggregators/UN/UN_pop.xlsx"
global output "${data_clean}/aggregators/UN/UN.dta"
* ==============================================================================

* ==============================================================================
* 	NOMINAL GDP
* ==============================================================================
* Open
import excel using "${UN_nGDP}" , clear 

* Drop empty rows 
drop in 1/3

* Make year variable 
local year = 1970
foreach var of varlist E-BC {
	ren `var' y_`year'
	loc year = `year' + 1
}

* Reshape long 
greshape long y_, i(A B C D) j(year)

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
greshape wide y_, i(A B C year) j(D)
ren y_* *

* Make ISO3 code
destring A, replace
kountry A, from(iso3n) to(iso3c)
ren _ISO3C_ iso3

* Fixing codes for Yugoslavia (Former) and USSR (Former)
replace iso3="SUN" if B=="USSR (Former)"
replace iso3="YUG" if B=="Yugoslavia (Former)"

* Combine modern and former Ethiopia
qui ds A B C year iso3, not
foreach var in `r(varlist)' {
	gen temp = `var' if B == "Ethiopia (Former)"
	bysort year: egen temp2 = max(temp)
	replace `var' = temp2 if B == "Ethiopia" & `var' == .
	drop temp temp2
}
drop if B == "Ethiopia (Former)"

* Combine modern and former Sudan
qui ds A B C year iso3, not
foreach var in `r(varlist)' {
	gen temp = `var' if B == "Sudan"
	bysort year: egen temp2 = max(temp)
	replace `var' = temp2 if B == "Sudan (Former)" & `var' == .
	drop temp temp2
}
drop if B == "Sudan"

* Fix missing country codes 
replace iso3 = "CUW"	if B == "Curaçao"
replace iso3 = "CSK"	if B == "Czechoslovakia (Former)"
replace iso3 = "XKX" 	if B == "Kosovo"
replace iso3 = "RUS"	if B == "Russian Federation"
replace iso3 = "SRB"	if B == "Serbia"
replace iso3 = "SXM"	if B == "Sint Maarten (Dutch part)"
replace iso3 = "TZA"	if B == "U.R. of Tanzania: Mainland"

* Drop some countries 
drop if B == "Zanzibar" 					// Zanzibar island 
drop if B == "Yemen Arab Republic (Former)"	// Former Yemen
drop if B == "Yemen Democratic (Former)"	// Former Yemen

* Analyzing missing countries. 
tab A if iso3==""
tab B if iso3==""
drop if B=="Montenegro"
drop if B=="South Sudan"

* Drop
drop A B C 

* Rename
ren iso3 ISO3

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
import excel using "${UN_rGDP}" , clear cellrange(A3:BC3560) 

* Drop empty rows 
drop in 1/3

* Make year variable 
local year = 1970
foreach var of varlist E-BC {
	ren `var' y_`year'
	loc year = `year' + 1
}

* Reshape long 
greshape long y_, i(A B C D) j(year)


* Keep relevant vars
replace D = "rGDP"		if D == "Gross Domestic Product (GDP)"
replace D = "rcons"			if D == "Final consumption expenditure"
drop if !inlist(D, "rGDP", "rcons")

* Reshape
greshape wide y_, i(A B C year) j(D)

* Rename
ren y_* *

* Make ISO3 code
ren B countryname
ren A ISOnum
destring ISOnum, replace force
drop if ISOnum == .
merge m:1 ISOnum using $isomapping, keep(3) keepus(ISO3) nogen

* Keep 
ren rGDP  UN_rGDP
ren rcons UN_rcons
keep ISO3 year UN_rGDP UN_rcons

* Convert to millions
replace UN_rGDP  = UN_rGDP / (10^6)
replace UN_rcons = UN_rcons / (10^6)

* Merge
merge 1:1 ISO3 year using `temp_master', nogen
save `temp_master', replace

* ==============================================================================
* 	Population
* ==============================================================================
import excel using "${UN_pop}" , clear cellrange(A17:BZ306) 

* Keep only countries
keep if F == "Country/Area" | F == "Type"

* Keep relevant columns
drop A B D F G 

* Reshape
qui ds C E, not
foreach var in `r(varlist)'{
	local newname = `var'[1]
	ren `var' UN_pop`newname'
}
qui greshape long UN_pop, i(C E) j(year) 

* Make ISO3 code
ren C countryname
ren E ISOnum
destring ISOnum UN_pop, replace force
drop if ISOnum == .
merge m:1 ISOnum using $isomapping, keep(3) keepus(ISO3) nogen

* Keep 
keep ISO3 year UN_pop

* Convert to millions
replace UN_pop = UN_pop / (10^3)

* Merge
merge 1:1 ISO3 year using `temp_master', nogen

* Convert Croatia's values to Euro
qui ds ISO3 year UN_pop *_GDP, not
foreach var in `r(varlist)'{
	replace `var' = `var' / 7.5345 if ISO3 == "HRV"
}

* Czechoslovakia has some trade values that negative
replace UN_exports = abs(UN_exports) if ISO3 == "CSK"
replace UN_exports_GDP = abs(UN_exports_GDP) if ISO3 == "CSK"

* Add the deflator
gen UN_deflator = (UN_nGDP / UN_rGDP) * 100

* Rebase the GDP to 2010
* Loop over all countries
qui levelsof ISO3, local(countries) clean
foreach country of local countries {
	
	* Rebase to 2010
	qui gen  temp = UN_deflator if year == 2010 & ISO3 == "`country'"
	qui egen defl_2010 = max(temp) if ISO3 == "`country'"
	qui replace UN_rGDP = (UN_rGDP * defl_2010) / 100 if ISO3 == "`country'"
	qui drop temp defl_2010	
}

* Update the deflator
replace UN_deflator = (UN_nGDP / UN_rGDP) * 100

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
