* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* CONSTRUCT FIXED CAPITAL FORMATION SERIES (In % of GDP)
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
cap splice, priority(BCEAO EUS UN OECD_EO IMF_IFS FAO AMECO CS1 CS2 CS3 WDI WDI_ARC AHSTAT JO Mitchell) generate(finv_GDP) varname(finv_GDP) base_year(2018) method("none")




* Create the log
clear 
set obs 1 
gen variable = "finv_GDP"
gen status = ""
if _rc == 0 {
	replace status = "Success"
}
else {
	replace status = "Error"
}

* Save 
save "$data_temp/combine_log/finv_GDP_log.dta", replace

* Generate documentation if requested
if $document == 1 {
	use "$data_final/chainlinked_finv_GDP", clear
	gmdmakedoc finv_GDP, ylabel("Fixed investment, % of GDP") transformation("ratio")
	gen variable = "finv_GDP"
	gen variable_definition = "Fixed investment to GDP ratio"
	save "$data_final/documentation_finv_GDP", replace
}
