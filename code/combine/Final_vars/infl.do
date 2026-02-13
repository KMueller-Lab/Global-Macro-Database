* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* CONSTRUCING INFLATION
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
cap splice, priority(CS3 OECD_EO WB_infl ADB AMF BIS BCEAO EUS FRANC_ZONE OECD_KEI WDI WDI_ARC IMF_WEO IMF_IFS CS1 CS2 AHSTAT JST Moxlad JERVEN ECLAC RR CLIO BORDO MW Mitchell HFS NBS FZ IHD IMF_WEO_forecast) generate(infl) varname(infl) base_year(2018) method("none")

* Create the log
clear 
set obs 1 
gen variable = "infl"
gen status = ""
if _rc == 0 {
	replace status = "Success"
}
else {
	replace status = "Error"
}

* Save 
save "$data_temp/combine_log/infl_log.dta", replace

* Generate documentation if requested
if $document == 1 {
	use "$data_final/chainlinked_infl", clear
	replace source = "BIS_infl" if source == "BIS"
	gmdmakedoc infl, ylabel("Inflation rate (%)") transformation("rate")
	gen variable = "infl"
	gen variable_definition = "Inflation"
	save "$data_final/documentation_infl", replace
}
