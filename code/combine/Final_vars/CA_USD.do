* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* Constructing current account balance in USD 
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
splice, priority(IMF_IFS OECD_EO CS2 Mitchell) generate(CA_USD) varname(CA_USD) base_year(2019) method("chainlink")



* Create the log
clear 
set obs 1 
gen variable = "CA_USD"
gen status = ""
if _rc == 0 {
	replace status = "Success"
}
else {
	replace status = "Error"
}

* Save 
save "$data_temp/combine_log/CA_USD_log.dta", replace

* Generate documentation if requested
if $document == 1 {
	use "$data_final/chainlinked_CA_USD", clear
	gmdmakedoc exports, ylabel("Current account balance, millions of USD")	
	gen variable = "CA_USD"
	gen variable_definition = "CA_USD"
	save "$data_final/documentation_CA_USD", replace
}
