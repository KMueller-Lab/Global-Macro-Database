* ==============================================================================
* GLOBAL MACRO PROJECT
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* CONSTRUCING imports series (in % of GDP)
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
cap splice, priority(OECD_EO EUS ADB AMF BCEAO UN AMECO UN IMF_WEO IMF_IFS CS1 CS2 CS3 WDI WDI_ARC JST AHSTAT Mitchell NBS IMF_WEO_forecast) generate(imports_GDP) varname(imports_GDP) base_year(2019) method("none")

* Create the log
clear 
set obs 1 
gen variable = "imports_GDP"
gen status = ""
if _rc == 0 {
	replace status = "Success"
}
else {
	replace status = "Error"
}

* Save 
save "$data_temp/combine_log/imports_GDP_log.dta", replace

* Generate documentation if requested
if $document == 1 {
	use "$data_final/chainlinked_imports_GDP", clear
	gmdmakedoc imports_GDP, ylabel("Imports, % of GDP") transformation("ratio")
	gen variable = "imports_GDP"
	gen variable_definition = "Imports to GDP ratio"
	save "$data_final/documentation_imports_GDP", replace
}
