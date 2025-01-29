* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
* 
* Description: 
* This Stata script reads in and clean interest rates for Brazil
*
* Author:
* Mohamed Lehbib
* National University of Singapore
*
* Created: 2024-10-08
*
* URL:  http://www.ipeadata.gov.br/Default.aspx 
* ==============================================================================

* ==============================================================================
* 	SET UP 
* ==============================================================================
* Clear
clear
global input "${data_raw}/country_level/BRA_1"
global output "${data_clean}/country_level/BRA_1"

* ===============================================================================
*	PROCESS
* ===============================================================================

* Open
import excel using "${input}", clear sheet("Processed") first

* Convert
replace pop = pop / 1000000

* Destring
destring *, replace

* Drop empty row
drop in l

* Add source identifier
qui ds year, not
foreach var in `r(varlist)'{
	ren `var' CS1_`var'
}

* Add country's ISO3
gen ISO3 = "BRA"

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
