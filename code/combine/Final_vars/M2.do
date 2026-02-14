* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* CONSTRUCT M2 SERIES
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

* Clear the panel
clear

* Open the data
use "$data_final/clean_data_wide", clear

* ==============================================================================
* Specify country specific priority ordering.
* ==============================================================================

* Set up the priority list
cap splice, priority(AFRISTAT BCEAO AFDB FRANC_ZONE ADB CS1 CS2 CS3 JST AHSTAT NBS Mitchell ECLAC BORDO HFS) generate(M2) varname(M2) base_year(2018) method("chainlink")


* Create the log
clear 
set obs 1 
gen variable = "M2"
gen status = ""
if _rc == 0 {
	replace status = "Success"
}
else {
	replace status = "Error"
}

* Save 
save "$data_temp/combine_log/M2_log.dta", replace

* Generate documentation if requested
if $document == 1 {
	use "$data_final/chainlinked_M2", clear
	gmdmakedoc M2, log ylabel("Money supply (M2), millions of LCU (Log scale)")	
	gen variable = "M2"
	gen variable_definition = "Money supply (M2)"
	save "$data_final/documentation_M2", replace
}
