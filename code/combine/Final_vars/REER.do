* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* CONSTRUCTING REAL EFFECTIVE EXCHANGE RATE SERIES
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
cap {
splice, priority(WDI WDI_ARC BRUEGEL BIS EUS IMF_IFS OECD_EO LUND CS1) generate(REER) varname(REER) base_year($base_year) method("chainlink")

* Assert REER equal to 100 in 2015
levelsof ISO3 if REER != . & year == 2015, local(countries) clean
foreach country of local countries {
	assert round(REER,0.1) == 100 if year == 2015
}
}

* Create the log
clear 
set obs 1 
gen variable = "REER"
gen status = ""
if _rc == 0 {
	replace status = "Success"
}
else {
	replace status = "Error"
}

* Save 
save "$data_temp/combine_log/REER_log.dta", replace

cap {
* Generate documentation if requested
if $document == 1 {
	use "$data_final/chainlinked_REER", clear
	replace source = "BIS_REER" if source == "BIS"
	gmdmakedoc REER, ylabel("Real effective exchange rate, $base_year = 100") transformation("ratio")
	gen variable = "REER"
	gen variable_definition = "Real effective exchange rate"
	save "$data_final/documentation_REER", replace
}

if _rc != 0 {
	use "$data_temp/combine_log/REER_log.dta", clear 
	replace status = "Error"
	save "$data_temp/combine_log/REER_log.dta", replace
}
