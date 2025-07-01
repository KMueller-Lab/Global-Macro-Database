* ==============================================================================
* GLOBAL CREDIT DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* 
* Description: 
* This Stata script reads in and clean data for ITASTAT
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
global input "${data_raw}/country_level/ITA_3"
global output "${data_clean}/country_level/ITA_3"

* ==============================================================================
*	POP
* ==============================================================================

* Open
use "$input", clear

* Destring variables
replace value = "" if value == "NA"
destring period value, replace

gen indicator = "" 
replace indicator = "nGDP" if series_code == "A.IT.B1GQ_B_W2_S1_X2.V.N.2024M9"
replace indicator = "rGDP" if series_code == "A.IT.B1GQ_B_W2_S1.L_2020.N.2024M9"
replace indicator = "exports" if series_code == "A.IT.P6_C_W1_S1.V.N.2024M9"
replace indicator = "imports" if series_code == "A.IT.P7_D_W1_S1.V.N.2024M9"
replace indicator = "cons" if series_code == "A.IT.P3_D_W0_S1.V.N.2024M9"
replace indicator = "finv" if series_code == "A.IT.P51G_D_W0_S1.V.N.2024M9"
replace indicator = "inv" if series_code == "A.IT.P5_D_W0_S1.V.N.2024M9"
drop if indicator == ""

* Keep 
keep period value indicator

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
	ren `var' CS3_`var'
}

* Add ISO3 
gen ISO3 = "ITA"

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
