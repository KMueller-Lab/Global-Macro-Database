* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* DOWNLOAD WEST AND CENTRAL AFRICAN ECONOMIC DATA FROM BANQUE DE FRANCE
* 
* Author:
* Mohamed Lehbib
* National University of Singapore
*
* Created: 2024-07-20
*
* Description: 
* This Stata script downloads economic data for west african currency union members
*
* Data source:
* DBnomics API
*
* ==============================================================================

clear
global output "${data_raw}\aggregators\FRANC_ZONE\FRANC_ZONE"

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
savedelta ${output}, id(period country series_code dataset_code)
