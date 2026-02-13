* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* CONSTRUCING GOVERNMENT DEFICIT TO GDP
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

cap {

* Open the data
use "$data_final/clean_data_wide", clear

* ==============================================================================
* Specify country specific priority ordering.
* ==============================================================================
* Set up the priority list
splice, priority(EUS BCEAO IMF_GFS FRANC_ZONE AFDB CS1 CS2 FZ Mitchell HFS) generate(cgovdef_GDP) varname(cgovdef_GDP) base_year(2018) method("none")


}

* Create the log
clear 
set obs 1 
gen variable = "cgovdef_GDP"
gen status = ""
if _rc == 0 {
	replace status = "Success"
}
else {
	replace status = "Error"
}

* Save 
save "$data_temp/combine_log/cgovdef_GDP_log.dta", replace

cap {
	
	* Generate documentation if requested
	if $document == 1 {
		use "$data_final/chainlinked_cgovdef_GDP", clear
		gmdmakedoc cgovdef_GDP, ylabel("Central government deficit, % of GDP") transformation("rate")
		gen variable = "cgovdef_GDP"
		gen variable_definition = "Central government deficit to GDP ratio"
		save "$data_final/documentation_cgovdef_GDP", replace
	}
}

* Log if there is an error 
if _rc != 0 {
	use "$data_temp/combine_log/cgovdef_GDP_log.dta", clear 
	replace status = "Error"
	save "$data_temp/combine_log/cgovdef_GDP_log.dta", replace
}
