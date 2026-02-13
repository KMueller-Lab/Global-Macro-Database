* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* Constructing long-term interest rate 
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
cap splice, priority(EUS OECD_EO OECD_KEI IMF_IFS AMECO OECD_MEI_ARC JST BORDO AMECO CS1 CS2 FZ MD MW NBS Homer_Sylla CLIO) generate(ltrate) varname(ltrate) base_year(2020) method("none")



* Create the log
clear 
set obs 1 
gen variable = "ltrate"
gen status = ""
if _rc == 0 {
	replace status = "Success"
}
else {
	replace status = "Error"
}

* Save 
save "$data_temp/combine_log/ltrate_log.dta", replace

* Generate documentation if requested
if $document == 1 {
	use "$data_final/chainlinked_ltrate", clear
	gmdmakedoc ltrate, ylabel("Long term interest rate (%)") transformation("rate")
	gen variable = "ltrate"
	gen variable_definition = "Long term interest rate"
	save "$data_final/documentation_ltrate", replace
}
