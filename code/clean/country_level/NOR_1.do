* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* CLEAN NORWEGIAN HISTORICAL GDP DATA 
* 
* Description: 
* This stata script cleans historical data for Norway from Grytten (2022)
*
* Author:
* Karsten Müller
* National University of Singapore
*
* Created: 2024-04-21
*
* URL: https://doi.org/10.1111/ehr.13085
* ==============================================================================

* ==============================================================================
* 	SET UP 
* ==============================================================================

* Clear 
clear 

* Define input and output 
global input "${data_raw}/country_level/NOR_1.xlsx"
global output "${data_clean}/country_level/NOR_1"

* ==============================================================================
* 	PROCESS
* ==============================================================================

* Open 
import excel using "${input}", clear sheet("NOR") first

* Add country's ISO3
gen ISO3 = "NOR"


* Add the deflator
gen deflator = (nGDP / rGDP) * 100

* Rebase the GDP to 2010
qui gen  temp = deflator if year == 2010 
qui egen defl_2010 = max(temp) 
qui replace rGDP = (rGDP * defl_2010) / 100 
qui drop temp defl_2010	

* Update the deflator
replace deflator = (nGDP / rGDP) * 100



* Add source identifier
qui ds ISO3 year, not
foreach var  in `r(varlist)'{
	ren `var' CS1_`var'
}

* Drop
drop CS1_nGDP_pc

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
