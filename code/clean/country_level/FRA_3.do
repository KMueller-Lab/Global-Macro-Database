* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* CLEAN DATA ON FRENCH MONETARY AGGREGATES 
* 
* Author:
* Mohamed Lehbib
* National University of Singapore
*
* Created: 2025-09-18
*
* URL: https://www.numdam.org/item/JSFS_1991__132_3_19_0.pdf
* ==============================================================================

* ==============================================================================
*			SET UP
* ==============================================================================

clear
global input "${data_raw}/country_level/FRA_3.xlsx"
global output "${data_clean}/country_level/FRA_3"

* Open
import excel using "$input", clear first 

* Rename 
ren Prix CPI

* Derive inflation 
tset year 
gen infl = (CPI - L.CPI) / L.CPI * 100

* Add ISO3 
gen ISO3 = "FRA"

* Convert Franc to Euro and billions to millions
merge m:1 ISO3 using $eur_fx, nogen assert(2 3) keep(3)
replace M1 = (M1 / EUR) * 1000
replace M2 = (M2 / EUR) * 1000
replace M3 = (M3 / EUR) * 1000 
drop EUR

* Add source identifier
qui ds ISO3 year, not
foreach var in `r(varlist)' {
	ren `var' CS3_`var'
}

* ==============================================================================
* 				Output
* ==============================================================================
* Sort
sort ISO3 year

* Order
order ISO3 year

* Check for duplciates
isid ISO3 year

* Save
save "${output}", replace
