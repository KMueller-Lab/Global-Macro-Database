* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* 
* Author:
* Mohamed Lehbib
* National University of Singapore
*
* Created: 2024-07-20
*
* Description: 
* This Stata script cleans economic data for countries that are 
* West and Central African Currency Union members.
*
* URL: https://www.banque-france.fr/fr/banque-de-france/partenariats-afrique-france#Sries-statistiques-17649 (archived on: 2024-11-27)
*
* ==============================================================================

* ==============================================================================
* 	SET UP
* ==============================================================================

clear
global input "${data_raw}/aggregators/FRANC_ZONE/FRANC_ZONE"
global output "${data_clean}/aggregators/FRANC_ZONE/FRANC_ZONE"

* ==============================================================================
* 	PROCESS
* ==============================================================================
* Open
use "${input}", clear

* Fix missing values
replace value = "" if value == "NA"

* Keep only relevant columns
keep period country series_code value

* Make series' codes shorter
replace series_code = substr(series_code, 1, strpos(series_code, ".")-1)

* Reshape
greshape wide value, i(country period) j(series_code)

* Destring
destring value*, replace

* Merge Comores data with other countries together
replace valuegdp_FCFA = valuegdp_KMF if country == "COM"
replace valuemoney_KMF = valuemoney_KMF if country == "COM"

* Drop Comores' columns
drop *KMF

* Rename
ren country ISO3
ren period year
ren value* *
ren price_index_percent infl
ren money_FCFA M2
ren investment inv_GDP
ren gdp_FCFA nGDP
ren budget_balance_percent govdef_GDP

* Convert units
replace nGDP = nGDP * 1000
replace M2       = M2   	* 1000

* Calculate investment and deficit total amount
gen inv = (inv_GDP * nGDP) / 100
gen govdef = (govdef_GDP * nGDP) / 100

* Add source identifier
qui ds ISO3 year, not
foreach var in `r(varlist)' {
	ren `var' FRANC_ZONE_`var'
}
* ==============================================================================
* 	OUTPUT
* ==============================================================================

* Sort
sort ISO3 year

* Order
order ISO3 year

* Check for duplciates
isid ISO3 year

* Save
save "${output}", replace
