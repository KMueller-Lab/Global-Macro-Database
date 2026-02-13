* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* CONSTRUCT SHORT TERM INTEREST RATE SERIES
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
cap splice, priority(IMF_IFS OECD_EO OECD_KEI OECD_MEI_ARC AMECO ADB ECLAC CS1 CS2 CS3 JST BORDO NBS Homer_Sylla MW IHD HFS) generate(strate) varname(strate) base_year(2017) method("none")



* Create the log
clear 
set obs 1 
gen variable = "strate"
gen status = ""
if _rc == 0 {
	replace status = "Success"
}
else {
	replace status = "Error"
}

* Save 
save "$data_temp/combine_log/strate_log.dta", replace

* Generate documentation if requested
if $document == 1 {
	use "$data_final/chainlinked_strate", clear
	gmdmakedoc strate, ylabel("Short term interest rate (%)") transformation("rate")
	gen variable = "strate"
	gen variable_definition = "Short term interest rate"
	save "$data_final/documentation_strate", replace
}
