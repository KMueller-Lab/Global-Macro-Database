* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Ziliang Chen, Mohamed Lehbib
* ==============================================================================
*
* Construct consumption 
* 
* Author:
* Karsten Müller
* National University of Singapore
*
* Created: 2024-10-17
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
cap splice, priority(OECD_EO EUS AMECO UN BCEAO AMF IMF_IFS ECLAC CS1 CS2 CS3 WDI WDI_ARC AHSTAT HFS) generate(cons) varname(cons) method("chainlink") base_year(2018)

* Create the log
clear 
set obs 1 
gen variable = "cons"
gen status = ""
if _rc == 0 {
	replace status = "Success"
}
else {
	replace status = "Error"
}

* Save 
save "$data_temp/combine_log/cons_log.dta", replace

* Generate documentation if requested
if $document == 1 {
	use "$data_final/chainlinked_cons", clear
	gmdmakedoc cons, log ylabel("Total consumption, millions of LCU (Log scale)")	
	gen variable = "cons"
	gen variable_definition = "Total consumption"
	save "$data_final/documentation_cons", replace
}
