* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* CONSTRUCT FIXED CAPITAL FORMATION SERIES
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
qui splice, priority(OECD_EO EUS AMECO UN FAO BCEAO IMF_IFS CS1 CS2 CS3 WDI WDI_ARC AHSTAT Mitchell JO HFS) generate(finv) varname(finv) base_year(2018) method("chainlink")

* Create the log
clear 
set obs 1 
gen variable = "finv"
gen status = ""
if _rc == 0 {
	replace status = "Success"
}
else {
	replace status = "Error"
}

* Save 
save "$data_temp/combine_log/finv_log.dta", replace

* Generate documentation if requested
if $document == 1 {
	use "$data_final/chainlinked_finv", clear
	gmdmakedoc finv, log ylabel("Fixed investment, millions of LCU (Log scale)")	
	gen variable = "finv"
	gen variable_definition = "Fixed investment"
	save "$data_final/documentation_finv", replace
}

