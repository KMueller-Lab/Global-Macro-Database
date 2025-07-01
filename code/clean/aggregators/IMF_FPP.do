* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Ziliang Chen, Mohamed Lehbib
* ==============================================================================
*
* CLEAN IMF PUBLIC FINANCES IN MODERN HISTORY
*
* Author:
* Karsten Müller
* National University of Singapore
*
* Last Editor:
* Mohamed Lehbib
* National University of Singapore
*
* Created: 2024-04-21 
* Last updated: 2024-09-25
*
* URL: https://www.imf.org/external/datamapper/datasets/FPP
* ==============================================================================

* ==============================================================================
* SET UP 
* ==============================================================================

* Clear data 
clear

* Define input and output files
global input "${data_raw}/aggregators/IMF/IMF_FPP_2025.dta"
global output "${data_clean}/aggregators/IMF/IMF_FPP.dta"

* ==============================================================================
* CLEAN DATA 
* ==============================================================================

* Open 
use "${input}", clear

* Extract ISO3 code
ren ifscode IFS 
merge m:1 IFS using $isomapping, keepus(ISO3) keep(3) assert(2 3) nogen

* Keep relevant variables
keep ISO3 year rev exp pb debt rgc ie 

* Create government deficit as the sum of primary balance and interest expenses
* This is due to the fact that primary balance data is the difference between a government's revenues and its non-interest expenditures. Whereas the net lending / net borrowing is the difference between government revenue and expenditure
gen govdef_GDP = pb - ie
drop pb ie 

* Rename variables 
ren (rev exp debt rgc) (govrev_GDP govexp_GDP govdebt_GDP rGDP_growth)

* Add source identifier
qui ds ISO3 year, not
foreach var  in `r(varlist)'{
	ren `var' IMF_FPP_`var'
}

* ==============================================================================
* 	Output
* ==============================================================================
* Sort
sort ISO3 year

* Order
order ISO3 year

* Check for duplicates
isid ISO3 year

* Save 
save "${output}", replace
