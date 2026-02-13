* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* CONSTRUCING GENERAL GOVERNMENT DEFICIT TO GDP
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
splice, priority(EUS OECD_EO AMF IMF_WEO IMF_GFS IMF_FPP ECLAC ADB CS1 CS2 IMF_WEO_forecast) generate(gen_govdef_GDP) varname(gen_govdef_GDP) base_year(2018) method("none")

}


* Create the log
clear 
set obs 1 
gen variable = "gen_govdef_GDP"
gen status = ""
if _rc == 0 {
	replace status = "Success"
}
else {
	replace status = "Error"
}

* Save 
save "$data_temp/combine_log/gen_govdef_GDP_log.dta", replace


cap {
* Generate documentation if requested
if $document == 1 {
	use "$data_final/chainlinked_gen_govdef_GDP", clear
	gmdmakedoc gen_govdef_GDP, ylabel("General government deficit, % of GDP") transformation("rate")
	gen variable = "gen_govdef_GDP"
	gen variable_definition = "General government deficit"
	save "$data_final/documentation_gen_govdef_GDP", replace
}
}

* Log if there is an error 
if _rc != 0 {
	use "$data_temp/combine_log/gen_govdef_GDP_log.dta", clear 
	replace status = "Error"
	save "$data_temp/combine_log/gen_govdef_GDP_log.dta", replace
}

