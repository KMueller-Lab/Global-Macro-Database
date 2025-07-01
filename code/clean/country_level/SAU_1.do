* ==============================================================================
* GLOBAL CREDIT DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* 
* Description: 
* This Stata script reads in and clean data for Saudi Arabia
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
global input "${data_raw}/country_level/SAU_1"
global output "${data_clean}/country_level/SAU_1"

* ==============================================================================
*	POP
* ==============================================================================

* Open
use "$input", clear

* Extract indicators
gen indicator = "" 
replace indicator = "nGDP" if series_code == "expenditure-on-gross-domestic-product" & dataset_name == "Expenditure on Gross Domestic Product (at purchasers' values at current prices) (million riyals)"
replace indicator = "exports" if series_code == "exports-of-goods-services" & dataset_name == "Expenditure on Gross Domestic Product (at purchasers' values at current prices) (million riyals)" 
replace indicator = "imports" if series_code == "imports-of-goods-services" & dataset_name == "Expenditure on Gross Domestic Product (at purchasers' values at current prices) (million riyals)"
replace indicator = "cons" if series_code == "total-final-consumption-expenditure" & dataset_name == "Expenditure on Gross Domestic Product (at purchasers' values at current prices) (million riyals)"
replace indicator = "finv" if series_code == "gross-fixed-capital-formation" & dataset_name == "Expenditure on Gross Domestic Product (at purchasers' values at current prices) (million riyals)"
replace indicator = "inv_1" if series_code == "change-in-stock" & dataset_name == "Expenditure on Gross Domestic Product (at purchasers' values at current prices) (million riyals)"
replace indicator = "rGDP" if series_code == "expenditure-on-gross-domestic-product" & dataset_name == "Expenditure on Gross Domestic Product (at purchasers' values at constant prices (2010 = 100)) (million riyals)"
drop if indicator == ""

* Keep 
keep period value indicator

* Destring
destring value, force replace

* Reshape 
greshape wide value, i(period) j(indicator)
ren value* *
ren period year

* Compute total investment
gen inv = inv_1 + finv
drop inv_1 

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
	ren `var' CS1_`var'
}

* Add ISO3 
gen ISO3 = "SAU"

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
