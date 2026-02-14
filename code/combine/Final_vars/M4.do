* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* CONSTRUCT M4 SERIES
* 
* Created: 
* 2024-06-28
* 
* Author:
* Mohamed Lehbib
* National University of Singapore
* 	
* ==============================================================================
* Run the master file
do "code/0_master.do"

* Open the data
use "$data_final/clean_data_wide", clear

* ==============================================================================
* Specify country specific priority ordering.
* ==============================================================================

* Set up the priority list
cap splice, priority(ADB JST HFS) generate(M4) varname(M4) base_year(2018) method("chainlink")

* Create the log
clear 
set obs 1 
gen variable = "M4"
gen status = ""
if _rc == 0 {
	replace status = "Success"
}
else {
	replace status = "Error"
}

* Save 
save "$data_temp/combine_log/M4_log.dta", replace

* Generate documentation if requested
if $document == 1 {
	use "$data_final/chainlinked_M4", clear
	gmdmakedoc M4, log ylabel("Money supply (M4), millions of LCU (Log scale)")	
	gen variable = "M4"
	gen variable_definition = "Money supply (M4)"
	save "$data_final/documentation_M4", replace
}
