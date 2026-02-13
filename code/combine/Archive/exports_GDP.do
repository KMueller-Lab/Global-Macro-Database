* ==============================================================================
* GLOBAL MACRO PROJECT
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* Constructing exports series (in % of GDP)
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
cap splice, priority(OECD_EO EUS UN ADB AMF BCEAO JST AMECO IMF_IFS IMF_WEO CS1 CS2 CS3 WDI WDI_ARC AHSTAT Mitchell NBS IMF_WEO_forecast) generate(exports_GDP) varname(exports_GDP) base_year(2019) method("none")



* Create the log
clear 
set obs 1 
gen variable = "exports_GDP"
gen status = ""
if _rc == 0 {
	replace status = "Success"
}
else {
	replace status = "Error"
}

* Save 
save "$data_temp/combine_log/exports_GDP_log.dta", replace

* Generate documentation if requested
if $document == 1 {
	use "$data_final/chainlinked_exports_GDP", clear
	gmdmakedoc exports_GDP, ylabel("Exports, % of GDP") transformation("ratio")
	gen variable = "exports_GDP"
	gen variable_definition = "Exports to GDP ratio"
	save "$data_final/documentation_exports_GDP", replace
}

