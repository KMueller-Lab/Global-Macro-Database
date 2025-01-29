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
* ==============================================================================

* ==============================================================================
* SET UP 
* ==============================================================================

* Clear data 
clear

* Define input and output files
global input "${data_raw}/aggregators/IMF/IMF_FPP.dta"
global output "${data_clean}/aggregators/IMF/IMF_FPP.dta"

* ==============================================================================
* CLEAN DATA 
* ==============================================================================

* Open 
use "${input}", clear

br

* Extract ISO3 code
kountry ifscode , from(imfn) to(iso3c)
ren _ISO3C_ ISO3
drop if ISO3==""

* Keep relevant variables
keep ISO3 year revenue expenditure debt

* Rename variables 
ren (revenue expenditure debt) (govrev_GDP govexp_GDP govdebt_GDP)

* Derive government deficit
gen govdef_GDP = govrev_GDP - govexp_GDP

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
