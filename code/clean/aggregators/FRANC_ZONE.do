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
* NOTE: This data was donwloaded using DBnomics code that is attached to the bottom of the file. 
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

* Drop empty obs 
drop if period == .

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
ren budget_balance_percent cgovdef_GDP

* Convert units
replace nGDP = nGDP * 1000
replace M2       = M2   	* 1000

* Calculate investment and deficit total amount
gen inv = (inv_GDP * nGDP) / 100
gen cgovdef = (cgovdef_GDP * nGDP) / 100

* Add source identifier
qui ds ISO3 year, not
foreach var in `r(varlist)' {
	ren `var' FRANC_ZONE_`var'
}

* Check for ratios and levels 
* Rebase variables to $base_year
gmd_rebase FRANC_ZONE

check_gdp_ratios FRANC_ZONE

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



/*

clear
global output "${data_raw}\aggregators\FRANC_ZONE\FRANC_ZONE"

* Run the master file
do "code/0_master.do"

cap {



* Create a temporary file where to save the datasets.
tempfile temp_master
save `temp_master', replace emptyok

* ==============================================================================
* 				NOMINAL GROSS DOMESTIC PRODUCT
* ==============================================================================

* Download and save
dbnomics import, pr(Franc-zone) d(FRANCZONE) indicator(gdp_FCFA) clear

* Save
append using `temp_master'
save `temp_master', replace

* ==============================================================================
* 				NOMINAL GROSS DOMESTIC PRODUCT FOR COMORES
* ==============================================================================

* Download and save
cap dbnomics import, pr(Franc-zone) d(FRANCZONE) indicator(gdp_KMF) clear

* Resize variables
qui ds, has(type string)
foreach var in `r(varlist)' {
	qui replace `var' = strtrim(`var')
	qui gen length = strlen(`var')
	qui su length
	qui recast str`r(max)' `var', force
	qui drop length
}

* Destring
destring period, replace

* Save
append using `temp_master'
save `temp_master', replace

* ==============================================================================
* 				INVESTMENTS
* ==============================================================================
* Download and save
dbnomics import, pr(Franc-zone) d(FRANCZONE) indicator(investment) clear

* Save
append using `temp_master'
save `temp_master', replace

* ==============================================================================
* 				BROAD MONEY (M2)
* ==============================================================================
* Download and save
dbnomics import, pr(Franc-zone) d(FRANCZONE) indicator(money_FCFA) clear

* Save
append using `temp_master'
save `temp_master', replace

* ==============================================================================
* 				BROAD MONEY (M2) FOR COMORES
* ==============================================================================
* Download and save
cap dbnomics import, pr(Franc-zone) d(FRANCZONE) indicator(money_KMF) clear

* Resize variables
qui ds, has(type string)
foreach var in `r(varlist)' {
	qui replace `var' = strtrim(`var')
	qui gen length = strlen(`var')
	qui su length
	qui recast str`r(max)' `var', force
	qui drop length
}

* Destring
destring period, replace

* Save
append using `temp_master'
save `temp_master', replace



* ==============================================================================
* 				INFLATION
* ==============================================================================
* Download and save
dbnomics import, pr(Franc-zone) d(FRANCZONE) indicator(price_index_percent) clear

* Save
append using `temp_master'
save `temp_master', replace


* ==============================================================================
* 				DEFICIT
* ==============================================================================

* Download and save
dbnomics import, pr(Franc-zone) d(FRANCZONE) indicator(budget_balance_percent) clear

* Save
append using `temp_master'
save `temp_master', replace


* ==============================================================================
* 				Output
* ==============================================================================


* Sort
sort period country

* Save download date 
gmdsavedate, source(FRANC_ZONE)

* Save
save ${output}, replace



}

* Create the log
clear
set obs 1
gen variable = "FRANC_ZONE"
gen status = ""
if _rc == 0 {
	replace status = "Success"
}
else {
	replace status = "Error"
}

* Save
save "$data_temp/download_log/FRANC_ZONE_log.dta", replace

