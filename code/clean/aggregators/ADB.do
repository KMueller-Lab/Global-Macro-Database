* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* 
* Description: 
* This Stata script reads in and cleans data from the Asian Development Bank
*
* Author:
* Mohamed Lehbib
* National University of Singapore
*
* Created: 2024-10-14
*
* URL: https://kidb.adb.org/
* ==============================================================================

* ==============================================================================
* 	SET UP 
* ==============================================================================
clear
global input1 "${data_raw}/aggregators/ADB/ADB_pop"
global input2 "${data_raw}/aggregators/ADB/ADB_CPI"
global input3 "${data_raw}/aggregators/ADB/ADB_macro"
global input4 "${data_raw}/aggregators/ADB/ADB_gov"
global output "${data_clean}/aggregators/ADB/ADB.dta"

* ===============================================================================
*	PROCESS
* ===============================================================================

* Open
import excel using "${input1}", clear allstring

* Rename rows
replace A = "pop"   if A == "Total population"
replace A = "unemp" if A == "Unemployment rate"

* Rename columns
ren A code
ren B countryname
drop C 

qui ds code countryname, not
foreach var in `r(varlist)'{
	local newname = `var'[1]
	ren `var' ADB_`newname'
}
drop in 1

* Reshape
greshape long ADB_, i(code countryname) j(year) string
greshape wide ADB_, i(countryname year) j(code) string

* Destring
destring year ADB*, replace force

* Convert units
qui replace ADB_pop = ADB_pop / 1000000

* Save
tempfile temp_master
save `temp_master', replace emptyok

********************************************************************************

* Open
import excel using "${input2}", clear allstring

* Drop 
drop if C == ""
drop A C

* Rename columns
ren B countryname

qui ds countryname, not
foreach var in `r(varlist)'{
	local newname = `var'[1]
	ren `var' ADB_CPI`newname'
}
drop in 1

* Reshape
greshape long ADB_CPI, i(countryname) j(year) string

* Destring
qui replace ADB_CPI   = subinstr(ADB_CPI,   "...", "", .)
destring year ADB*, replace

* Save and merge
merge 1:1 countryname year using `temp_master', nogen
save `temp_master', replace

********************************************************************************

* Open
import excel using "${input4}", clear allstring

* Rename rows
drop if C == ""
replace A = "govrev_GDP"   if A == "Government Revenue (% of GDP)"
replace A = "govdef_GDP"   if A == "Government Net Lending/Net Borrowing (% of GDP)"
replace A = "govtax_GDP"   if A == "Government Taxes (% of GDP)"
replace A = "govexp_GDP"   if A == "Government Expenditure (% of GDP)"

* Rename columns
ren A code
ren B countryname
drop C 

qui ds code countryname, not
foreach var in `r(varlist)'{
	local newname = `var'[1]
	ren `var' ADB_`newname'
}
drop in 1

* Reshape
greshape long ADB_, i(code countryname) j(year) string
greshape wide ADB_, i(countryname year) j(code) string

* Destring
qui ds ADB*
foreach var in `r(varlist)'{
	qui replace `var' = subinstr(`var', "...", "", .)
}
destring year ADB*, replace

* Save and merge
merge 1:1 countryname year using `temp_master', nogen
save `temp_master', replace

********************************************************************************

* Open
import excel using "${input3}", clear allstring

* Rename rows
drop if inlist(C, "US Dollar", "")
drop if inlist(A, "Demand deposits (excluding government deposits)", "Overall balance")
replace A = "strate"    if A == "Yield on Short-Term Treasury Bills (% per annum, period averages)"
replace A = "imports"   if A == "External trade—Imports, cif"
replace A = "exports"   if A == "External trade—Exports, fob"
replace A = "M1"   		if A == "Money supply (M1)"
replace A = "CA_GDP"    if A == "BOP—Overall balance (% of GDP)"
replace A = "rGDP"  	if A == "GDP at constant prices"
replace A = "USDfx"     if A == "Average of period"
replace A = "sav"   	if A == "Gross domestic saving at current prices"
replace A = "M0"   		if A == "Currency in circulation"
replace A = "infl"   	if A == "CPI (national)—Food and nonalcoholic beverages price index (% annual change)"
replace A = "inv"   	if A == "Gross capital formation at current prices"
replace A = "M2"   		if A == "Money supply (M2)" & C != "percent"
replace A = "nGDP"  	if A == "GDP at current prices"
replace A = "M3"   		if A == "Money supply (M3)"
replace A = "M4"   		if A == "Money supply (M4)"
drop if A == "Money supply (M2)" // Only percentage, no values

* Rename columns
ren A code
ren B countryname
drop C 

qui ds code countryname, not
foreach var in `r(varlist)'{
	local newname = `var'[1]
	ren `var' ADB_`newname'
}
drop in 1

* Reshape
greshape long ADB_, i(code countryname) j(year) string
greshape wide ADB_, i(countryname year) j(code) string

* Destring
qui ds ADB*
foreach var in `r(varlist)'{
	qui replace `var' = subinstr(`var', "...", "", .)
}
destring year ADB*, replace

* Convert units
qui ds ADB_M* ADB_exports ADB_imports ADB_inv ADB_nGDP ADB_rGDP ADB_sav
foreach var in `r(varlist)'{
	qui replace `var' = `var' / 1000000
}

* Save and merge
merge 1:1 countryname year using `temp_master', nogen
save `temp_master', replace

********************************************************************************
* Deduce government finance in nominal values
gen ADB_govexp = (ADB_govexp_GDP * ADB_nGDP) / 100
gen ADB_govrev = (ADB_govrev_GDP * ADB_nGDP) / 100
gen ADB_govdef = (ADB_govdef_GDP * ADB_nGDP) / 100
gen ADB_govtax = (ADB_govtax_GDP * ADB_nGDP) / 100

* Extract ISO3 
replace countryname = "Brunei"		if countryname == "Brunei Darussalam"
replace countryname = "China" 		if countryname == "China, People's Republic of"
replace countryname = "Hong Kong"   if countryname == "Hong Kong, China"
replace countryname = "South Korea" if countryname == "Korea, Republic of"
replace countryname = "Kyrgyzstan"  if countryname == "Kyrgyz Republic"
replace countryname = "Laos" 		if countryname == "Lao People's Democratic Republic"
replace countryname = "Taiwan" 		if countryname == "Taipei,China"
replace countryname = "Vietnam" 	if countryname == "Viet Nam"
replace countryname = "Micronesia (Federated States of)"  if countryname == "Micronesia, Federated States of"
merge m:1 countryname using $isomapping, assert(2 3) keep(3) keepusing(ISO3) nogen
drop countryname

* Fix units for China and Hong Kong in 2020
replace ADB_M2 = ADB_M2 * (10^9) if ISO3 == "CHN" & year == 2020 & ADB_M2 < 1
replace ADB_M2 = ADB_M2 * (10^9) if ISO3 == "HKG" & year == 2020 & ADB_M2 < 1
replace ADB_govtax = . if ISO3 == "TUV"

* Fix units for Real GDP for Myanmar in 2000
replace ADB_rGDP = ADB_rGDP * 10 if ISO3 == "MMR" & year == 2000

* Remove zero values
ds ISO3 year, not
foreach var in `r(varlist)'{
	replace `var' = . if `var' == 0
}


* Add ratios to gdp variables
gen ADB_imports_GDP = (ADB_imports / ADB_nGDP) * 100
gen ADB_exports_GDP = (ADB_exports / ADB_nGDP) * 100
gen ADB_inv_GDP     = (ADB_inv / ADB_nGDP) * 100

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
