* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* Clean interest rate data from Homer & Sylla
* 
* Author:
* Mohamed Lehbib
* National University of Singapore
* 
* Created: 2024-10-30
*
* Source: A History of Interest Rates
* ==============================================================================

* ==============================================================================
* 	SET UP
* ==============================================================================
* Clear all
clear

* Define input and output files
global input "${data_raw}/aggregators/Homer_Sylla/Homer_Sylla.xlsx"
global output "${data_clean}/aggregators/Homer_Sylla/Homer_Sylla.dta"

* ==============================================================================
* 	SET UP
* ==============================================================================
* Open
import excel using "${input}", clear firstrow cellrange(A1:E2222)

* Add source identifier
qui ds ISO3 year, not
foreach var in `r(varlist)'{
	ren `var' Homer_Sylla_`var'
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
