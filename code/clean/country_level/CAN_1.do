* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* 
* Description: 
* This Stata script reads in and clean historical data for Canada
*
* Author:
* Mohamed Lehbib
* National University of Singapore
*
* Created: 2024-10-02
*
* URL: https://www150.statcan.gc.ca/n1/pub/11-516-x/3000140-eng.htm
* ==============================================================================

* ==============================================================================
* 	SET UP 
* ==============================================================================
* Clear
clear
global input "${data_raw}/country_level/CAN_1"
global output "${data_clean}/country_level/CAN_1"

* ===============================================================================
*	PROCESS
* ===============================================================================

* Open
import excel using "${input}", clear sheet("gov") first

* Drop empty rows
drop if year == .

* Save
tempfile temp_master
save `temp_master', replace emptyok

* Open
local sheets pop Finance trade national_accounts
foreach sheet of local sheets{
	
	* Open
	import excel using "${input}", clear sheet("`sheet'") first
	
	* Sort
	sort year
	
	* Drop empty rows 
	drop if year == .
	
	* Save and merge
	tempfile temp_c
	save `temp_c', replace emptyok
	merge 1:1 year using `temp_master', nogen
	save `temp_master', replace	
	
}

* Add source identifier
qui ds year, not
foreach var in `r(varlist)'{
	ren `var' CS1_`var'
}

* Add country's ISO3
gen ISO3 = "CAN"

* Derive inflation rate
sort ISO3 year
encode ISO3, gen(id)
xtset id year
by id: gen CS1_infl = (CS1_CPI - L.CS1_CPI) / L.CS1_CPI * 100 if L.CS1_CPI != .
drop id

* Compute total consumption
gen CS1_cons = CS1_cons_gov + CS1_cons_HH 

* Compute investment 
gen CS1_inv = CS1_inventory_change + CS1_finv 

* Drop 
drop CS1_inventory_change CS1_cons_HH CS1_cons_gov

* Add ratios to gdp variables
gen CS1_cons_GDP    = (CS1_cons / CS1_nGDP) * 100
gen CS1_imports_GDP = (CS1_imports / CS1_nGDP) * 100
gen CS1_exports_GDP = (CS1_exports / CS1_nGDP) * 100
gen CS1_finv_GDP    = (CS1_finv / CS1_nGDP) * 100
gen CS1_inv_GDP     = (CS1_inv / CS1_nGDP) * 100
gen CS1_govrev_GDP = (CS1_govrev / CS1_nGDP) * 100
gen CS1_govexp_GDP = (CS1_govexp / CS1_nGDP) * 100
gen CS1_govtax_GDP = (CS1_govtax / CS1_nGDP) * 100
gen CS1_govdebt_GDP = (CS1_govdebt / CS1_nGDP) * 100


* ===============================================================================
* 	Output
* ===============================================================================

* Order
order ISO3 year

* Sort
sort ISO3 year

* Check for duplicates
isid ISO3 year

* Save
save "${output}", replace
