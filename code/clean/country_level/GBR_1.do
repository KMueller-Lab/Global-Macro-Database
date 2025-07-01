* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* CLEAN DATA FROM BANK OF ENGLAND
* 
* Description: 
* This Stata script reads in and cleans data from the Bank of England: A millennium of macroeconomic data for the UK
*
* Author:
* Mohamed Lehbib
* National University of Singapore
*
* Created: 2024-09-26
*
* Source: Bank of England 
* ==============================================================================
* 	SET UP 
* ==============================================================================

* Clear the panel
clear 

* Define input and output files 
global input "${data_raw}/country_level/GBR_1.xlsx"
global output "${data_clean}/country_level/GBR_1"

* ==============================================================================
* 	PROCESS
* ==============================================================================

* Open
import excel using "${input}", clear sheet("A1. Headline series") cellrange(A8:CE938)

* Keep relevant variables
keep A B H V W Y AB AO AP AS AT AU BA BE BL BM BN BX CB CC T U

* Rename
ren (A B H V W Y AB AO AP AS AT AU BA BE BL BM BN BX CB CC T U) (year rGDP rGDP_ENG nGDP_ENG nGDP pop unemp CPI infl cbrate strate ltrate USDfx HPI M0 M1 M2 govdebt CA CA_GDP exports imports)

* Add ISO3 code
gen ISO3 = "GBR"

* Extend the United Kingdom nominal GDP series using nominal GDP data for England
qui su nGDP_ENG if year == 1700, meanonly
local nGDP_1 = r(mean)
qui su nGDP if year == 1700, meanonly
local nGDP_2 = r(mean)

* Calculate the ratio and multiply the GDP values in England before 1700
local ratio = `nGDP_2' / `nGDP_1'
qui replace nGDP = nGDP_ENG * `ratio' if year <= 1699
drop nGDP_ENG

* Extend the United Kingdom real GDP series using real GDP data for England
qui su rGDP_ENG if year == 1700, meanonly
local rGDP_1 = r(mean)
qui su rGDP if year == 1700, meanonly
local rGDP_2 = r(mean)

* Calculate the ratio and multiply the real GDP values in England before 1700
local ratio = `rGDP_2' / `rGDP_1'
qui replace rGDP = rGDP_ENG * `ratio' if year <= 1699
drop rGDP_ENG

* Calculate the deflator
gen deflator = nGDP / rGDP

* Rebase the GDP to 2010
qui gen  temp = deflator if year == 2010 
qui egen defl_2010 = max(temp) 
qui replace rGDP = (rGDP * defl_2010) / 100 
qui drop temp defl_2010	

* Update the deflator
replace deflator = (nGDP / rGDP) * 100

* Save temporarily
tempfile temp_c
save `temp_c', replace

* Import the trade prices deflators in order to derive trade nominal values
import excel using "${input}", clear sheet("A35. Trade volumes and prices")

* Keep relevant columns
keep A V Z
drop in 1/5
drop in 738/l
ren (A V Z) (year exports_deflator imports_deflator)

* Destring
destring *, replace

* Merge 
merge 1:1 year using `temp_c', nogen
save `temp_c', replace

* Extend the trade price deflators using GDP deflator
qui su deflator if year == 1772, meanonly
local deflator_1 = r(mean)
qui su exports_deflator if year == 1772, meanonly
local deflator_2 = r(mean)
qui su exports_deflator if year == 1772, meanonly
local deflator_3 = r(mean)

* Calculate the ratio and multiply the price deflator deflators
local ratio = `deflator_2' / `deflator_1'
qui replace exports_deflator = deflator * `ratio' if year <= 1772
qui replace exports = exports * exports_deflator
local ratio = `deflator_3' / `deflator_1'
qui replace imports_deflator = deflator * `ratio' if year <= 1772
qui replace imports = imports * imports_deflator

* Drop
drop exports_deflator imports_deflator

* Merge 
merge 1:1 year using `temp_c', nogen
save `temp_c', replace

* Add Government debt data
import excel using "${input}", clear sheet("A27. Central govt borrowing ")

* keep relevant columns
keep AR AT AU AW AX AY
keep in 12/340
ren (AR AT AU AW AX AY) (year govexp govexp_GDP govrev govrev_GDP govdef)

* Destring
destring *, replace

* Merge 
merge 1:1 year using `temp_c', nogen
save `temp_c', replace

* Add ratios to gdp variables
gen imports_GDP = (imports / nGDP) * 100
gen exports_GDP = (exports / nGDP) * 100
gen govdef_GDP  = (govdef  / nGDP) * 100

* Add source identifier
qui ds ISO3 year, not
foreach var in `r(varlist)'{
	qui ren `var' CS1_`var'
}
keep ISO3 year CS1* 

* Convert units
replace CS1_pop = CS1_pop / 1000
replace CS1_USDfx = 1/CS1_USDfx

* Drop 
drop CS1_exports_deflator  CS1_imports_deflator 

* ==============================================================================
* 	OUTPUT
* ==============================================================================
* Sort
sort ISO3 year

* Order
order ISO3 year

* Check for duplicates
isid ISO3 year

* Save
save "${output}", replace
