* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* 
* Clean Interwar Macro Panel Dataset
* 
* Author:
* Mohamed Lehbib
* National University of Singapore
*
* Created: 2024-10-07
*
* URL: https://sites.google.com/site/tnhalbers/teaching?authuser=0#h.8o2u76nzlcwn
* ==============================================================================

* ==============================================================================
* 	SET UP 
* ==============================================================================
clear
global input "${data_raw}/aggregators/TH_ID/TH_ID.dta"
global output "${data_clean}/aggregators/TH_ID/TH_ID.dta"

* ==============================================================================
* 	PROCESS
* ==============================================================================

* Open
use "${input}", clear 

* Generate year
gen year = yofd(dofm(Time))

* Generate ISO3
ren country countryname
replace countryname = "United Kingdom" if countryname == "GreatBritain"
replace countryname = "United States"  if countryname == "UnitedStates"
replace countryname = "New Zealand"    if countryname == "NewZealand"
replace countryname = "South Africa"  if countryname == "SouthAfrica"

* Merge in ISO codes
merge m:1 countryname using $isomapping, assert(2 3) keepus(ISO3) keep(3) nogen

* Keep relevant columns
keep ISO3 year TOTEX TOTIM Time

* Take yearly value of imports and exports
sort ISO3 year Time
by ISO3 year: gen exports_s = sum(TOTEX)
by ISO3 year: gen imports_s = sum(TOTIM)
ren (imports_s exports_s) (imports exports)

* Keep total rows
gen month = mod(Time, 12)
keep if month == 11

* Drop columns 
drop TOTEX TOTIM month Time
drop if exports == 0 | imports == 0

* Add source identifier
qui ds year ISO3, not
foreach var in `r(varlist)'{
	ren `var' TH_ID_`var'
}

* Convert currency and units for Australia
replace TH_ID_exports = TH_ID_exports * 2 if ISO3 == "AUS"
replace TH_ID_imports = TH_ID_imports * 2 if ISO3 == "AUS"

replace TH_ID_exports = TH_ID_exports / 1000 if ISO3 == "AUS"
replace TH_ID_imports = TH_ID_imports / 1000 if ISO3 == "AUS"

* Convert currency for Bulgaria
replace TH_ID_exports = TH_ID_exports / 1000000 if ISO3 == "BGR"
replace TH_ID_imports = TH_ID_imports / 1000000 if ISO3 == "BGR"

* Convert currency for Chile
replace TH_ID_exports = TH_ID_exports / 1000 if ISO3 == "CHL"
replace TH_ID_imports = TH_ID_imports / 1000 if ISO3 == "CHL"

* Convert currency for Estonia
replace TH_ID_exports = TH_ID_exports / 1000 if ISO3 == "EST"
replace TH_ID_imports = TH_ID_imports / 1000 if ISO3 == "EST"

* Convert currency for Estonia
replace TH_ID_exports = TH_ID_exports / 1000 if ISO3 == "POL"
replace TH_ID_imports = TH_ID_imports / 1000 if ISO3 == "POL"

* Convert Finland currency
qui replace TH_ID_exports = TH_ID_exports / 100   if ISO3 == "FIN" 
qui replace TH_ID_imports = TH_ID_imports / 100   if ISO3 == "FIN" 

* Convert France currency
qui replace TH_ID_exports = TH_ID_exports / 100   if ISO3 == "FRA" 
qui replace TH_ID_imports = TH_ID_imports / 100   if ISO3 == "FRA" 

* Convert Mexico currency
qui replace TH_ID_exports = TH_ID_exports / 1000   if ISO3 == "MEX" 
qui replace TH_ID_imports = TH_ID_imports / 1000   if ISO3 == "MEX" 

* Convert Romania currency
qui replace TH_ID_exports = TH_ID_exports / 200000000   if ISO3 == "ROU" 
qui replace TH_ID_imports = TH_ID_imports / 200000000   if ISO3 == "ROU" 

* Convert currency and units for South Africa
replace TH_ID_exports = TH_ID_exports * 2 if ISO3 == "ZAF"
replace TH_ID_imports = TH_ID_imports * 2 if ISO3 == "ZAF"

replace TH_ID_exports = TH_ID_exports / 1000 if ISO3 == "ZAF"
replace TH_ID_imports = TH_ID_imports / 1000 if ISO3 == "ZAF"

* Drop values for Yuguslava
replace TH_ID_imports = . if ISO3 == "YUG"
replace TH_ID_exports = . if ISO3 == "YUG"

* Convert currency to euro
merge m:1 ISO3 using $eur_fx, keep(1 3)
qui ds TH_ID_imports TH_ID_exports
foreach var in `r(varlist)'{
	replace `var' = `var'/EUR_irrevocable_FX if _merge == 3
}
drop EUR_irrevocable_FX _merge

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
