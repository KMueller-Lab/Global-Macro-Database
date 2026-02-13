* ==============================================================================
* GLOBAL MACRO PROJECT
* by Karsten Müller, Chenzi Xu, Ziliang Chen, Mohamed Lehbib
* ==============================================================================
*
* Construct real consumption series 
* 
* Author:
* Karsten Müller
* National University of Singapore
*
* Created: 2025-01-20
*
* ==============================================================================
* Run the master file 
do "code/0_master.do"

* Clear the panel
clear

* Create temporary file to store the data
tempfile temp_master
save `temp_master', replace emptyok

* Open the data
use "$data_final/clean_data_wide", clear

* ==============================================================================
* Specify country specific priority ordering.
* ==============================================================================

* Set up the priority list
cap splice, priority(IMF_IFS WDI UN CS3 BARRO) generate(rcons) varname(rcons) method("chainlink") base_year(2019)



* Create the log
clear 
set obs 1 
gen variable = "rcons"
gen status = ""
if _rc == 0 {
	replace status = "Success"
}
else {
	replace status = "Error"
}

* Save 
save "$data_temp/combine_log/rcons_log.dta", replace

* Generate documentation if requested
if $document == 1 {
	use "$data_final/chainlinked_rcons", clear
	gmdmakedoc rcons, log ylabel("Real total consumption, millions of LCU (Log scale)")	
	gen variable = "rcons"
	gen variable_definition = "Real total consumption"
	save "$data_final/documentation_rcons", replace
} 
