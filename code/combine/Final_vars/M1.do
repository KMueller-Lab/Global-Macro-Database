* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* CONSTRUCT M1 SERIES
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
cap splice, priority(AFRISTAT BCEAO AFDB OECD_MEI ADB CS1 CS2 CS3 AHSTAT JST NBS Mitchell ECLAC BORDO HFS) generate(M1) varname(M1) base_year(2018) method("chainlink")



* Create the log
clear 
set obs 1 
gen variable = "M1"
gen status = ""
if _rc == 0 {
	replace status = "Success"
}
else {
	replace status = "Error"
}

* Save 
save "$data_temp/combine_log/M1_log.dta", replace

* Generate documentation if requested
if $document == 1 {
	use "$data_final/chainlinked_M1", clear
	gmdmakedoc M1, log ylabel("Money supply (M1), millions of LCU (Log scale)")	
	gen variable = "M1"
	gen variable_definition = "Money supply (M1)"
	save "$data_final/documentation_M1", replace
}

if _rc != 0 {
	use "$data_temp/combine_log/M1_log.dta", clear 
	replace status = "Error"
	save "$data_temp/combine_log/M1_log.dta", replace
}
