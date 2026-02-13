* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* CONSTRUCT M3
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

* Create temporary file to store the data
tempfile temp_master
save `temp_master', replace emptyok

* Open the data
use "$data_final/clean_data_wide", clear

* ==============================================================================
* Specify country specific priority ordering.
* ==============================================================================

* Set up the priority list
cap splice, priority(OECD_MEI IMF_IFS ADB ECLAC JST CS1 CS2 CS3 BORDO HFS NBS) generate(M3) varname(M3) base_year(2018) method("chainlink")


* Create the log
clear 
set obs 1 
gen variable = "M3"
gen status = ""
if _rc == 0 {
	replace status = "Success"
}
else {
	replace status = "Error"
}

* Save 
save "$data_temp/combine_log/M3_log.dta", replace

* Generate documentation if requested
if $document == 1 {
	use "$data_final/chainlinked_M3", clear
	gmdmakedoc M3, log ylabel("Money supply (M3), millions of LCU (Log scale)")	
	gen variable = "M3"
	gen variable_definition = "Money supply (M3)"
	save "$data_final/documentation_M3", replace
}
