* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* Constructing investment
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
cap splice, priority(OECD_EO EUS AMECO UN BCEAO FRANC_ZONE AMF ADB IMF_WEO IMF_IFS ECLAC CS1 CS2 CS3 WDI WDI_ARC JST AHSTAT Mitchell JO HFS IMF_WEO_forecast) generate(inv) varname(inv) base_year(2018) method("chainlink")

* Create the log
clear 
set obs 1 
gen variable = "inv"
gen status = ""
if _rc == 0 {
	replace status = "Success"
}
else {
	replace status = "Error"
}

* Save 
save "$data_temp/combine_log/inv_log.dta", replace

* Generate documentation if requested
if $document == 1 {
	use "$data_final/chainlinked_inv", clear
	gmdmakedoc inv, log ylabel("Investment, millions of LCU (Log scale)")		
	gen variable = "inv"
	gen variable_definition = "Investment"
	save "$data_final/documentation_inv", replace
}
