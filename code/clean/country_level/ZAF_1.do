* ==============================================================================
* GLOBAL CREDIT DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* 
* Description: 
* This Stata script reads in and clean data for ZAFdi Arabia
*
* Author:
* Mohamed Lehbib
* National University of Singapore
*
* Created: 2024-11-05
*
* ==============================================================================

* ==============================================================================
* 	SET UP 
* ==============================================================================
* Clear
clear
global input "${data_raw}/country_level/ZAF_1"
global output "${data_clean}/country_level/ZAF_1"

* ==============================================================================
*	PROCESS
* ==============================================================================

* Open
use "$input", clear

* Extract indicators
gen indicator = "" 
replace indicator = "strate" if series_code == "KBP2000J" 
replace indicator = "ltrate" if series_code == "KBP2003J" 
replace indicator = "govdef_GDP" if series_code == "KBP4420F" 
replace indicator = "govtax" if series_code == "KBP4595J" 
replace indicator = "govrev" if series_code == "KBP4597J" 
replace indicator = "govexp" if series_code == "KBP4601J" 
replace indicator = "nGDP" if series_code == "KBP6006J" 
replace indicator = "rGDP" if series_code == "KBP6006Y" 
replace indicator = "finv" if series_code == "KBP6009J" 
replace indicator = "inv" if series_code == "KBP6180J" 
replace indicator = "exports" if series_code == "KBP6013J" 
replace indicator = "imports" if series_code == "KBP6014J" 
replace indicator = "cons" if series_code == "KBP6620J" 
replace indicator = "M1" if series_code == "KBP1371J" 
replace indicator = "M2" if series_code == "KBP1373J" 
replace indicator = "M3" if series_code == "KBP1374J" 
replace indicator = "M0" if series_code == "KBP1000J" 
drop if indicator == ""

* Keep 
keep period value indicator

* Destring
destring value, force replace

* Reshape 
greshape wide value, i(period) j(indicator)
ren value* *
ren period year

* Add ratios to gdp variables
gen cons_GDP    = (cons / nGDP) * 100
gen imports_GDP = (imports / nGDP) * 100
gen exports_GDP = (exports / nGDP) * 100
gen finv_GDP    = (finv / nGDP) * 100
gen inv_GDP     = (inv / nGDP) * 100
gen govrev_GDP = (govrev / nGDP) * 100
gen govexp_GDP = (govexp / nGDP) * 100
gen govtax_GDP = (govtax / nGDP) * 100

* Add the deflator
gen deflator = (nGDP / rGDP) * 100

* Rebase the GDP to 2010
qui gen  temp = deflator if year == 2010 
qui egen defl_2010 = max(temp) 
qui replace rGDP = (rGDP * defl_2010) / 100 
qui drop temp defl_2010	

* Update the deflator
replace deflator = (nGDP / rGDP) * 100

* Add source identifier
qui ds year, not
foreach var in `r(varlist)'{
	ren `var' CS1_`var'
}

* Add ISO3 
gen ISO3 = "ZAF"

* ==============================================================================
* 	Output
* ==============================================================================

* Order
order ISO3 year

* Sort
sort ISO3 year

* Check for duplicates
isid ISO3 year

* Save
save "${output}", replace
