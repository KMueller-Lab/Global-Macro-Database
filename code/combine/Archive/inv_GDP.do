* ==============================================================================
* GLOBAL MACRO PROJECT
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* Constructing investment series (in % of GDP)
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
splice, priority(OECD_EO EUS ADB AMF BCEAO AMECO IMF_WEO IMF_IFS UN CS1 CS2 CS3 WDI WDI_ARC AHSTAT JST JO ECLAC FRANC_ZONE Mitchell IMF_WEO_forecast) generate(inv_GDP) varname(inv_GDP) base_year(2018) method("none")

* Create the log
clear 
set obs 1 
gen variable = "inv_GDP"
gen status = ""
if _rc == 0 {
	replace status = "Success"
}
else {
	replace status = "Error"
}

* Save 
save "$data_temp/combine_log/inv_GDP_log.dta", replace

* Generate documentation if requested
if $document == 1 {
	use "$data_final/chainlinked_inv_GDP", clear
	gmdmakedoc inv_GDP, ylabel("Investment, % of GDP") transformation("ratio")
	gen variable = "inv_GDP"
	gen variable_definition = "Investment to GDP ratio"
	save "$data_final/documentation_inv_GDP", replace
}
