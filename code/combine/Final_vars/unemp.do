* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* CONSTRUCT UNEMPLOYMENT RATE SERIES
* 
* Created: 
* 2024-06-28
* 
* Author:
* Mohamed Lehbib
* National University of Singapore
* 	
* ==============================================================================

* Clear the panel
clear

* Run the master file
do "code/0_master.do"

* Open the data
use "$data_final/clean_data_wide", clear

* ==============================================================================
* Specify country specific priority ordering.
* ==============================================================================

* Set up the priority list
cap splice, priority(IMF_WEO EUS OECD_EO OECD_KEI AMECO ADB AFDB CS1 CS2 JST IMF_IFS AHSTAT HFS ILO IMF_WEO_forecast) generate(unemp) varname(unemp) base_year(2018)  method("none")


* Create the log
clear 
set obs 1 
gen variable = "unemp"
gen status = ""
if _rc == 0 {
	replace status = "Success"
}
else {
	replace status = "Error"
}

* Save 
save "$data_temp/combine_log/unemp_log.dta", replace

* Generate documentation if requested
if $document == 1 {
	use "$data_final/chainlinked_unemp", clear
	gmdmakedoc unemp, ylabel("Unemployment rate (%)") transformation("rate")
	gen variable = "unemp"
	gen variable_definition = "Unemployment"
	save "$data_final/documentation_unemp", replace
}
