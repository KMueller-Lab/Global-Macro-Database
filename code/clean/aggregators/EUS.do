* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* 
* Author:
* Mohamed Lehbib
* National University of Singapore
*
* Created: 2024-05-21
*
* Description: 
* This Stata script processes the raw Eurostat data.
*
* Data source:
* Eurostat.
* 
* ==============================================================================
*
* ==============================================================================
* 	SET UP
* ==============================================================================
* Define input and output files 
clear
global input "${data_raw}/aggregators/EUS/EUS"
global output "${data_clean}/aggregators/EUS/EUS.dta"

* ==============================================================================
* 	PROCESS
* ==============================================================================

* Open 
use "${input}", clear

* Drop regional aggregates 
drop if regexm(geo, "[0-9]|FX|EFTA|EA|EU|EL|DE_TOT")

* Rename datasets
gen series = ""
replace series_name = "REER" 			if dataset_name == "Real effective exchange rate – index, 42 trading partners"
replace series_name = "unemp" 			if dataset_name == "Unemployment rate - annual data"
replace series_name = "strate" 			if dataset_name == "Interest rates - monthly data"
replace series_name = "pop" 			if strpos(series_name, "Population on 1 January")
replace series_name = "govtax" 			if strpos(series_name, "Total receipts from taxes")
replace series_name = "govexp"   		if strpos(series_name, "government expenditure")
replace series_name = "govrev" 		if strpos(series_name, "government revenue")
replace series_name = "govdef_GDP" 		if strpos(series_name, "Net lending (+)/net borrowing (-)")
replace series_name = "HPI" 			if dataset_name == "House price index (2015 = 100) - quarterly data"
replace series_name = "exports" 		if strpos(series_name, "Exports of goods and services")
replace series_name = "imports" 		if strpos(series_name, "Imports of goods and services")
replace series_name = "finv" 			if strpos(series_name, "Gross fixed capital formation")
replace series_name = "inv" 			if strpos(series_name, "Gross capital formation")
replace series_name = "cons" 			if strpos(series_name, "Final consumption expenditure")
replace series_name = "nGDP" 		if strpos(series_name, "Current prices, million units of national currency – Gross domestic product at market prices")
replace series_name = "rGDP" 		if strpos(series_name, "Chain linked volumes (2010), million units of national currency – Gross domestic product at market prices")
replace series_name = "infl" 			if strpos(series_name, "Growth rate (t/t-12)")
replace series_name = "CPI" 			if strpos(series_name, "Monthly – Harmonized consumer price index, 2015=100")

* Extract the year
gen year = substr(period, 1, 4)
drop period

* Keep end-of-year observation for each variable
sort geo series_name year
by geo series_name year: keep if _n == _N

* Keep relevant variables
keep year geo value series_name

* Reshape
greshape wide value, i(year geo) j(series_name) string 
rename value* EUS_*

* Convert pop to million
replace EUS_pop = EUS_pop / 1000000

* Generate government finances in nominal values
gen EUS_govdef = (EUS_govdef_GDP * EUS_nGDP) / 100

* Rename
ren geo ISO2
destring year, replace

* Convert iso2 to iso3
replace ISO2 = "GB" if ISO2 == "UK"
merge m:1 ISO2 using ${isomapping}, nogen assert(2 3) keep(3) keepusing(ISO3)
drop ISO2 

* Remove 
ren * *

* Add ratios to gdp variables
gen EUS_cons_GDP    = (EUS_cons / EUS_nGDP) * 100
gen EUS_imports_GDP = (EUS_imports / EUS_nGDP) * 100
gen EUS_exports_GDP = (EUS_exports / EUS_nGDP) * 100
gen EUS_finv_GDP    = (EUS_finv / EUS_nGDP) * 100
gen EUS_inv_GDP     = (EUS_inv / EUS_nGDP) * 100
gen EUS_govrev_GDP = (EUS_govrev / EUS_nGDP) * 100
gen EUS_govexp_GDP = (EUS_govexp / EUS_nGDP) * 100
gen EUS_govtax_GDP = (EUS_govtax / EUS_nGDP) * 100

* ==============================================================================
* 	OUTPUT
* ==============================================================================
* Sort
sort ISO3 year

* Order
order ISO3 year 

* Check for duplicates
isid year ISO3 

* Save
save "${output}", replace
