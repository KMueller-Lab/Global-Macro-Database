* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* Clean central bank policy rate interest rate data
* 
* Author:
* Mohamed Lehbib
* National University of Singapore
* 
* Created: 2024-10-30
*
* Source: The Effect of Monetary Policy on Systemic Bank Funding Stability
* URL: https://maximiliangrimm.com/research/
* ==============================================================================

* ==============================================================================
* 	SET UP
* ==============================================================================
* Clear all
clear

* Define input and output files
global input "${data_raw}/aggregators/Grimm/Grimm"
global output "${data_clean}/aggregators/Grimm/Grimm.dta"

* ==============================================================================
* 	SET UP
* ==============================================================================
* Open
use "${input}", clear

* Keep end-of-year observation
sort iso3 year month
by iso3 year: keep if _n == _N

* Keep relevant columns
keep iso3 year R_Policy

* Rename
ren iso3 ISO3
ren R_Policy cbrate

* Drop countries with no data
drop if ISO3 == "XXK"

* Add source identifier
qui ds ISO3 year, not
foreach var in `r(varlist)'{
	ren `var' Grimm_`var'
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

* Save
save "${output}", replace
