* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* Description: 
* This Stata script reads in and cleans the IMF Global Debt Database.
*
* Author:
* Karsten Müller
* National University of Singapore
*
* Created: 2024-04-21 
*
* ==============================================================================

* ==============================================================================
* SET UP 
* ==============================================================================

* Clear data 
clear

* Define input and output files
global input "${data_raw}/aggregators/IMF/IMF_GDD/IMF_GDD.dta"
global output "${data_clean}/aggregators/IMF/IMF_GDD/IMF_GDD.dta"

* ==============================================================================
* CLEAN DATA 
* =========================================================================

* Open 
use "${input}", clear

* Extract ISO3 code
kountry ifscode , from(imfn) to(iso3c)
ren _ISO3C_ ISO3
drop if ISO3==""

* Rename variables 
ren (cg gg ngdp) (cgovdebt_GDP gen_govdebt_GDP nGDP)

* Keep pnly relevant columns
keep ISO3 year cgovdebt_GDP gen_govdebt_GDP nGDP

* Convert units
replace nGDP = nGDP * 1000
replace nGDP = nGDP / 1000 if ISO3 == "AFG" & year <= 1993

* Derive government levels 
gen cgovdebt = (cgovdebt_GDP * nGDP) / 100
gen gen_govdebt = (gen_govdebt_GDP * nGDP) / 100

* Convert currency for Croatia	
replace nGDP = nGDP / 7.5345 if ISO3 == "HRV"

* Add source identifier
qui ds ISO3 year, not
foreach var  in `r(varlist)'{
	ren `var' IMF_GDD_`var'
}

* Rebase variables to $base_year
gmd_rebase IMF_GDD

* Check for ratios and levels 
check_gdp_ratios IMF_GDD

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

