* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* CLEAN IRISH HISTORICAL DATA 
* 
* Description: 
* This stata script cleans historical data for Ireland
*
* Author:
* Karsten Müller
* National University of Singapore
*
* Created: 2025-02-21
*
* URL: https://rebeccastuart.net/historical-data/
* ==============================================================================

* ==============================================================================
* 	SET UP 
* ==============================================================================

* Clear 
clear 

* First run Eurostat because we will use later 
do "$code_clean/aggregators/EUS.do"
clear

* Define input and output 
global input  "${data_raw}/country_level/IRL_1.xlsx"
global EUS    "${data_clean}/aggregators/EUS/EUS"
global output "${data_clean}/country_level/IRL_1"

* ==============================================================================
* 	PROCESS
* ==============================================================================
	
* Open 
import excel using "${input}", clear sheet("Data") first

* Add country's ISO3
gen ISO3 = "IRL"

* Rename columns
ren (A UNEMP STI LTI) (year unemp strate ltrate)

* Keep relevant columns
keep ISO3 year unemp strate ltrate

* Save temporarily
tempfile temp_master
save `temp_master', replace

import excel using "${input}", clear sheet("Paper") first

merge 1:1 ISO3 year using `temp_master', nogen

* Derive values based on Eurostat 
merge 1:1 ISO3 year using $EUS, keepus(EUS_nGDP EUS_rGDP EUS_cons) keep(1 3) nogen
qui splice, priority(EUS CS1) varname(nGDP) generate(nGDP) method("chainlink") base_year(2010) save("NO")
qui splice, priority(EUS CS1) varname(rGDP) generate(rGDP) method("chainlink") base_year(2010) save("NO")
drop CS1* EUS*

* Add source identifier
qui ds ISO3 year, not
foreach var  in `r(varlist)'{
	ren `var' CS1_`var'
}

* ===============================================================================
* 	OUTPUT
* ===============================================================================
* Order 
order ISO3 year

* Sort
sort ISO3 year	

* Check for duplicates
isid ISO3 year

* Save
save "${output}", replace
