* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* 
* Description: 
* This Stata script reads in and clean data for Indonesia
*
* Author:
* Ziliang Chen
* National University of Singapore

* ==============================================================================

* ==============================================================================
* 	SET UP 
* ==============================================================================
* Clear
clear
global input "${data_raw}/country_level/IDN_1"
global output "${data_clean}/country_level/IDN_1"

* ===============================================================================
*	PROCESS
* ===============================================================================

* Open
use $input, clear

keep period value dataset_code series_name series_code REF_AREA

replace dataset_code = "M2" if dataset_code == "TABEL1_1" & series_code == "1.A"
replace dataset_code = "M1" if dataset_code == "TABEL1_1" & series_code == "2.A"
replace dataset_code = "M0" if dataset_code == "TABEL1_2" & series_code == "1.A"
replace dataset_code = "govrev" if dataset_code == "TABEL4_1" & series_code == "2.A"
replace dataset_code = "govexp" if dataset_code == "TABEL4_2" & series_code == "2.A"
replace dataset_code = "govdef" if dataset_code == "TABEL4_3" & series_code == "2.A"
replace dataset_code = "govdebt" if dataset_code == "TABEL4_4" & series_code == "2.A"
replace dataset_code = "CA" if dataset_code == "TABEL5_1" & series_code == "1.A"
replace dataset_code = "USDfx" if dataset_code == "TABEL5_40" & series_code == "10.A"
replace dataset_code = "finv" if dataset_code == "TABEL7_3" & series_code == "5.A"
replace dataset_code = "exports_goods" if dataset_code == "TABEL7_3" & series_code == "8.A"
replace dataset_code = "exports_services" if dataset_code == "TABEL7_3" & series_code == "9.A"
replace dataset_code = "nGDP" if dataset_code == "TABEL7_1" & series_code == "64.A"
replace dataset_code = "imports_goods" if dataset_code == "TABEL7_3" & series_code == "10.A"
replace dataset_code = "imports_services" if dataset_code == "TABEL7_3" & series_code == "11.A"
replace dataset_code = "CPI" if dataset_code == "TABEL8_1" & series_code == "23.A"

* Rename
ren period year
ren REF_AREA ISO3

* destring
replace value = "" if value == "NA"
destring year value, replace

* Drop
drop series_name series_code
* Drop all unused observations
drop if strpos(dataset_code, "TABEL") > 0

* Reshape
greshape wide value, i(ISO3 year) j(dataset_code)
ren value* *

* Combine good and services for exports and imports_good
gen exports = exports_goods + exports_services
gen imports = imports_goods + imports_services

drop imports_goods exports_goods exports_services imports_goods imports_services 

* Convert units
ds M0 M1 M2 exports imports govrev govexp govdef govdebt nGDP finv 
foreach var in `r(varlist)'{
	replace `var' = `var' * 1000
}

* Add ratios to gdp variables
gen imports_GDP = (imports / nGDP) * 100
gen exports_GDP = (exports / nGDP) * 100
gen finv_GDP    = (finv / nGDP) * 100
gen govdef_GDP  = (govdef/nGDP) * 100
gen govdebt_GDP = (govdebt/nGDP) * 100
gen CA_GDP      = (CA/nGDP) * 100
gen govrev_GDP = (govrev/nGDP) * 100
gen govexp_GDP = (govexp/nGDP) * 100

* Add source identifier
qui ds ISO3 year, not
foreach var in `r(varlist)' {
	ren `var' CS1_`var'
}

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
