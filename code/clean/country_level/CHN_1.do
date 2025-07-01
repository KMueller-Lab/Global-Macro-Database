* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* 
* Description: 
* This Stata script reads in and clean data from National Bureau of Statistics of China (NBS)
*
* Author:
* Ziliang Chen
* National University of Singapore
*
* Created: 2024-12-18
*
* URL: https://data.stats.gov.cn/english/easyquery.htm?cn=C01
* ==============================================================================

* ==============================================================================
* 	SET UP 
* ==============================================================================
* Clear
clear
global input "${data_raw}/country_level/CHN_1"
global output "${data_clean}/country_level/CHN_1"

* ===============================================================================
*	PROCESS
* ===============================================================================

* Open
import excel using "${input}", clear sheet("Sheet1") first

* Drop notes on units
drop in 1

* Destring all variables
destring *, replace 
ren rGDP rGDP_index

* Convert units
foreach var in nGDP finv cons exports imports govrev govexp govtax {
	replace `var' = `var' * 100
}
replace USDfx = USDfx / 100
replace pop = pop / 100
replace infl = infl - 100

* Derive real GDP
gen b_nGDP = nGDP if rGDP_index == 100
egen base_nGDP = max(b_nGDP)
gen rGDP = (rGDP_index * base_nGDP) / 100

* Derive CA in LCU and in GDP
replace CA_USD = CA_USD / 100
gen CA = CA_USD * USDfx
gen CA_GDP = (CA / nGDP) * 100

* Drop redundant variables
drop CA_USD b_nGDP base_nGDP rGDP_index

* Add the deflator
gen deflator = (nGDP / rGDP) * 100

* Rebase the GDP to 2010
qui gen  temp = deflator if year == 2010 
qui egen defl_2010 = max(temp) 
qui replace rGDP = (rGDP * defl_2010) / 100 
qui drop temp defl_2010	

* Update the deflator
replace deflator = (nGDP / rGDP) * 100


* Add ISO3 
gen ISO3 = "CHN"

* Add source identifier
qui ds year ISO3, not
foreach var in `r(varlist)' {
	ren `var' CS1_`var'
}

* ==============================================================================
* 	OUTPUT
* ==============================================================================
* Sort
sort ISO3 year

* Order 
order ISO3 year

* Check for duplicates
isid ISO3 year

* Output
save "${output}", replace